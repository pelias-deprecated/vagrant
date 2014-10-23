#
# Cookbook Name:: pelias
# Recipe:: default
#

%w(
  setup
  config
  index
  geonames
  quattroshapes
  osm
  api
).each do |r|
  include_recipe "pelias::#{r}"
end
