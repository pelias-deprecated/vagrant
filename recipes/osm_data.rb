#
# Cookbook Name:: pelias
# Recipe:: osm_data
#

# override tempfile location so the data download
#   temp file goes somewhere with enough space
ENV['TMP'] = node[:pelias][:osm_data][:basedir]

# fail if someone tries to pull something other than
#   a pbf data file
fail if node[:pelias][:osm_data][:file] !~ /\.pbf$/

remote_file "#{node[:pelias][:osm_data][:basedir]}/#{node[:pelias][:osm_data][:file]}" do
  action  :create
  source  node[:pelias][:osm_data][:url]
  mode    0644
  backup  false
  only_if { node[:pelias][:osm][:index_data] == true }
end
