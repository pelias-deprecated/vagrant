require 'spec_helper'

describe 'pelias::default' do
  before do
    stub_command('npm -g list bower').and_return(true)
  end
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  %w(
    setup
    config
    index
    geonames
    quattroshapes
    osm
    api
  ).each do |r|
    it "should include the pelias::#{r} recipe" do
      expect(chef_run).to include_recipe "pelias::#{r}"
    end
  end
end
