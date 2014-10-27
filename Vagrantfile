# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  config.vm.hostname = 'pelias'
  config.vm.box      = 'ubuntu-14.04'
  config.vm.box_url  = 'https://oss-binaries.phusionpassenger.com/vagrant/boxes/latest/ubuntu-14.04-amd64-vbox.box'

  config.vm.provider 'virtualbox' do |v|
    host = RbConfig::CONFIG['host_os']

    # give VM 1/2 system memory & access to all cpu cores on the host
    if host =~ /darwin/
      cpu  = `sysctl -n hw.ncpu`.to_i
      mem  = `sysctl -n hw.memsize`.to_i / 1024 / 1024 / 2
    elsif host =~ /linux/
      cpu = `nproc`.to_i
      mem = `grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//'`.to_i / 1024 / 4
    else
      cpu = 2
      mem = 2048
    end

    v.cpus   = cpu
    v.memory = mem
  end

  config.vm.network :private_network, ip: '33.33.33.10'
  config.vm.network :forwarded_port, host: 3100, guest: 3100
  config.berkshelf.enabled = true
end

# includes
load 'pelias_settings.rb'
