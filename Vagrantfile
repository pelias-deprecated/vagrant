# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  config.vm.hostname = 'pelias'
  config.vm.box      = 'ubuntu-14.04'
  config.vm.box_url  = 'https://oss-binaries.phusionpassenger.com/vagrant/boxes/latest/ubuntu-14.04-amd64-vbox.box'

  config.vm.provider 'virtualbox' do |v|
    host = RbConfig::CONFIG['host_os']

    # give 1/2 RAM to VM. Setting this to 4, for example,
    #   would give 1/4 RAM to the VM.
    mem_divisor = 2
    if host =~ /darwin/
      cpu  = `sysctl -n hw.ncpu`.to_i
      mem  = `sysctl -n hw.memsize`.to_i / 1024 / 1024 / mem_divisor
    elsif host =~ /linux/
      cpu = `nproc`.to_i
      mem = `grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//'`.to_i / 1024 / mem_divisor
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
