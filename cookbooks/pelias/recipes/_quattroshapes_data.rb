#
# Cookbook Name:: pelias
# Recipe:: _osm_data
#

# override tempfile location so the planet download
#   temp file goes somewhere with enough space
ENV['TMP'] = node[:pelias][:quattroshapes][:data_dir]

directory node[:pelias][:quattroshapes][:data_dir] do
  owner     node[:pelias][:user][:name]
  group     node[:pelias][:user][:name]
  mode      0755
  recursive true
end

# always download the simplified data if we're called
remote_file "#{node[:pelias][:quattroshapes][:data_dir]}/quattroshapes-simplified.tar.gz" do
  action    :create
  backup    false
  source    "#{node[:pelias][:quattroshapes][:data_url]}/quattroshapes-simplified.tar.gz"
  owner     node[:pelias][:user][:name]
  retries   1
  notifies  :run, 'execute[extract quattroshapes]', :immediately
end

execute 'extract quattroshapes' do
  action  :nothing
  user    node[:pelias][:user][:name]
  cwd     node[:pelias][:quattroshapes][:data_dir]
  command 'tar zxf quattroshapes-simplified.tar.gz --strip-components=1'
end
