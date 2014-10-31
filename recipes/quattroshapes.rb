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
  only_if { node[:pelias][:quattroshapes][:index_data] == true && !::File.directory?("#{node[:pelias][:basedir]}/quattroshapes-data" }
end

execute 'npm install quattroshapes-pipeline' do
  action  :nothing
  user    node[:pelias][:user][:name]
  command 'npm install'
  cwd     "#{node[:pelias][:basedir]}/quattroshapes-pipeline/current"
  environment('HOME' => node[:pelias][:user][:home])
end

ark 'quattroshapes-data' do
  action            :put
  owner             node[:pelias][:user][:name]
  url               node[:pelias][:quattroshapes][:data_url]
  checksum          node[:pelias][:quattroshapes][:checksum]
  path              node[:pelias][:basedir]
  notifies          :write, 'log[log quattroshapes data load]', :immediately
  only_if { node[:pelias][:quattroshapes][:index_data] == true && !::File.directory?("#{node[:pelias][:basedir]}/quattroshapes-data") }
end

log 'log quattroshapes data load' do
  action  :nothing
  message "Beginning load of Quattroshapes data into Elasticsearch. See #{node[:pelias][:basedir]}/logs."
end

node[:pelias][:quattroshapes][:types].each do |type|
  execute "load quattroshapes #{type}" do
    action      :nothing
    user        node[:pelias][:user][:name]
    command     "node example/runme.js #{type} >#{node[:pelias][:basedir]}/logs/quattroshapes_#{type}.out 2>#{node[:pelias][:basedir]}/logs/quattroshapes_#{type}.err"
    cwd         "#{node[:pelias][:basedir]}/quattroshapes-pipeline/current"
    timeout     node[:pelias][:quattroshapes][:timeout]
    subscribes  :run, 'ark[quattroshapes-data]', :immediately
    environment('PELIAS_CONFIG' => "#{node[:pelias][:cfg_dir]}/#{node[:pelias][:cfg_file]}")
  end
end
