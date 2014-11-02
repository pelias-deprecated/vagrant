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
* a system with ~8GB of RAM and ~50GB of free disk space

Goals
-----
* to provide, via the included Chef code, a reference for installing your own Pelias system:
  * learn what dependencies you'll need, what the workflow looks like and how you can mold that to your own environment and needs
* to provide a sandbox environment for people to do quick development against a local Pelias instance

Getting started
---------------
* from the repository root run `vagrant up`, which will:
  * download the vagrant box
    * this is a one time operation
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
  * load Geonames data for Italy into Elasticsearch
  * load OSM extracts for Rome and Florence into Elasticsearch
* `vagrant suspend` or `vagrant halt` will stop the virtual machine without any data loss
* `vagrant up` will bring it back online for use
* to start from scratch: `vagrant destroy; vagrant up`

How long will this take?
------------------------
* presently, to load the defaults (geonames for IT, all of quattroshapes, Florence and Rome): ~9 hours
* 95% of this time is spent on quattroshapes, which we're working to modify to allow importing only required pieces

Tweaking things
---------------
* the `pelias_settings.rb` file is your primary means of overriding any default values
* as an example, let's suppose you want to load osm data for a location in Germany:

#### geonames
* multiple geoname countries can be loaded by editing the geonames array:
```
  'geonames' => {
    'index_data' => true,
    'country_codes' => [
      'DE'
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
      'munich' => 'https://s3.amazonaws.com/metro-extracts.mapzen.com/munich_germany.osm.pbf'
    }
  }
```

* now that you've edited `pelias_settings.rb`, run `vagrant up` to start loading data, or `vagrant provision` if you'd previously started the instance

Bugs/Issues
-----------
* due to an issue in Elasticsearch 0.3.10 cookbook, setting `default[:elasticsearch][:version]` inside the attributes file does not take effect
  * current workaround is to override the version in `pelias_settings.rb`
  * future fix is to move to Elasticsearch 0.3.11 when it's pushed to opscode
* quattroshapes take a long time to load ( >8 hours in this type of environment)
  * look into breaking quattroshapes up into more easily ingested chunks

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
