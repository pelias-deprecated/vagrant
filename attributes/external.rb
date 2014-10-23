# external cookbook overrides
#

# nodejs
default[:nodejs][:version]            = '0.10.32'
default[:nodejs][:checksum_linux_x64] = '621777798ed9523a4ad1c4d934f94b7bc765871d769a014a53a4f1f7bcb5d5a7'
default[:nodejs][:dir]                = '/usr'

# elasticsearch
default[:elasticsearch][:version]             = '1.3.4'
default[:elasticsearch][:skip_restart]        = true
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

# java
default[:java][:install_flavor]                         = 'oracle'
default[:java][:jdk_version]                            = '7'
default[:java][:oracle][:accept_oracle_download_terms]  = true
default[:java][:jdk][:'7'][:x86_64][:url]               = 'http://download.oracle.com/otn-pub/java/jdk/7u51-b13/jdk-7u51-linux-x64.tar.gz'
default[:java][:jdk][:'7'][:x86_64][:checksum]          = '764f96c4b078b80adaa5983e75470ff2'
