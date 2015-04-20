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
  create_dirs_before_symlink %w(tmp public config deploy)

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

# download and load, using the downloaded file
#   as an additional guard against a re-load.
#
node[:pelias][:geonames][:alpha2_country_codes].each do |country|
  execute "download geonames for #{country}" do
    user    node[:pelias][:user][:name]
    command "./bin/pelias-geonames -d #{country} >#{node[:pelias][:basedir]}/logs/geonames_#{country}.out 2>#{node[:pelias][:basedir]}/logs/geonames_#{country}.err"
    cwd     "#{node[:pelias][:basedir]}/geonames/current"
    timeout node[:pelias][:geonames][:timeout]
    environment(
      'HOME' => node[:pelias][:user][:home],
      'PELIAS_CONFIG' => "#{node[:pelias][:cfg_dir]}/#{node[:pelias][:cfg_file]}"
    )
    notifies :write, "log[log geonames load for #{country}]", :immediately
    notifies :run,   "execute[load geonames for #{country}]", :immediately
    only_if { node[:pelias][:geonames][:index_data] == true && !::File.exist?("#{node[:pelias][:geonames][:data_dir]}/#{country}.zip") }
  end

  log "log geonames load for #{country}" do
    action  :nothing
    message "Beginning load of Geonames data into Elasticsearch for #{country}. Log: #{node[:pelias][:basedir]}/logs/geonames_#{country}.{out,err}"
  end

  execute "load geonames for #{country}" do
    action  :nothing
    user    node[:pelias][:user][:name]
    command "./bin/pelias-geonames -i #{country} >#{node[:pelias][:basedir]}/logs/geonames_#{country}.out 2>#{node[:pelias][:basedir]}/logs/geonames_#{country}.err"
    cwd     "#{node[:pelias][:basedir]}/geonames/current"
    timeout node[:pelias][:geonames][:timeout]
    environment(
      'HOME' => node[:pelias][:user][:home],
      'PELIAS_CONFIG' => "#{node[:pelias][:cfg_dir]}/#{node[:pelias][:cfg_file]}"
    )
  end
end
