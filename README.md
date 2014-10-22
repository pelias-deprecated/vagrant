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
  * load an OSM extract of Florence, Italy into Elasticsearch
  * run the Pelias API server, which you can interact with locally via your browser, curl, etc thanks to the magic of port forwarding: [API](http://localhost:3100/search?input=Empire&lat=40.7903&lon=73.9597)

Tweaking Things
---------------
* if you re-provision the instance (`vagrant provision`) with default settings, you're going to end up re-loading data. If you need to reprovision, first edit the Vagrantfile to
  disable any data loads that have already taken place.
* the Vagrantfile is your primary means of overriding any default values.
* attempting to load a large set of geonames like this locally (e.g. -i all) will almost certainly result in failure. Choose only the regions you need:
  * for example, if you want to test the data in Warsaw, only load the geonames data for Poland
