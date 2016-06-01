#
# Cookbook Name:: pelias
# Recipe:: setup
#

# dependencies
include_recipe 'apt::default'
include_recipe 'java::default'
include_recipe 'nodejs::nodejs_from_binary'
include_recipe 'elasticsearch::default'
include_recipe 'elasticsearch::plugins'

package 'git'
package 'build-essential'

# need to start ES after the initial installation
execute 'service elasticsearch start' do
  not_if 'pgrep -f elasticsearch'
end

# user
include_recipe 'pelias::user'

# base/logs
directory node[:pelias][:basedir] do
  recursive true
  mode      0755
  owner     node[:pelias][:user][:name]
end

directory "#{node[:pelias][:basedir]}/logs" do
  mode    0755
  owner   node[:pelias][:user][:name]
end

# geonames
directory node[:pelias][:geonames][:data_dir] do
  recursive true
  owner     node[:pelias][:user][:name]
  mode      0755
end

# osm
directory node[:pelias][:osm][:data_dir] do
  recursive true
  owner     node[:pelias][:user][:name]
  mode      0755
end

directory node[:pelias][:osm][:leveldb] do
  recursive true
  owner  node[:pelias][:user][:name]
  mode   0755
end

# address deduper
directory node[:pelias][:address_deduper][:leveldb] do
  recursive true
  owner     node[:pelias][:user][:name]
  mode      0755
end
