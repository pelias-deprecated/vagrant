#
# Cookbook Name:: pelias
# Recipe:: openaddresses
#

include_recipe 'pelias::address_deduper'

directory node[:pelias][:openaddresses][:data_dir] do
  owner     node[:pelias][:user][:name]
  group     node[:pelias][:user][:name]
  mode      0755
  recursive true
end

deploy "#{node[:pelias][:basedir]}/openaddresses" do
  user        node[:pelias][:user][:name]
  repository  node[:pelias][:openaddresses][:repository]
  revision    node[:pelias][:openaddresses][:revision]
  migrate     false

  symlink_before_migrate.clear

  notifies :run,  'execute[purge address deduper datastore]', :immediately
  notifies :kill, 'runit_service[pelias-address-deduper]',    :immediately
  notifies :run,  'execute[npm install openaddresses]',       :immediately
  only_if  { node[:pelias][:openaddresses][:index_data] == true }
end

execute 'purge address deduper datastore' do
  action  :nothing
  user    node[:pelias][:user][:name]
  command "find #{node[:pelias][:address_deduper][:leveldb]} -type f -exec rm {} \\; || true"
end

execute 'npm install openaddresses' do
  action  :nothing
  user    node[:pelias][:user][:name]
  command 'npm install'
  cwd     "#{node[:pelias][:basedir]}/openaddresses/current"
  environment(
    'HOME' => node[:pelias][:user][:home]
  )
end

if node[:pelias][:openaddresses][:data_files] == []
  remote_file "#{node[:pelias][:openaddresses][:data_dir]}/#{node[:pelias][:openaddresses][:full_file_name]}" do
    action      :create
    backup      false
    source      node[:pelias][:openaddresses][:full_data_url]
    owner       node[:pelias][:user][:name]
    retries     2
    retry_delay 60
    notifies    :run, 'execute[extract openaddresses data]', :immediately
    only_if     { node[:pelias][:openaddresses][:index_data] == true }
  end

  execute 'extract openaddresses data' do
    action  :nothing
    user    node[:pelias][:user][:name]
    cwd     node[:pelias][:openaddresses][:data_dir]
    command "unzip -o #{node[:pelias][:openaddresses][:full_file_name]} -d #{node[:pelias][:openaddresses][:data_dir]}"
    notifies    :run, 'execute[import openaddresses data]', :immediately
  end
else
  node[:pelias][:openaddresses][:data_files].each do |data_file|
    remote_file "#{node[:pelias][:openaddresses][:data_dir]}/#{data_file}.zip" do
      action    :create_if_missing
      source    "#{node[:pelias][:openaddresses][:data_path]}/#{data_file}.zip"
      owner     node[:pelias][:user][:name]
      retries     2
      retry_delay 60
      backup    false
      notifies    :run, "execute[extract openaddresses data for #{data_file}]", :immediately
      only_if     { node[:pelias][:openaddresses][:index_data] == true }
    end

    execute "extract openaddresses data for #{data_file}" do
      action  :nothing
      user    node[:pelias][:user][:name]
      cwd     node[:pelias][:openaddresses][:data_dir]
      command "unzip -o #{data_file}.zip -d #{node[:pelias][:openaddresses][:data_dir]}"
      notifies    :run, 'execute[import openaddresses data]', :delayed
    end
  end
end

execute 'import openaddresses data' do
  action  :nothing
  user    node[:pelias][:user][:name]
  cwd     "#{node[:pelias][:basedir]}/openaddresses/current"
  command 'node import.js'
  environment(
    'PELIAS_CONFIG' => "#{node[:pelias][:cfg_dir]}/#{node[:pelias][:cfg_file]}"
  )
end
