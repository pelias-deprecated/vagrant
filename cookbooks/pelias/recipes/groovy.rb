#
# Cookbook Name:: pelias
# Recipe:: groovy
#

directory node[:pelias][:elasticsearch_groovy][:basedir] do
  recursive true
  mode      0755
  owner     node[:elasticsearch][:user]
  group     node[:elasticsearch][:user]
end

deploy "#{node[:pelias][:elasticsearch_groovy][:basedir]}/pelias-scripts" do
  user        node[:elasticsearch][:user]
  repository  node[:pelias][:elasticsearch_groovy][:repository]
  revision    node[:pelias][:elasticsearch_groovy][:revision]
  migrate     false

  symlink_before_migrate.clear

  notifies :create, "link[#{node[:elasticsearch][:path][:conf]}/scripts]", :immediately
end

link "#{node[:elasticsearch][:path][:conf]}/scripts" do
  action  :nothing
  to      "#{node[:pelias][:elasticsearch_groovy][:basedir]}/pelias-scripts/current/scripts"
end
