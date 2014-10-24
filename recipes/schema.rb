#
# Cookbook Name:: pelias
# Recipe:: schema
#

deploy "#{node[:pelias][:basedir]}/pelias-schema" do
  user        node[:pelias][:user][:name]
  repository  node[:pelias][:schema][:repository]
  revision    node[:pelias][:schema][:revision]
  migrate     false

  symlink_before_migrate.clear
  create_dirs_before_symlink %w(tmp public config deploy)

  notifies :run, 'execute[npm install pelias-schema]', :immediately
  only_if { node[:pelias][:schema][:drop_index] == true || node[:pelias][:schema][:create_index] == true }
end

execute 'npm install pelias-schema' do
  action  :nothing
  user    node[:pelias][:user][:name]
  command 'npm install'
  cwd     "#{node[:pelias][:basedir]}/pelias-schema/current"
  environment('HOME' => node[:pelias][:user][:home])
end

execute 'node scripts/drop_index.js --force-yes' do
  user    node[:pelias][:user][:name]
  cwd     "#{node[:pelias][:basedir]}/pelias-schema/current"
  only_if { node[:pelias][:schema][:drop_index] == true }
  environment('PELIAS_CONFIG' => "#{node[:pelias][:cfg_dir]}/#{node[:pelias][:cfg_file]}")
end

# retry once in case ES is slow to start.
execute 'node scripts/create_index.js' do
  user            node[:pelias][:user][:name]
  cwd             "#{node[:pelias][:basedir]}/pelias-schema/current"
  retries         1
  retry_delay     15
  not_if  "curl -s 'localhost:9200/_cat/indices?v' | grep pelias"
  only_if { node[:pelias][:schema][:create_index] == true }
  environment('PELIAS_CONFIG' => "#{node[:pelias][:cfg_dir]}/#{node[:pelias][:cfg_file]}")
end
