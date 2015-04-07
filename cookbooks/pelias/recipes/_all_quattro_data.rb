#
# Cookbook Name:: pelias
# Recipe:: _all_quattro_data
#

url = node[:pelias][:quattroshapes][:data_url].split('alpha3').first + 'quattroshapes-simplified.tar.gz'

execute "wget -O quattroshapes-simplified.tar.gz #{url}" do
  user      node[:pelias][:user][:name]
  cwd       node[:pelias][:quattroshapes][:data_dir]
  notifies  :run, 'execute[extract quattroshapes]', :immediately
  not_if    { ::File.exist? "#{node[:pelias][:quattroshapes][:data_dir]}/quattroshapes-simplified.tar.gz" }
end

execute 'extract quattroshapes' do
  action  :nothing
  user    node[:pelias][:user][:name]
  command 'tar zxf quattroshapes-simplified.tar.gz --strip-components=1'
  cwd     node[:pelias][:quattroshapes][:data_dir]
end
