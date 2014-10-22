#
# Cookbook Name:: pelias
# Recipe:: quattroshapes
#

directory node[:pelias][:quattroshapes][:data_dir] do
  owner  node[:pelias][:user][:name]
  group  node[:pelias][:user][:name]
  mode   0755
end

deploy "#{node[:pelias][:basedir]}/quattroshapes-pipeline" do
  user        node[:pelias][:user][:name]
  repository  node[:pelias][:quattroshapes][:repository]
  revision    node[:pelias][:quattroshapes][:revision]
  migrate     false

  symlink_before_migrate.clear
  create_dirs_before_symlink %w(tmp public config deploy)

  notifies :run, 'execute[npm install quattroshapes-pipeline]', :immediately
  notifies :run, 'remote_file[download quattroshapes]',         :immediately
  only_if { node[:pelias][:quattroshapes][:index_data] == true }
end

execute 'npm install quattroshapes-pipeline' do
  action  :nothing
  user    node[:pelias][:user][:name]
  command 'npm install'
  cwd     "#{node[:pelias][:basedir]}/quattroshapes-pipeline/current"
  environment('HOME' => node[:pelias][:user][:home])
end

remote_file 'download quattroshapes' do
  action    :nothing
  backup    false
  path      "#{node[:pelias][:basedir]}/#{node[:pelias][:quattroshapes][:file_name]}"
  source    node[:pelias][:quattroshapes][:data_url]
  notifies  :run, 'execute[extract quattroshapes data]', :immediately
  only_if { node[:pelias][:quattroshapes][:index_data] == true && !::File.exist?("#{node[:pelias][:basedir]}/#{node[:pelias][:quattroshapes][:file_name]}") }
end

execute 'extract quattroshapes data' do
  action  :nothing
  user    node[:pelias][:user][:name]
  cwd     node[:pelias][:basedir]
  command "tar zxf #{node[:pelias][:quattroshapes][:file_name]} -C #{node[:pelias][:quattroshapes][:data_dir]} --strip-components=1"
end

node[:pelias][:quattroshapes][:types].each do |type|
  execute "load quattroshapes #{type}" do
    action      :run
    user        node[:pelias][:user][:name]
    command     "node example/runme.js #{type} >#{node[:pelias][:basedir]}/logs/quattroshapes_#{type}.log 2>&1"
    cwd         "#{node[:pelias][:basedir]}/quattroshapes-pipeline/current"
    timeout     node[:pelias][:quattroshapes][:timeout]
    only_if     { node[:pelias][:quattroshapes][:index_data] == true }
    subscribes  :run, 'execute[extract quattroshapes data]', :immediately
    environment('PELIAS_CONFIG' => "#{node[:pelias][:cfg_dir]}/#{node[:pelias][:cfg_file]}")
  end
end

# snapshot
es_host = node[:opsworks][:layers][:elasticsearch][:instances].keys.first
stack   = node[:opsworks][:stack][:name].gsub('::', '_')

execute 'create quattroshapes snapshot repo' do
  command "curl -XPUT \"http://#{es_host}:9200/_snapshot/quattroshapes_snapshot\" -d \'{
  \"type\": \"s3\",
    \"settings\": {
      \"bucket\": \"mapzen.backups-#{node[:opsworks][:instance][:region]}\",
      \"base_path\": \"#{node[:mapzen][:environment]}/#{stack}/quattroshapes\"
    }
  }\'"
  only_if { node[:pelias][:quattroshapes][:index_data] == true && node[:pelias][:worker][:snapshot_quattroshapes] == true }
end

execute 'snapshot quattroshapes' do
  command "curl -XPUT \"http://#{es_host}:9200/_snapshot/quattroshapes_snapshot/quattroshapes_snapshot_latest?wait_for_completion=true\""
  timeout 21_600
  only_if { node[:pelias][:quattroshapes][:index_data] == true && node[:pelias][:worker][:snapshot_quattroshapes] == true }
end

