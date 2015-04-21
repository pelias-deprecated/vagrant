# Manipulate the chef run by copying this file to a location of your choosing
# and setting the environment variable PELIAS_VAGRANTFILE=/path/to/your/file.
# This default config will be loaded if you don't set this value.

Vagrant.configure('2') do |config|
  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = 'cookbooks'

    chef.json = {
      'pelias' => {
        'schema' => {
          'create_index' => true
        },
        'geonames' => {
          'index_data' => true,
          'alpha2_country_codes' => [
            'GB'
          ]
        },
        'quattroshapes' => {
          'index_data' => true,
          'alpha3_country_codes' => [
            'GBR'
          ]
        },
        'osm' => {
          'index_data' => true,
          'extracts' => {
            'london' => 'https://s3.amazonaws.com/metro-extracts.mapzen.com/london_england.osm.pbf'
          }
        }
      }
    }

    chef.run_list = [
      'recipe[pelias::default]'
    ]
  end
end
