require 'spec_helper'

describe 'pelias::default' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }
  before do
    stub_command('pgrep -f elasticsearch').and_return(true)
  end

  %w(
    setup
    config
    schema
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
