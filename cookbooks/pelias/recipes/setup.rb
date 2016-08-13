#
# Cookbook Name:: pelias
# Recipe:: setup
#

# dependencies
include_recipe 'apt::default'
include_recipe 'java::default'
include_recipe 'nodejs::nodejs_from_binary'

package 'git'
package 'build-essential'

# need to start ES after the initial installation
include_recipe 'chef-sugar'
elasticsearch_user 'elasticsearch'
elasticsearch_install 'elasticsearch' do
  type node['elasticsearch']['install_type'].to_sym # since TK can't symbol.
end
elasticsearch_configure 'elasticsearch' do
    allocated_memory "#{(node[:memory][:total].to_i * 0.6).floor / 1024}m"
    configuration ({
      'cluster.name' => 'pelias',
      'network.host' => ['_eth0_', '_local_'],
      'threadpool.bulk.type'      => 'fixed',
      'threadpool.bulk.size'      => '4',
      'threadpool.bulk.wait_time' => '10s',
      'threadpool.bulk.queue'     => '1000',
      'index.refresh_interval'    => '30s',
    })
end
elasticsearch_plugin 'analysis-icu' do
  action :install
end
elasticsearch_service 'elasticsearch' do
  service_actions [:enable, :start]
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
