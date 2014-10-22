#
# Cookbook Name:: pelias
# Recipe:: default
#

include_recipe 'apt::default'
include_recipe 'git::default'
include_recipe 'java::default'

include_recipe 'elasticsearch::default'
include_recipe 'elasticsearch::plugins'

# force an ES restart, since the cookbook defaults
#   to :delayed.
service 'elasticsearch' do
  action :restart
end

include_recipe 'pelias::user'
include_recipe 'nodejs::install_from_binary'

execute 'install-bower' do
  command 'npm install bower -g'
  user    'root'
  not_if  'npm -g list bower'
end

directory node[:pelias][:basedir] do
  action  :create
  mode    0755
  owner   node[:pelias][:user][:name]
  group   node[:pelias][:user][:name]
end

directory "#{node[:pelias][:basedir]}/logs" do
  action  :create
  mode    0755
  owner   node[:pelias][:user][:name]
  group   node[:pelias][:user][:name]
end

include_recipe 'pelias::config'
include_recipe 'pelias::index'
include_recipe 'pelias::geonames'
include_recipe 'pelias::osm'
include_recipe 'pelias::api'
