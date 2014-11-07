require 'spec_helper'

describe 'pelias::setup' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }
  before do
    stub_command('pgrep -f elasticsearch').and_return(false)
  end

  it 'should install build-essential' do
    expect(chef_run).to install_package 'build-essential'
  end

  %w(
    pelias::user
    apt::default
    git::default
    java::default
    nodejs::nodejs_from_binary
    elasticsearch::default
    elasticsearch::plugins
  ).each do |r|
    it "should include recipe #{r}" do
      expect(chef_run).to include_recipe r
    end
  end

  it 'should start elasticsearch' do
    expect(chef_run).to run_execute 'service elasticsearch start'
  end

  %w(
    /opt/pelias
    /opt/pelias/logs
    /opt/pelias/data/geonames
    /opt/pelias/data/quattroshapes
    /opt/pelias/data/osm
    /opt/pelias/leveldb
  ).each do |dir|
    it "it should create #{dir}" do
      expect(chef_run).to create_directory(dir).with(
        owner:  'pelias',
        mode:   0755
      )
    end
  end

end
