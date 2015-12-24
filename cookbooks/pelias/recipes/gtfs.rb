#
# Cookbook Name:: pelias
# Recipe:: gtfs
#

deploy "#{node[:pelias][:basedir]}/gtfs" do
  user        node[:pelias][:user][:name]
  repository  node[:pelias][:gtfs][:repository]
  revision    node[:pelias][:gtfs][:revision]
  migrate     false

  symlink_before_migrate.clear

  notifies :run, 'execute[npm install gtfs]', :immediately
  only_if { node[:pelias][:gtfs][:index_data] == true }
end

execute 'npm install gtfs' do
  action :nothing
  user node[:pelias][:user][:name]
  command 'npm install'
  cwd "#{node[:pelias][:basedir]}/gtfs/current"
  environment(
    'HOME' => node[:pelias][:user][:home]
  )
  notifies :run, "execute[import gtfs data]", :immediately
end


execute 'import gtfs data' do
  action :nothing
  user node[:pelias][:user][:name]
  cwd "#{node[:pelias][:basedir]}/gtfs/current"
  command 'node import.js'
  environment(
    'PELIAS_CONFIG' => "#{node[:pelias][:cfg_dir]}/#{node[:pelias][:cfg_file]}"
  )
end
