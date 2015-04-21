# external cookbook overrides
#

# nodejs
default[:nodejs][:version]                      = '0.12.2'
default[:nodejs][:checksum_linux_x64]           = '4e1578efc2a2cc67651413a05ccc4c5d43f6b4329c599901c556f24d93cd0508'

# elasticsearch
default[:elasticsearch][:version]               = '1.5.1'
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
default[:java][:ark_retries]                            = 2
default[:java][:ark_retry_delay]                        = 3
default[:java][:ark_timeout]                            = 300
default[:java][:install_flavor]                         = 'oracle'
default[:java][:jdk_version]                            = '8'
default[:java][:oracle][:accept_oracle_download_terms]  = true
default[:java][:jdk][:'8'][:x86_64][:checksum]          = '6cb35916c59762c1ea6acdb275f93a94'
default[:java][:jdk][:'8'][:x86_64][:url]               = 'http://download.oracle.com/otn-pub/java/jdk/8u45-b14/jre-8u45-linux-x64.tar.gz'
