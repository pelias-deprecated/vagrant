#
# Cookbook Name:: pelias
# Recipe:: api_deploy
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

include_recipe 'pelias::api_service'
