#
# Cookbook Name:: pelias
# Recipe:: quattroshapes
#

deploy "#{node[:pelias][:basedir]}/quattroshapes" do
  user        node[:pelias][:user][:name]
  repository  node[:pelias][:quattroshapes][:repository]
  revision    node[:pelias][:quattroshapes][:revision]
  migrate     false

  symlink_before_migrate.clear

  notifies :run, 'execute[npm install quattroshapes]', :immediately
  only_if { node[:pelias][:quattroshapes][:index_data] == true }
end

execute 'npm install quattroshapes' do
  action  :nothing
  user    node[:pelias][:user][:name]
  command 'npm install'
  cwd     "#{node[:pelias][:basedir]}/quattroshapes/current"
  environment('HOME' => node[:pelias][:user][:home])
end

remote_file "#{node[:pelias][:quattroshapes][:data_dir]}/quattroshapes-simplified.tar.gz" do
  action    :create_if_missing
  source    "#{node[:pelias][:quattroshapes][:data_url]}/quattroshapes-simplified.tar.gz"
  mode      0644
  backup    false
  notifies  :run, 'execute[extract quattroshapes]', :immediately
  only_if   { node[:pelias][:quattroshapes][:index_data] == true }
end

execute 'extract quattroshapes' do
  action  :nothing
  user    node[:pelias][:user][:name]
  command 'tar zxf quattroshapes-simplified.tar.gz --strip-components=1'
  cwd     node[:pelias][:quattroshapes][:data_dir]
end

node[:pelias][:quattroshapes][:alpha3_country_codes].each do |country|
  node[:pelias][:quattroshapes][:types].each do |type|
    execute "load quattroshapes for #{country} #{type}" do
      action      :nothing
      user        node[:pelias][:user][:name]
      command     <<-EOH
        node example/runme.js #{type} #{country} \
          >#{node[:pelias][:basedir]}/logs/quattroshapes_#{country}_#{type}.out \
          2>#{node[:pelias][:basedir]}/logs/quattroshapes_#{country}_#{type}.err
      EOH
      cwd         "#{node[:pelias][:basedir]}/quattroshapes/current"
      timeout     node[:pelias][:quattroshapes][:timeout]
      subscribes  :run, 'execute[extract quattroshapes]', :immediately
      environment(
        'PELIAS_CONFIG' => "#{node[:pelias][:cfg_dir]}/#{node[:pelias][:cfg_file]}"
      )
    end
  end
end
