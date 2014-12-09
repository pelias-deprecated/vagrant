#
# Cookbook Name:: pelias
# Recipe:: api
#

git node[:pelias][:api][:deploy_to] do
  action      :sync
  user        node[:pelias][:user][:name]
  repository  node[:pelias][:api][:repository]
  revision    node[:pelias][:api][:revision]
  notifies    :run,     'execute[npm install pelias-api]',  :immediately
  notifies    :restart, 'runit_service[pelias-api]',        :delayed
end

execute 'npm install pelias-api' do
  action  :nothing
  command 'npm install'
  user    node[:pelias][:user][:name]
  cwd     node[:pelias][:api][:deploy_to]
  environment('HOME' => node[:pelias][:api][:deploy_to])
end

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
