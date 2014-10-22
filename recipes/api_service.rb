#
# Cookbook Name:: pelias
# Recipe:: api_service
#

include_recipe 'runit::default'

runit_service 'pelias-api' do
  action          [:enable, :start]
  log             true
  default_logger  true
  sv_timeout      60
  subscribes      :restart, "template[#{node[:pelias][:cfg_dir]}/#{node[:pelias][:cfg_file]}", :delayed
  env(
    'PELIAS_CONFIG' => "#{node[:pelias][:cfg_dir]}/#{node[:pelias][:cfg_file]}",
    'NODE_ENV'      => "#{node[:pelias][:node_env]}",
    'PORT'          => "#{node[:pelias][:api][:port]}"
  )
end
