#
# Cookbook Name:: pelias
# Recipe:: geonames
#

deploy "#{node[:pelias][:basedir]}/geonames" do
  user        node[:pelias][:user][:name]
  repository  node[:pelias][:geonames][:repository]
  revision    node[:pelias][:geonames][:revision]
  migrate     false

  symlink_before_migrate.clear

  notifies :run, 'execute[npm install geonames]', :immediately
  only_if { node[:pelias][:geonames][:index_data] == true }
end

execute 'npm install geonames' do
  action  :nothing
  user    node[:pelias][:user][:name]
  command 'npm install'
  cwd     "#{node[:pelias][:basedir]}/geonames/current"
  environment('HOME' => node[:pelias][:user][:home])
end

node[:pelias][:geonames][:alpha2_country_codes].each do |country|
  remote_file "#{node[:pelias][:geonames][:data_dir]}/#{country}.zip" do
    action    :create_if_missing
    source    "#{node[:pelias][:geonames][:data_url]}/#{country}.zip"
    owner     node[:pelias][:user][:name]
    mode      0644
    backup    false
    notifies  :write, "log[log geonames load for #{country}]", :immediately
    notifies  :run,   "execute[load geonames for #{country}]", :immediately
    only_if   { node[:pelias][:geonames][:index_data] == true }
  end

  log "log geonames load for #{country}" do
    action  :nothing
    message "Beginning load of Geonames data into Elasticsearch for #{country}. Log: #{node[:pelias][:basedir]}/logs/geonames_#{country}.{out,err}"
  end

  execute "load geonames for #{country}" do
    action  :nothing
    user    node[:pelias][:user][:name]
    command <<-EOH
      ./bin/pelias-geonames -i #{country} \
        >#{node[:pelias][:basedir]}/logs/geonames_#{country}.out \
        2>#{node[:pelias][:basedir]}/logs/geonames_#{country}.err
    EOH
    cwd     "#{node[:pelias][:basedir]}/geonames/current"
    timeout node[:pelias][:geonames][:timeout]
    environment(
      'HOME' => node[:pelias][:user][:home],
      'PELIAS_CONFIG' => "#{node[:pelias][:cfg_dir]}/#{node[:pelias][:cfg_file]}"
    )
  end
end
