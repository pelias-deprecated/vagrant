# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  config.omnibus.chef_version = '11.12.8'
  config.vm.hostname          = 'pelias'

  if ENV['PELIAS_AWS']
    # for this to work, please follow the instructions here: https://github.com/mitchellh/vagrant-aws
    #   and update the values as appropriate for your env.
    config.vm.box = 'dummy'

    config.vm.provider :aws do |aws, override|
      aws.access_key_id     = ENV['AWS_ACCESS_KEY_ID']
      aws.secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
      aws.keypair_name      = ENV['PELIAS_AWS_KEYPAIR_NAME']
      aws.ami               = ENV['PELIAS_AWS_AMI'] || 'ami-7747d01e'
      aws.tags              = { 'vagrant' => 'true', 'role' => 'pelias' }

      override.ssh.username         = ENV['PELIAS_AWS_SSH_USERNAME']      || 'ubuntu'
      override.ssh.private_key_path = ENV['PELIAS_AWS_PRIVATE_KEY_PATH']  || '~/.ssh/id_rsa'
    end
  else
    config.vm.box     = 'ubuntu-14.04-opscode'
    config.vm.box_url = 'http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-14.04_chef-provisionerless.box'
  end

  config.vm.provider 'virtualbox' do |v|
    v.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
    v.customize ['modifyvm', :id, '--natdnsproxy1', 'on']

    host = RbConfig::CONFIG['host_os']

    def memish(ram, mem_max, mem_min)
      if ram > mem_max
        mem_max
      elsif ram < mem_min
        mem_min
      else
        ram
      end
    end

    mem_divisor = 2
    mem_min     = 3_096
    mem_max     = 8_192

    if host =~ /darwin/
      cpu = `sysctl -n hw.ncpu`.to_i
      ram = `sysctl -n hw.memsize`.to_i / 1024 / 1024 / mem_divisor
      mem = memish(ram, mem_max, mem_min)
    elsif host =~ /linux/
      cpu = `nproc`.to_i
      ram = `grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//'`.to_i / 1024 / mem_divisor
      mem = memish(ram, mem_max, mem_min)
    else
      cpu = 2
      mem = mem_min
    end

    if ENV['PELIAS_VAGRANT_CPUS']
      v.cpus = ENV['PELIAS_VAGRANT_CPUS']
    else
      v.cpus = cpu
    end
    if ENV['PELIAS_VAGRANT_MB']
      v.memory = ENV['PELIAS_VAGRANT_MB']
    else
      v.memory = mem
    end
  end

  # forward 3100 (API)
  config.vm.network :forwarded_port, host: 3100, guest: 3100
  config.vm.network :forwarded_port, host: 9200, guest: 9200

  config.vm.network :private_network, ip: '192.168.33.10'
  config.berkshelf.berksfile_path = 'Berksfile'
  config.berkshelf.enabled = true
end

# includes
if ENV['PELIAS_VAGRANT_CFG']
  load ENV['PELIAS_VAGRANT_CFG']
else
  load 'pelias_settings.example.rb'
end
