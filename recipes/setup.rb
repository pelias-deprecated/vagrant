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

# need to start ES after the initial installation, but
#   not after.
file '/etc/.elasticsearch_initial_install.lock' do
  action :nothing
end

service 'elasticsearch' do
  action   :start
  not_if   { ::File.exist?('/etc/.elasticsearch_initial_install.lock') }
  notifies :create, 'file[/etc/.elasticsearch_initial_install.lock]', :immediately
end

# base/logs
directory node[:pelias][:basedir] do
  action    :create
  recursive true
  mode      0755
  owner     node[:pelias][:user][:name]
end

directory "#{node[:pelias][:basedir]}/logs" do
  action  :create
  mode    0755
  owner   node[:pelias][:user][:name]
end

# geonames
directory node[:pelias][:geonames][:data_dir] do
  owner  node[:pelias][:user][:name]
  mode   0755
end

# osm
directory node[:pelias][:osm][:data_dir] do
  owner  node[:pelias][:user][:name]
  mode   0755
end

directory node[:pelias][:osm][:leveldb] do
  owner  node[:pelias][:user][:name]
  mode   0755
end
