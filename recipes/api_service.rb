#
# Cookbook Name:: pelias
# Recipe:: api_service
#

include_recipe 'runit::default'

runit_service 'pelias-api' do
  action          :enable
  log             true
  default_logger  true
end
