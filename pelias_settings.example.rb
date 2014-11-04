# manipulate the chef run by copying this file to a location of your choosing
#   and setting the environment variable PELIAS_VAGRANTFILE=/path/to/your/file.
#   This default config will be loaded if you don't set this value.
#
# the index_data key will only carry out the task if the
#   underlying guards in the chef recipes return false. For example, if
#   create_index => true is set for the schema, the schema will be created
#   on the first provisioning run. If the image is re-provisioned with create_index => true,
#   the index creation step will be skipped as the recipe will check to see if the
#   index is already present.
#
# similarly, if index_data => true is set for geonames, quattroshapes or osm, the data will be
#   loaded on the initial provisioning run. Subsequent provisioning runs will not attempt to re-index
#   the data, as the recipe will check for the existence of downloaded data and skip the run if it
#   already exists.
#
Vagrant.configure('2') do |config|
  config.vm.provision :chef_solo do |chef|
    chef.json = {
      'elasticsearch' => {
        'version' => '1.3.4'
      },
      'pelias' => {
        'schema' => {
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
