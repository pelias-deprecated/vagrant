#
# Cookbook Name:: pelias
# Recipe:: _all_quattro_data
#

url = node[:pelias][:quattroshapes][:data_url].split('alpha3').first + 'quattroshapes-simplified.tar.gz'
remote_file "#{node[:pelias][:quattroshapes][:data_dir]}/quattroshapes-simplified.tar.gz" do
  action    :create_if_missing
  source    url
  mode      0644
  backup    false
  notifies  :run, 'execute[extract quattroshapes]', :immediately
end

execute 'extract quattroshapes' do
  action  :nothing
  user    node[:pelias][:user][:name]
  command 'tar zxf quattroshapes-simplified.tar.gz --strip-components=1'
  cwd     node[:pelias][:quattroshapes][:data_dir]
end
