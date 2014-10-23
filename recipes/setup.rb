#
# Cookbook Name:: pelias
# Recipe:: setup
#

log 'Installing system dependencies'
package 'build-essential'

include_recipe 'pelias::user'
include_recipe 'apt::default'
include_recipe 'git::default'
include_recipe 'java::default'
include_recipe 'nodejs::nodejs_from_binary'

log 'Installing Elasticsearch'
include_recipe 'elasticsearch::default'
include_recipe 'elasticsearch::plugins'

# force an ES restart, since the cookbook defaults
#   to :delayed.
service 'elasticsearch' do
  action :restart
end

execute 'install bower' do
  command 'npm install bower -g'
  user    'root'
  not_if  'npm -g list bower'
end

directory node[:pelias][:basedir] do
  action    :create
  recursive true
  mode      0755
  owner     node[:pelias][:user][:name]
  group     node[:pelias][:user][:name]
end

directory "#{node[:pelias][:basedir]}/logs" do
  action  :create
  mode    0755
  owner   node[:pelias][:user][:name]
  group   node[:pelias][:user][:name]
end

# geonames
directory node[:pelias][:geonames][:data_dir] do
  owner  node[:pelias][:user][:name]
  group  node[:pelias][:user][:name]
  mode   0755
end

# quattroshapes
directory node[:pelias][:quattroshapes][:data_dir] do
  owner  node[:pelias][:user][:name]
  group  node[:pelias][:user][:name]
  mode   0755
end

# osm
directory node[:pelias][:osm][:data_dir] do
  owner  node[:pelias][:user][:name]
  group  node[:pelias][:user][:name]
  mode   0755
end

directory node[:pelias][:osm][:leveldb] do
  owner  node[:pelias][:user][:name]
  group  node[:pelias][:user][:name]
  mode   0755
end
