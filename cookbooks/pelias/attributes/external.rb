# external cookbook overrides
#

# nodejs
default[:nodejs][:version]                      = '0.10.36'
default[:nodejs][:checksum_linux_x64]           = '2bc13477684a9fe534bdc9d8f4a8caf6257a11953b57c42cad9b919ee259a0d5'
default[:nodejs][:dir]                          = '/usr'

# elasticsearch
default[:elasticsearch][:version]               = '1.5.0'
default[:elasticsearch][:filename]              = "elasticsearch-#{node[:elasticsearch][:version]}.tar.gz"
default[:elasticsearch][:download_url]          = [node[:elasticsearch][:host], node[:elasticsearch][:repository], node[:elasticsearch][:filename]].join('/')
default[:elasticsearch][:skip_restart]          = true
default[:elasticsearch][:bootstrap][:mlockall]  = false
default[:elasticsearch][:allocated_memory]      = "#{(node[:memory][:total].to_i * 0.6).floor / 1024}m"
default[:elasticsearch][:plugin][:mandatory]    = %w(pelias-analysis)
default[:elasticsearch][:custom_config]         = {
  'threadpool.bulk.type'      => 'fixed',
  'threadpool.bulk.size'      => '4',
  'threadpool.bulk.wait_time' => '10s',
  'threadpool.bulk.queue'     => '1000',
  'index.refresh_interval'    => '30s'
}
default[:elasticsearch][:plugins]               = {
  'pelias-analysis' => {
    'url' => 'https://github.com/pelias/elasticsearch-plugin/blob/1.3.4/pelias-analysis.zip?raw=true'
  }
}

# java
default[:java][:install_flavor]                         = 'oracle'
default[:java][:jdk_version]                            = '8'
default[:java][:oracle][:accept_oracle_download_terms]  = true
default[:java][:jdk][:'8'][:x86_64][:url]               = 'http://download.oracle.com/otn-pub/java/jdk/8u40-b26/jdk-8u40-linux-x64.tar.gz'
default[:java][:jdk][:'8'][:x86_64][:checksum]          = '3b3f74589539b8bbe5d78005e52f4f78'
