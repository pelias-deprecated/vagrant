#
# Cookbook Name:: pelias
# Recipe:: default
#

%w(
  setup
  config
  schema
  geonames
  quattroshapes
  osm
  api
).each do |r|
  include_recipe "pelias::#{r}"
end
