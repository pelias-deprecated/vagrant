#
# Cookbook Name:: pelias
# Recipe:: default
#

%w(
  setup
  config
  api
  schema
  openaddresses
  geonames
  osm
).each do |r|
  include_recipe "pelias::#{r}"
end
