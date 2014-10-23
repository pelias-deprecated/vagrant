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

Getting Started
---------------
* running `vagrant up` will:
  * boot a linux instance that you can interact with via `vagrant ssh`
  * install all the dependencies required to run Pelias:
    * elasticsearch
    * nodejs
    * required Pelias repositories
    * other system dependencies
  * create the Elasticsearch 'pelias' index
  * load Geonames data for Italy into Elasticsearch
  * load OSM extracts for Rome and Florence into Elasticsearch
  * run the Pelias API server, which you can interact with locally via your browser, curl, etc thanks to the magic of port forwarding: [API](http://localhost:3100/search?input=Coli&lat=41.8902&lon=12.4923)
* to preserve all that data you just loaded, run `vagrant halt`
* to bring it all back online (without having to redo all the loading of the data), run `vagrant up`
* to start from scratch: `vagrant destroy; vagrant up`

Tweaking Things
---------------
* the vagrant_chef.rb file is your primary means of overriding any default values.
* attempting to load a large set of geonames (e.g. -i all) will almost certainly result in failure. Choose only the regions you need:
  * for example, if you want to test the data in Warsaw, only load the geonames data for Poland
* osm extracts you may want to load can be found on the [Mapzen Metro Extracts](https://mapzen.com/metro-extracts) page.
* multiple extracts can be loaded by updating the extracts hash:
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

* multiple geoname countries can be loaded by editing the geonames array:
```
  'geonames' => {
    'index_data' => true,
    'country_codes' => [
      'IT',
      'DE'
    ]
  },
```
