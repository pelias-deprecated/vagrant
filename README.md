README
======

[![Circle CI](https://circleci.com/gh/pelias/vagrant.png?style=badge)](https://circleci.com/gh/pelias/vagrant)

Notes
-----
* WORK IN PROGRESS!!!

Requirements
------------
* [VirtualBox](https://www.virtualbox.org/wiki/Downloads) >= 4.3.18
* [Vagrant](https://www.vagrantup.com/downloads.html) >= 1.6.5
* a system with an absolute minimum of ~4GB of RAM (more is better, and will be necessary if you want to load larger regions) and ~50GB of free disk space

Goals
-----
* to provide, via the included Chef code, a reference for installing your own Pelias system:
  * learn what dependencies you'll need, what the workflow looks like and how you can mold that to your own environment and needs
* to provide a sandbox environment for people to do quick development against a local Pelias instance

Access points
-------------
* API: `curl http://localhost:3100`
* [Demo](http://rawgit.com/pelias/demo/vagrant/index.html#loc=7,41.857,13.217), which references the API on localhost:3100
* Elasticsearch: `curl http://localhost:9200`
* `vagrant ssh && sudo su -` and you've got free reign in a sandboxed environment

Environment
-----------
* you can set the following environment variables to specify the number of cores and amount of RAM in MB to allocate to the VM. If left unset, we will infer sensible defaults (see Vagrantfile).

```
export PELIAS_VAGRANT_CPUS=3
export PELIAS_VAGRANT_MB=6144
```

* you can alter the default settings in pelias_settings.example.rb by using a local config:

```
export PELIAS_VAGRANT_CFG=${HOME}/.pelias_settings.rb
```

Getting started
---------------
* copy the included pelias_settings.example.rb to a location of your choice, then export the environment variable `PELIAS_VAGRANTFILE` to reference it: `export PELIAS_VAGRANTFILE=/path/to/the/file`
  * you can leave the defaults in place until you get familiar with things, or if you're feeling up to it, edit away
  * you can override anything found in `attributes/default.rb`
* from the repository root run `vagrant up`, which will:
  * download the vagrant box (this is a one time operation)
  * boot a linux instance that you can connect to via `vagrant ssh`
  * install all the dependencies required to load data into and run Pelias:
    * elasticsearch
    * nodejs
    * required Pelias repositories
    * other system dependencies
  * create the Elasticsearch 'pelias' index
  * run the Pelias API server, which you can interact with locally via your browser, curl, etc thanks to the magic of port forwarding: [example query](http://localhost:3100/search?input=fontana&lat=41.8902&lon=12.4923)
    * as soon as the geonames data load starts, you'll be able to start querying the index via the API
    * more details on the API can be found here: [Pelias API](https://github.com/pelias/api)
    * in addition, you can access our [Demo](http://rawgit.com/pelias/demo/vagrant/index.html#loc=7,41.857,13.217) which will let you visualize the data you're loading, run searches, etc.
  * load Geonames data for Italy into Elasticsearch
  * load OSM extracts for Rome and Florence into Elasticsearch
* `vagrant suspend` or `vagrant halt` will stop the virtual machine without any data loss
* `vagrant up` will bring it back online for use
* to start from scratch: `vagrant destroy; vagrant up`

How long will this take?
------------------------
* presently, to load the defaults (geonames for IT, quattroshapes for ITA and Florence and Rome OSM data): ~1 hour (including initial build time of the VM, which is a one time deal)
* larger countries with more data, e.g. the US and most countries in Western Europe, will take longer

Tweaking things
---------------
* the `pelias_settings.example.rb` file shows some ways you can define/override values in the provisioning process
* you can copy this file to a location of your choice and reference it via an environment variable: `PELIAS_VAGRANTFILE`
  * if the environment variable is set, vagrant will attempt to load the contents of the file it references
  * if the environment variable is not set, vagrant will load pelias_settings.example.rb provided in the repository
* let's suppose you want to load osm data for locations in Germany and Italy:
  * from the repo root: `cp pelias_settings.example.rb ~/.pelias_settings.rb`
  * in your profile, `export PELIAS_VAGRANTFILE=${HOME}/.pelias_settings.rb`
    * this file is now your means of manipulating the vagrant chef run going forward

#### geonames
* multiple geoname countries can be loaded by editing the geonames alpha2 array of [country codes](http://www.geonames.org/countries/):
```
  'geonames' => {
    'index_data' => true,
    'country_codes' => [
      'IT',
      'DE'
    ]
  },
```

#### quattroshapes
* multiple quattroshapes can be loaded by modifying the quattroshapes alpha3 array of [country codes](http://www.geonames.org/countries/):
```
  'quattroshapes' => {
    'index_data' => true,
    'alpha3' => [
      'ITA',
      'DEU'
    ]
  },
```

#### osm
* osm extracts you may want to load can be found on the [Mapzen Metro Extracts](https://mapzen.com/metro-extracts) page.
* multiple extracts can be loaded by updating the extracts hash:
```
  'osm' => {
    'index_data' => true,
    'extracts' => {
      'florence' => 'https://s3.amazonaws.com/metro-extracts.mapzen.com/florence_italy.osm.pbf',
      'munich' => 'https://s3.amazonaws.com/metro-extracts.mapzen.com/munich_germany.osm.pbf'
    }
  }
```

* now that you've edited `PELIAS_VAGRANTFILE`, run `vagrant up` to start loading data, or `vagrant provision` if you'd previously started the instance

Bugs/Issues
-----------
* quattroshapes take a long time to load ( >8 hours in this type of environment)
  * look into breaking quattroshapes up into more easily ingested chunks

TODO
----
* specs for quattro

Contributing
------------
* yes please!
* fork, create a feature branch, make your changes, add/update specs, submit a pull request

Happy Geocoding!
----------------
```curl 'localhost:3100/search?input=grazie&lat=41.8902&lon=12.4923' | python -mjson.tool```
```json
{
    "date": 1414926251985,
    "features": [
        {
            "geometry": {
                "coordinates": [
                    12.4833598,
                    41.9046615
                ],
                "type": "Point"
            },
            "properties": {
                "admin0": "Italia",
                "admin1": "Roma",
                "admin2": "Provincia di Roma",
                "alpha3": "ITA",
                "local_admin": "Roma",
                "locality": "Roma",
                "name": "Madonna Delle Grazie",
                "neighborhood": "Campo Marzio",
                "text": "Madonna Delle Grazie, Roma"
            },
            "type": "Feature"
        },
...
```

![pelias](./img/vagrant.gif)
