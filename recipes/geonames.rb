#
# Cookbook Name:: pelias
# Recipe:: geonames
#
# Copyright 2013, Mapzen
#
# All rights reserved - Do Not Redistribute
#

deploy "#{node[:pelias][:basedir]}/pelias-geonames" do
  user        node[:pelias][:user][:name]
  repository  node[:pelias][:geonames][:repository]
  revision    node[:pelias][:geonames][:revision]
  migrate     false

  symlink_before_migrate.clear
  create_dirs_before_symlink %w(tmp public config deploy)

  notifies :run, 'execute[npm install pelias-geonames]', :immediately
  # notifies :run, 'execute[download geonames]', :immediately
  notifies :run, 'execute[load geonames]', :immediately
end

execute 'npm install pelias-geonames' do
  action  :nothing
  user    node[:pelias][:user][:name]
  command 'npm install'
  cwd     "#{node[:pelias][:basedir]}/pelias-geonames/current"
  environment('HOME' => node[:pelias][:user][:home])
  only_if { node[:pelias][:geonames][:index_data] == true }
end

# execute 'download geonames' do
#  action  :nothing
#  user    node[:pelias][:user][:name]
#  command "./bin/pelias-geonames -d all >#{node[:pelias][:basedir]}/logs/geonames_download.log 2>&1"
#  cwd     "#{node[:pelias][:basedir]}/pelias-geonames/current"
#  only_if { node[:pelias][:geonames][:index_data] == true && !File.exist?('data/allCountries.zip') }
# end

log "Commencing load of geonames into Elasticsearch. To follow along: vagrant ssh && tail -f #{node[:pelias][:basedir]}/logs/geonames.log" if node[:pelias][:geonames][:index_data] == true
execute 'load geonames' do
  action  :nothing
  user    node[:pelias][:user][:name]
  command "./bin/pelias-geonames -i all >#{node[:pelias][:basedir]}/logs/geonames.log 2>&1"
  cwd     "#{node[:pelias][:basedir]}/pelias-geonames/current"
  timeout node[:pelias][:geonames][:timeout]
  environment(
    'HOME' => node[:pelias][:user][:home],
    'PELIAS_CONFIG' => "#{node[:pelias][:cfg_dir]}/#{node[:pelias][:cfg_file]}"
  )
  only_if { node[:pelias][:geonames][:index_data] == true }
end
