README
======

Requirements
------------
* download [VirtualBox](https://www.virtualbox.org/wiki/Downloads) >= 4.3.18
* download [Vagrant](https://www.vagrantup.com/downloads.html) >= 1.6.5

Getting Started
---------------
* `vagrant up` will:
  * boot a linux instance that you can interact with via `vagrant ssh`
  * install all the dependencies required to run Pelias:
    * elasticsearch
    * nodejs
    * required Pelias repositories
    * other system dependencies
  * create the Elasticsearch 'pelias' index
  * load Geonames data into Elasticsearch
  * load a sample OSM extract for New York City into Elasticsearch
  * run the Pelias API, which you can interact with locally via your browser: [http://localhost:3100/suggest?]
