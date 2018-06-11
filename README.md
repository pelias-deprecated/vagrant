------
This repository holds an archive of the Pelias Vagrant image, which was once used to help set up Pelias, but is now out of date.

For the new, fancy way to set up Pelias please see our [Docker setup!](https://github.com/pelias/docker)
------

README
======

Build Status
------------
[![Circle CI](https://circleci.com/gh/pelias/vagrant.svg?style=svg)](https://circleci.com/gh/pelias/vagrant)

Requirements
------------
* a system with ~4GB of RAM and ~20GB of free disk space to load a modest test environment
* ruby 2.x
* [ChefDK](http://downloads.getchef.com/chef-dk/)
* [VirtualBox](https://www.virtualbox.org/wiki/Downloads) ~> 1.5
* [Vagrant](https://www.vagrantup.com/downloads.html) ~> 1.7

Goals
-----
* to provide, via the included Chef code, a reference for installing your own Pelias system:
  * learn what dependencies you'll need, what the workflow looks like and how you can mold that to your own environment and needs
* to provide a sandbox environment for people to do quick development against a local Pelias instance

Access points
-------------
* API: `curl http://localhost:3100/v1`
* [Leaflet Demo](https://mapzen.github.io/leaflet-geocoder/#12/40.7258/-73.9804): references the API on search.mapzen.com, change url to localhost:3100 so you can see a visual representation of the data you're loading
* `vagrant ssh && sudo su -` and you've got free reign in a sandboxed environment
* You can also share both access to your vagrant environment via ssh, or just share the API endpoint:
  * `vagrant share --ssh` will accomplish both
  * `vagrant share` will allow only the latter

Environment
-----------
* you can set the following environment variables to specify the number of cores and amount of RAM in MB to allocate to the VM. If left unset, we will infer sensible defaults (see Vagrantfile).

```bash
export PELIAS_VAGRANT_CPUS=3
export PELIAS_VAGRANT_MB=6144
```

* you can alter the default settings in pelias_settings.example.rb by using a local config, 
which can in fact be used to override any value set in the chef run:

```bash
export PELIAS_VAGRANT_CFG=${PWD}/pelias_settings.rb
```

Getting started
---------------
* install VirtualBox, Vagrant and ChefDK
* `vagrant plugin install vagrant-berkshelf`
* `vagrant plugin install vagrant-omnibus`
* if you use rbenv or otherwise manipulate your path, make sure you set `/opt/chefdk/bin` ahead of any other locally installed gems that might conflict with berkshelf, foodcritic, etc, e.g.:

```bash
eval "$(rbenv init -)"
export PATH=/opt/chefdk/bin:$PATH
```

* copy the included pelias_settings.example.rb to a location of your choice, then export the environment variable `PELIAS_VAGRANT_CFG` to reference it: `export PELIAS_VAGRANT_CFG=/path/to/the/file`
  * you can leave the defaults in place until you get familiar with things, or if you're feeling up to it, edit away
  * you can override anything found in `attributes/default.rb`, but typically what you'll want access to is referenced in the example config: `pelias_settings.example.rb`
* from the repository root run `vagrant up`, which will:
  * download the vagrant box (this is a one time operation)
  * boot a linux instance that you can connect to via `vagrant ssh`
  * install all the dependencies required to load data into and run Pelias:
    * elasticsearch
    * nodejs
    * required Pelias repositories
    * other system dependencies
  * create the Elasticsearch 'pelias' index
  * run the Pelias API server, which you can interact with locally via your browser, curl, etc thanks to the magic of port forwarding: [example query](http://localhost:3100/v1/search?text=London)
    * as soon as the geonames data load starts, you'll be able to start querying the index via the API
    * more details on the API can be found here: [Pelias API](https://github.com/pelias/pelias-doc)
    * in addition, you can access our [Demo](https://mapzen.github.io/leaflet-geocoder/#12/40.7258/-73.9804) which will let you visualize the data you're loading, run searches, etc.
    * the demo by default uses the endpoint API search.mapzen.com, clone the project and change URL to localhost:3100 to query your local instance
  * load Geonames data for England into Elasticsearch
  * load an OSM extract for London into Elasticsearch
* `vagrant suspend` or `vagrant halt` will stop the virtual machine without any data loss
* `vagrant up` will bring it back online for use
* to start entirely from scratch: `vagrant destroy; vagrant up`, or to just reload all the data: `curl -XDELETE http://localhost:9200/pelias` followed by `vagrant provision`

How long will this take?
------------------------
* presently, to load the defaults (all of Great Britain from Geonames, and London from OSM): ~30 minutes, not including initial build time of the VM, which is a one time event
* larger countries with more data, e.g. the US and most countries in Western Europe, will take longer

Tweaking things
---------------
* the `pelias_settings.example.rb` file shows some ways you can define/override values in the provisioning process
* you can copy this file to a location of your choice and reference it via an environment variable: `PELIAS_VAGRANT_CFG`
  * if the environment variable is set, vagrant will attempt to load the contents of the file it references
  * if the environment variable is not set, vagrant will load pelias_settings.example.rb provided in the repository
* let's suppose you want to load osm data for locations in Germany and Italy:
  * from the repo root: `cp pelias_settings.example.rb ~/.pelias_settings.rb`
  * in your profile, `export PELIAS_VAGRANT_CFG=${HOME}/.pelias_settings.rb`
    * this file is now your means of manipulating the vagrant chef run going forward

#### openaddresses
* import data from openaddresses with an array of data files from the default data directory in `default.rb` (remove `data_files` hash for the entire global collection):
```
  'openaddresses' => {
    'index_data' => true,
    'data_files' => [
      'us-ny-nyc'
    ]
  },
```

#### geonames
* multiple geoname countries can be loaded by editing the geonames alpha2 array of [country codes](http://www.geonames.org/countries/) (or you can specify 'all'):
```
  'geonames' => {
    'index_data' => true,
    'alpha2_country_codes' => [
      'IT',
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
      'florence' => 'https://s3.amazonaws.com/metro-extracts.mapzen.com/florence_italy.osm.pbf',
      'munich' => 'https://s3.amazonaws.com/metro-extracts.mapzen.com/munich_germany.osm.pbf'
    }
  }
```

* now that you've edited `PELIAS_VAGRANT_CFG`, run `vagrant up` to start loading data, or `vagrant provision` if you'd previously started the instance

Bugs/Issues
-----------
* there is presently a bug resulting in the OSM process not exiting on completion of data load for certain extracts
* there is a [bug](https://github.com/mitchellh/vagrant/issues/5199) in vagrant that prevents re-provisioning if the the system is halted
  * as a workaround, `rm .vagrant/machines/default/virtualbox/synced_folders` and `vagrant reload --provision`

Contributing
------------
* yes please!
* fork, create a feature branch, make your changes, add/update specs, submit a pull request
