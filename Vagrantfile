# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  config.vm.hostname = 'pelias'
  config.vm.box      = 'ubuntu-14.04'
  config.vm.box_url  = 'https://oss-binaries.phusionpassenger.com/vagrant/boxes/latest/ubuntu-14.04-amd64-vbox.box'

  config.vm.provider 'virtualbox' do |v|
    v.memory = 6144
    v.cpus = 2
  end

  # Assign this VM to a host-only network IP, allowing you to access it
  # via the IP. Host-only networks can talk to the host machine as well as
  # any other machines on the same network, but cannot be accessed (through this
  # network interface) by any external networks.
  config.vm.network :private_network, ip: '33.33.33.10'

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.

  # config.vm.network :public_network

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  config.vm.network :forwarded_port, host: 3100, guest: 3100

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider :virtualbox do |vb|
  #   # Don't boot with headless mode
  #   vb.gui = true
  #
  #   # Use VBoxManage to customize the VM. For example to change memory:
  #   vb.customize ["modifyvm", :id, "--resize", "1024"]
  # end
  #
  # View the documentation for the provider you're using for more
  # information on available options.

  #config.ssh.max_tries = 40
  #config.ssh.timeout   = 120

  # The path to the Berksfile to use with Vagrant Berkshelf
  # config.berkshelf.berksfile_path = "./Berksfile"

  # Enabling the Berkshelf plugin. To enable this globally, add this configuration
  # option to your ~/.vagrant.d/Vagrantfile file
  config.berkshelf.enabled = true

  # An array of symbols representing groups of cookbook described in the Vagrantfile
  # to exclusively install and copy to Vagrant's shelf.
  # config.berkshelf.only = []

  # An array of symbols representing groups of cookbook described in the Vagrantfile
  # to skip installing and copying to Vagrant's shelf.
  # config.berkshelf.except = []

  config.vm.provision :chef_solo do |chef|
    chef.json = {
      'nodejs' => {
        'version' => '0.10.32',
        'checksum_linux_x64' => '621777798ed9523a4ad1c4d934f94b7bc765871d769a014a53a4f1f7bcb5d5a7',
        'dir' => '/usr'
      },
      'elasticsearch' => {
        'version' => '1.3.4',
        'allocated_memory' => '5G',
        'custom_config' => {
          'threadpool.bulk.type'      => 'fixed',
          'threadpool.bulk.size'      => '2',
          'threadpool.bulk.wait_time' => '3s',
          'threadpool.bulk.queue'     => '500'
        },
        'plugin' => {
          'mandatory' => [
            'pelias-analysis'
          ]
        },
        'plugins' => {
          'pelias-analysis' => {
            'url' => 'https://github.com/pelias/elasticsearch-plugin/blob/1.3.4/pelias-analysis.zip?raw=true'
          }
        }
      },
      'java' => {
        'install_flavor' => 'openjdk',
        'jdk_version' => '7'
      },
      'pelias' => {
        'index' => {
          'create_index' => true
        },
        'geonames' => {
          'index_data' => true,
          'country_codes' => [
            'IT'
          ]
        },
        'quattroshapes' => {
          'index_data' => true
        },
        'osm' => {
          'index_data' => true,
          'extracts' => {
            'rome' => 'https://s3.amazonaws.com/metro-extracts.mapzen.com/rome_italy.osm.pbf',
            'florence' => 'https://s3.amazonaws.com/metro-extracts.mapzen.com/florence_italy.osm.pbf'
          }
        }
      }
    }

    chef.run_list = [
      'recipe[pelias::default]'
    ]
  end
end
