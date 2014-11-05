# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  config.vm.hostname = 'pelias'
  config.vm.box      = 'ubuntu-14.04'
  config.vm.box_url  = 'https://oss-binaries.phusionpassenger.com/vagrant/boxes/latest/ubuntu-14.04-amd64-vbox.box'

  config.vm.provider 'virtualbox' do |v|
    host = RbConfig::CONFIG['host_os']

    def memish(ram, mem_max)
      if ram > mem_max
        mem_max
      else
        ram
      end
    end

    mem_divisor = 2
    mem_min     = 2048
    mem_max     = 6144

    if host =~ /darwin/
      cpu = `sysctl -n hw.ncpu`.to_i
      ram = `sysctl -n hw.memsize`.to_i / 1024 / 1024 / mem_divisor
      mem = memish(ram, mem_max)
    elsif host =~ /linux/
      cpu = `nproc`.to_i
      ram = `grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//'`.to_i / 1024 / mem_divisor
      mem = memish(ram, mem_max)
    else
      cpu = 2
      mem = mem_min
    end

    v.cpus   = cpu
    v.memory = mem
  end

  # forward 3100 (API) and 9200 (ES)
  config.vm.network :forwarded_port, host: 3100, guest: 3100
  config.vm.network :forwarded_port, host: 9200, guest: 9200

  config.vm.network :private_network, ip: '33.33.33.10'
  config.berkshelf.enabled = true
end

# includes
if ENV['PELIAS_VAGRANTFILE']
  load ENV['PELIAS_VAGRANTFILE']
else
  load 'pelias_settings.example.rb'
end
