# env
default[:pelias][:basedir]                    = '/opt/pelias'
default[:pelias][:cfg_dir]                    = '/etc/pelias'
default[:pelias][:cfg_file]                   = 'pelias.json'

# user
default[:pelias][:user][:name]                = 'pelias'
default[:pelias][:user][:home]                = '/home/pelias'

# esclient
default[:pelias][:esclient][:logdir]          = '/var/log/esclient'
default[:pelias][:esclient][:keepalive]       = true
default[:pelias][:esclient][:api_version]     = node[:elasticsearch][:version].split('.')[0] + '.' + node[:elasticsearch][:version].split('.')[1]
default[:pelias][:esclient][:request_timeout] = 120_000
default[:pelias][:esclient][:max_retries]     = 3
default[:pelias][:esclient][:dead_timeout]    = 3000
default[:pelias][:esclient][:max_sockets]     = 20

# api
default[:pelias][:api][:port]                 = 3100
default[:pelias][:api][:node_env]             = 'dev'
default[:pelias][:api][:deploy_to]            = "#{node[:pelias][:basedir]}/pelias-api"
default[:pelias][:api][:repository]           = 'https://github.com/pelias/api.git'
default[:pelias][:api][:revision]             = 'master'
default[:pelias][:api][:restart_wait]         = 60
default[:pelias][:api][:shutdown_timeout]     = 30

# geonames
default[:pelias][:geonames][:repository]      = 'https://github.com/mapzen/pelias-geonames.git'
default[:pelias][:geonames][:data_dir]        = "#{node[:pelias][:basedir]}/geonames-data"
default[:pelias][:geonames][:revision]        = 'master'
default[:pelias][:geonames][:index_data]      = false
default[:pelias][:geonames][:country_codes]   = %w(IT) # Italy
default[:pelias][:geonames][:timeout]         = 14_400 # 4 hours

# quattroshapes
default[:pelias][:quattroshapes][:repository] = 'https://github.com/pelias/quattroshapes-pipeline.git'
default[:pelias][:quattroshapes][:revision]   = 'master'
default[:pelias][:quattroshapes][:data_url]   = 'https://s3.amazonaws.com/peter.johnson/quattroshapes-simplified.tar.gz'
default[:pelias][:quattroshapes][:file_name]  = node[:pelias][:quattroshapes][:data_url].split('/').last
default[:pelias][:quattroshapes][:data_dir]   = "#{node[:pelias][:basedir]}/quattroshapes-data"
default[:pelias][:quattroshapes][:index_data] = false
default[:pelias][:quattroshapes][:types]      = %w(admin0 admin1 admin2 local_admin locality neighborhood)
default[:pelias][:quattroshapes][:timeout]    = 86_400 # 4 hours, note that this is per type

# osm
default[:pelias][:osm][:basedir]              = node[:pelias][:basedir]
default[:pelias][:osm][:repository]           = 'https://github.com/mapzen/pelias-openstreetmap.git'
default[:pelias][:osm][:revision]             = 'master'
default[:pelias][:osm][:index_data]           = false
default[:pelias][:osm][:timeout]              = 14_400 # 4 hours
default[:pelias][:osm][:leveldb]              = "#{node[:pelias][:basedir]}/leveldb"
default[:pelias][:osm][:extracts]             = {
  'new-york' => 'https://s3.amazonaws.com/metro-extracts.mapzen.com/new-york.osm.pbf',
  'rome' => 'https://s3.amazonaws.com/metro-extracts.mapzen.com/rome_italy.osm.pbf'
}

# schema
default[:pelias][:index][:repository]         = 'https://github.com/pelias/schema.git'
default[:pelias][:index][:revision]           = 'master'
default[:pelias][:index][:drop_index]         = false
default[:pelias][:index][:create_index]       = false
default[:pelias][:index][:replicas]           = 0
default[:pelias][:index][:shards]             = 1
default[:pelias][:index][:concurrency]        = 32

# external cookbook overrides
default[:nodejs][:version]                    = '0.10.32'
default[:nodejs][:checksum_linux_x64]         = '621777798ed9523a4ad1c4d934f94b7bc765871d769a014a53a4f1f7bcb5d5a7'
default[:nodejs][:dir]                        = '/usr'

default[:elasticsearch][:version]             = '1.3.4'
default[:elasticsearch][:allocated_memory]    = "#{(node[:memory][:total].to_i * 0.8).floor / 1024}m"
default[:elasticsearch][:plugin][:mandatory]  = %w(pelias-analysis)
default[:elasticsearch][:custom_config]       = {
  'threadpool.bulk.type'      => 'fixed',
  'threadpool.bulk.size'      => '2',
  'threadpool.bulk.wait_time' => '3s',
  'threadpool.bulk.queue'     => '500'
}
default[:elasticsearch][:plugins]             = {
  'pelias-analysis' => {
    'url' => "https://github.com/pelias/elasticsearch-plugin/blob/#{node[:elasticsearch][:version]}/pelias-analysis.zip?raw=true"
  }
}

default[:java][:install_flavor]               = 'openjdk'
default[:java][:jdk_version]                  = '7'
