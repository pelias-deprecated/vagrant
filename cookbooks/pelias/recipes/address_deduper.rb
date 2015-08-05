#
# Cookbook Name:: pelias
# Recipe:: address_deduper
#

include_recipe 'pelias::_address_deduper_service'

execute 'chown leveldb dir' do
  command "chown -R #{node[:pelias][:user][:name]}:#{node[:pelias][:user][:name]} #{node[:pelias][:basedir]}/leveldb"
end

# requirements
package 'unzip'
package 'python-pip'
package 'python-dev'

git "#{node[:pelias][:basedir]}/address_deduper" do
  user        node[:pelias][:user][:name]
  repository  node[:pelias][:address_deduper][:repository]
  revision    node[:pelias][:address_deduper][:revision]
  notifies    :run,  'execute[install address deduper pip requirements]', :immediately
  notifies    :kill, 'runit_service[pelias-address-deduper]',             :immediately
end

execute 'install address deduper pip requirements' do
  action  :nothing
  cwd     "#{node[:pelias][:basedir]}/address_deduper"
  command 'pip install -U -r requirements.txt'
end
