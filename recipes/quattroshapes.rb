#
# Cookbook Name:: pelias
# Recipe:: quattroshapes
#

# skip deploying if we don't need to
node[:pelias][:quattroshapes][:alpha3_country_codes].each do |country|
  download = "#{node[:pelias][:quattroshapes][:data_dir]}/#{country}.tgz"
  next if File.exist?(download)
  node.set[:pelias][:quattroshapes][:shall_we_deploy] = true
  break
end

deploy "#{node[:pelias][:basedir]}/quattroshapes-pipeline" do
  user        node[:pelias][:user][:name]
  repository  node[:pelias][:quattroshapes][:repository]
  revision    node[:pelias][:quattroshapes][:revision]
  migrate     false

  symlink_before_migrate.clear
  create_dirs_before_symlink %w(tmp public config deploy)

  notifies :run, 'execute[npm install quattroshapes-pipeline]', :immediately
  only_if { node[:pelias][:quattroshapes][:index_data] == true && node[:pelias][:quattroshapes][:shall_we_deploy] == true }
end

execute 'npm install quattroshapes-pipeline' do
  action  :nothing
  user    node[:pelias][:user][:name]
  command 'npm install'
  cwd     "#{node[:pelias][:basedir]}/quattroshapes-pipeline/current"
  environment('HOME' => node[:pelias][:user][:home])
end

node[:pelias][:quattroshapes][:alpha3_country_codes].each do |country|
  # unique templates for each file we need to load (ugh)
  template "#{node[:pelias][:basedir]}/quattroshapes-pipeline/current/example/#{country}_index_quattroshapes.js" do
    source  'index_quattroshapes.js.erb'
    mode    0644
    variables(country: country)
    only_if { node[:pelias][:quattroshapes][:index_data] == true && node[:pelias][:quattroshapes][:shall_we_deploy] == true }
  end

  remote_file "#{node[:pelias][:quattroshapes][:data_dir]}/#{country}.tgz" do
    action    :create_if_missing
    source    "#{node[:pelias][:quattroshapes][:data_url]}/#{country}.tgz"
    mode      0644
    backup    false
    notifies  :run, "execute[extract quattroshapes for #{country}]", :immediately
    only_if { node[:pelias][:quattroshapes][:index_data] == true }
  end

  execute "extract quattroshapes for #{country}" do
    action  :nothing
    user    node[:pelias][:user][:name]
    command "tar zxf #{country}.tgz"
    cwd     node[:pelias][:quattroshapes][:data_dir]
  end

  node[:pelias][:quattroshapes][:types].each do |type|
    execute "load quattroshapes for #{country} #{type}" do
      action      :nothing
      user        node[:pelias][:user][:name]
      command     "node #{node[:pelias][:basedir]}/quattroshapes-pipeline/current/example/#{country}_index_quattroshapes.js #{type} >#{node[:pelias][:basedir]}/logs/quattroshapes_#{country}_#{type}.out 2>#{node[:pelias][:basedir]}/logs/quattroshapes_#{country}_#{type}.err"
      cwd         "#{node[:pelias][:basedir]}/quattroshapes-pipeline/current"
      timeout     node[:pelias][:quattroshapes][:timeout]
      subscribes  :run, "execute[extract quattroshapes for #{country}]", :immediately
      environment(
        'PELIAS_CONFIG' => "#{node[:pelias][:cfg_dir]}/#{node[:pelias][:cfg_file]}",
        'OSMIUM_POOL_THREADS' => node[:pelias][:osm][:osmium_threads]
      )
    end
  end
end
