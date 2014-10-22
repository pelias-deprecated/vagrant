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
  only_if { node[:pelias][:geonames][:index_data] == true }
end

execute 'npm install pelias-geonames' do
  action  :nothing
  user    node[:pelias][:user][:name]
  command 'npm install'
  cwd     "#{node[:pelias][:basedir]}/pelias-geonames/current"
  environment('HOME' => node[:pelias][:user][:home])
  only_if { node[:pelias][:geonames][:index_data] == true }
end

node[:pelias][:geonames][:country_codes].each do |country|
  log "Commencing load of geonames for #{country}into Elasticsearch. To follow along: vagrant ssh && tail -f #{node[:pelias][:basedir]}/logs/geonames_#{country}.log" if node[:pelias][:geonames][:index_data] == true
  execute "load geonames for #{country}" do
    user    node[:pelias][:user][:name]
    command "./bin/pelias-geonames -i #{country} >#{node[:pelias][:basedir]}/logs/geonames_#{country}.log 2>&1"
    cwd     "#{node[:pelias][:basedir]}/pelias-geonames/current"
    timeout node[:pelias][:geonames][:timeout]
    environment(
      'HOME' => node[:pelias][:user][:home],
      'PELIAS_CONFIG' => "#{node[:pelias][:cfg_dir]}/#{node[:pelias][:cfg_file]}"
    )
    only_if { node[:pelias][:geonames][:index_data] == true }
  end
end
