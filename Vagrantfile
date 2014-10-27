# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  config.vm.hostname = 'pelias'
  config.vm.box      = 'ubuntu-14.04'
  config.vm.box_url  = 'https://oss-binaries.phusionpassenger.com/vagrant/boxes/latest/ubuntu-14.04-amd64-vbox.box'

  config.vm.provider 'virtualbox' do |v|
    v.cpus   = 2
    v.memory = 6144
  end

  config.vm.network :private_network, ip: '33.33.33.10'
  config.vm.network :forwarded_port, host: 3100, guest: 3100
  config.berkshelf.enabled = true
end

# includes
load 'pelias_settings.rb'
