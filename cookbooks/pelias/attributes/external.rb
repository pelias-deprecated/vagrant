# external cookbook overrides
#

# nodejs
default[:nodejs][:version]                      = '4.4.7'
default[:nodejs][:binary][:checksum]            = '5ad10465cc9d837c1fda8db0fd1bdc1a4ce823dd6afbc533ac2127e6a9a64133'

# elasticsearch
default[:elasticsearch][:version]               = '2.3.3'

# java
default[:java][:ark_retries]                            = 2
default[:java][:ark_retry_delay]                        = 3
default[:java][:ark_timeout]                            = 300
default[:java][:install_flavor]                         = 'oracle'
default[:java][:jdk_version]                            = '8'
default[:java][:oracle][:accept_oracle_download_terms]  = true
default[:java][:jdk][:'8'][:x86_64][:checksum]          = '6cb35916c59762c1ea6acdb275f93a94'
default[:java][:jdk][:'8'][:x86_64][:url]               = 'http://download.oracle.com/otn-pub/java/jdk/8u45-b14/jre-8u45-linux-x64.tar.gz'
