#
# Cookbook Name:: pelias
# Recipe:: _address_deduper_service
#

include_recipe 'runit::default'

runit_service 'pelias-address-deduper' do
  action          :enable
  finish          true
  log             true
  default_logger  true
  sv_timeout      60
  env(
    'DEDUPER_STORAGE_LEVELDB_DIR' => "#{node[:pelias][:address_deduper][:leveldb_dir]}"
  )
end
