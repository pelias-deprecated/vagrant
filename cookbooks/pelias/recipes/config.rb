#
# Cookbook Name:: pelias
# Recipe:: config
#

directory node[:pelias][:cfg_dir] do
  recursive true
  owner     node[:pelias][:user][:name]
  group     node[:pelias][:user][:name]
  mode      0755
end

directory node[:pelias][:esclient][:logdir] do
  recursive true
  owner     node[:pelias][:user][:name]
  group     node[:pelias][:user][:name]
  mode      0755
end

template "#{node[:pelias][:cfg_dir]}/#{node[:pelias][:cfg_file]}" do
  source  "#{node[:pelias][:cfg_file]}.erb"
  mode    0644
  variables(osm_data_file: '')
end
