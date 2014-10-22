#
# Cookbook Name:: pelias
# Recipe:: api_deploy
#

# deploy
#
deploy node[:pelias][:api][:deploy_to] do
  user      node[:pelias][:user][:name]
  repo      node[:pelias][:api][:repository]
  revision  node[:pelias][:api][:revision]
  migrate   false

  create_dirs_before_symlink %w(tmp public config deploy)
  symlink_before_migrate.clear

  notifies :run,     'execute[install-bower]',        :immediately
  notifies :run,     'execute[install-pelias-bower]', :immediately
  notifies :run,     'execute[install-pelias-npm]',   :immediately
  notifies :restart, 'runit_service[pelias-api]', :delayed
end

execute 'install-bower' do
  action  :nothing
  command 'npm install bower -g'
  user    'root'
  cwd     "#{node[:pelias][:api][:deploy_to]}/current"
  not_if  'npm -g list bower'
end

execute 'install-pelias-bower' do
  action  :nothing
  command 'bower install --config.interactive=false && npm install'
  user    node[:pelias][:user][:name]
  cwd     "#{node[:pelias][:api][:deploy_to]}/current"
  environment('HOME' => "#{node[:pelias][:api][:deploy_to]}/shared")
end

execute 'install-pelias-npm' do
  action  :nothing
  command 'npm install'
  user    node[:pelias][:user][:name]
  cwd     "#{node[:pelias][:api][:deploy_to]}/current"
  environment('HOME' => "#{node[:pelias][:api][:deploy_to]}/shared")
end

include_recipe 'pelias::api_service'
