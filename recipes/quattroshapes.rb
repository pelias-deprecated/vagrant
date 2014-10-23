#
# Cookbook Name:: pelias
# Recipe:: quattroshapes
#

deploy "#{node[:pelias][:basedir]}/quattroshapes-pipeline" do
  user        node[:pelias][:user][:name]
  repository  node[:pelias][:quattroshapes][:repository]
  revision    node[:pelias][:quattroshapes][:revision]
  migrate     false

  symlink_before_migrate.clear
  create_dirs_before_symlink %w(tmp public config deploy)

  notifies :run, 'execute[npm install quattroshapes-pipeline]', :immediately
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
  action    :create_if_missing
  backup    false
  path      "#{node[:pelias][:basedir]}/#{node[:pelias][:quattroshapes][:file_name]}"
  source    node[:pelias][:quattroshapes][:data_url]
  notifies  :run, 'execute[extract quattroshapes data]', :immediately
  only_if { node[:pelias][:quattroshapes][:index_data] == true }
end

execute 'extract quattroshapes data' do
  action  :nothing
  user    node[:pelias][:user][:name]
  cwd     node[:pelias][:basedir]
  command "tar zxf #{node[:pelias][:quattroshapes][:file_name]} -C #{node[:pelias][:quattroshapes][:data_dir]} --strip-components=1"
end

node[:pelias][:quattroshapes][:types].each do |type|
  execute "load quattroshapes #{type}" do
    action      :nothing
    user        node[:pelias][:user][:name]
    command     "node example/runme.js #{type} >#{node[:pelias][:basedir]}/logs/quattroshapes_#{type}.log 2>&1"
    cwd         "#{node[:pelias][:basedir]}/quattroshapes-pipeline/current"
    timeout     node[:pelias][:quattroshapes][:timeout]
    subscribes  :run, 'execute[extract quattroshapes data]', :immediately
    environment('PELIAS_CONFIG' => "#{node[:pelias][:cfg_dir]}/#{node[:pelias][:cfg_file]}")
  end
end
