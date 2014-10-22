#
# Cookbook Name:: pelias
# Recipe:: osm
#

include_recipe 'pelias::osm_data'

deploy "#{node[:pelias][:basedir]}/pelias-osm" do
  user        node[:pelias][:user][:name]
  repository  node[:pelias][:osm][:repository]
  revision    node[:pelias][:osm][:revision]
  migrate     false

  symlink_before_migrate.clear
  create_dirs_before_symlink %w(tmp public config deploy)

  notifies :run, 'execute[npm install pelias-osm]', :immediately
  only_if { node[:pelias][:osm][:index_data] == true }
end

execute 'npm install pelias-osm' do
  action  :nothing
  user    node[:pelias][:user][:name]
  command 'npm install'
  cwd     "#{node[:pelias][:basedir]}/pelias-osm/current"
  environment('HOME' => node[:pelias][:user][:home])
  only_if { node[:pelias][:osm][:index_data] == true }
end

# triggered by the data download
#   TODO: hash of extracts/urls to install
log "Commencing load of OSM data into Elasticsearch. To follow along: vagrant ssh && tail -f #{node[:pelias][:basedir]}/logs/osm.log" if node[:pelias][:osm][:index_data] == true
execute 'load osm' do
  action  :nothing
  user    node[:pelias][:user][:name]
  command "node index.js >#{node[:pelias][:basedir]}/logs/osm.log 2>&1"
  cwd     "#{node[:pelias][:basedir]}/pelias-osm/current"
  timeout node[:pelias][:osm][:timeout]
  environment(
    'HOME' => node[:pelias][:user][:home],
    'PELIAS_CONFIG' => "#{node[:pelias][:cfg_dir]}/#{node[:pelias][:cfg_file]}"
  )
end
