#
# Cookbook Name:: pelias
# Recipe:: osm
#

deploy "#{node[:pelias][:basedir]}/osm" do
  user        node[:pelias][:user][:name]
  repository  node[:pelias][:osm][:repository]
  revision    node[:pelias][:osm][:revision]
  migrate     false

  symlink_before_migrate.clear

  notifies :run, 'execute[npm install osm]', :immediately
  only_if { node[:pelias][:osm][:index_data] == true }
end

execute 'npm install osm' do
  action  :nothing
  user    node[:pelias][:user][:name]
  command 'npm install'
  cwd     "#{node[:pelias][:basedir]}/osm/current"
  environment('HOME' => node[:pelias][:user][:home])
end

node[:pelias][:osm][:extracts].map do |name, url|
  # fail if someone tries to pull something other than
  #   a pbf data file
  data_file = url.split('/').last
  fail if data_file !~ /\.pbf$/

  # unique templates for each file we need to load (ugh)
  template "#{node[:pelias][:cfg_dir]}/#{name}_#{node[:pelias][:cfg_file]}" do
    source  "#{node[:pelias][:cfg_file]}.erb"
    mode    0644
    variables(osm_data_file: data_file)
    only_if { node[:pelias][:osm][:index_data] == true }
  end

  remote_file "#{node[:pelias][:osm][:data_dir]}/#{data_file}" do
    action    :create_if_missing
    source    url
    owner     node[:pelias][:user][:name]
    mode      0644
    backup    false
    notifies  :write, "log[log osm load #{name}]", :immediately
    notifies  :run,   "execute[load osm #{name}]", :immediately
    only_if   { node[:pelias][:osm][:index_data] == true }
  end

  log "log osm load #{name}" do
    action  :nothing
    message "Beginning load of OSM data into Elasticsearch for #{name}. Log: #{node[:pelias][:basedir]}/logs/osm_#{name}.{out,err}"
  end

  # triggered by the data download
  execute "load osm #{name}" do
    action  :nothing
    user    node[:pelias][:user][:name]
    command <<-EOH
      node index.js \
        >#{node[:pelias][:basedir]}/logs/osm_#{name}.out \
        2>#{node[:pelias][:basedir]}/logs/osm_#{name}.err
    EOH
    cwd     "#{node[:pelias][:basedir]}/osm/current"
    timeout node[:pelias][:osm][:timeout]
    environment(
      'HOME'                => node[:pelias][:user][:home],
      'PELIAS_CONFIG'       => "#{node[:pelias][:cfg_dir]}/#{name}_#{node[:pelias][:cfg_file]}"
    )
  end
end
