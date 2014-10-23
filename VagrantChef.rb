# manipulate the chef run here
#
Vagrant.configure('2') do |config|
  config.vm.provision :chef_solo do |chef|
    chef.json = {
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
