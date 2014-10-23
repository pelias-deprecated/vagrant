README
======

[![Circle CI](https://circleci.com/gh/pelias/pelias-vagrant.png?style=badge)](https://circleci.com/gh/pelias/pelias-vagrant)

Notes
-----
* WORK IN PROGRESS!!!

Requirements
------------
* [VirtualBox](https://www.virtualbox.org/wiki/Downloads) >= 4.3.18
* [Vagrant](https://www.vagrantup.com/downloads.html) >= 1.6.5
* a system with ~8GB of RAM and ~60GB of free disk space

Goals
-----
* provide, via the included Chef code, a reference for installing your own Pelias system:
  * learn what dependencies you'll need, what the workflow looks like and how you can mold that to your own environment and needs
* provide a sandbox environment for people to do quick development against Pelias

Getting Started
---------------
* running `vagrant up` will:
  * boot a linux instance that you can interact with via `vagrant ssh`
  * install all the dependencies required to run load and run Pelias:
    * elasticsearch
    * nodejs
    * required Pelias repositories
    * other system dependencies
  * create the Elasticsearch 'pelias' index
  * load Geonames data for Italy into Elasticsearch
  * load OSM extracts for Rome and Florence into Elasticsearch
  * run the Pelias API server, which you can interact with locally via your browser, curl, etc thanks to the magic of port forwarding: [API](http://localhost:3100/search?input=Coli&lat=41.8902&lon=12.4923)
* `vagrant halt` will stop the virtual machine without any data loss
* `vagrant up` will bring it back online for use
* to start from scratch: `vagrant destroy; vagrant up`

Tweaking Things
---------------
* the vagrant_chef.rb file is your primary means of overriding any default values.

#### geonames
* multiple geoname countries can be loaded by editing the geonames array followed by `vagrant provision`:
```
  'geonames' => {
    'index_data' => true,
    'country_codes' => [
      'IT',
      'DE'
    ]
  },
```

#### osm
* osm extracts you may want to load can be found on the [Mapzen Metro Extracts](https://mapzen.com/metro-extracts) page.
* multiple extracts can be loaded by updating the extracts hash followed by `vagrant provision`:
```
  'osm' => {
    'index_data' => true,
    'extracts' => {
      'rome' => 'https://s3.amazonaws.com/metro-extracts.mapzen.com/rome_italy.osm.pbf',
      'florence' => 'https://s3.amazonaws.com/metro-extracts.mapzen.com/florence_italy.osm.pbf',
      'munich' => 'https://s3.amazonaws.com/metro-extracts.mapzen.com/munich_germany.osm.pbf'
    }
  }
```


Bugs/Issues
-----------
* due to an issue in Elasticsearch 0.3.10 cookbook, setting `default[:elasticsearch][:version]` inside the attributes file does not take effect
  * current workaround is to override the version in pelias_settings.rb
  * future fix is to move to Elasticsearch 0.3.11 when it's pushed to opscode
* there's an issue with geonames which will cause the load to always run unless you set `'index_data' => false` in vagrant_chef.rb explicitly
  * # NOTE: there's a bug here in that the download doesn't write to data_dir, so this will always run at the moment.
* quattroshapes take a long time to load ( >8 hours in this type of environment)
  * look into breaking quattroshapes up into more easily ingested chunks

TODO
----
* end to end testing
* remaining specs
