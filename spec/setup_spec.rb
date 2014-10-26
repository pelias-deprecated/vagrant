require 'spec_helper'

describe 'pelias::setup' do
  before do
    stub_command('npm -g list bower').and_return(true)
  end
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  it 'should log something' do
    expect(chef_run).to write_log 'Installing system dependencies'
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

  it 'should log something else' do
    expect(chef_run).to write_log 'Installing Elasticsearch'
  end

  it 'should restart elasticsearch' do
    expect(chef_run).to restart_service 'elasticsearch'
  end

  it 'should install bower' do
    stub_command('npm -g list bower').and_return(false)
    expect(chef_run).to run_execute('install bower').with(
      command: 'npm install bower -g',
      user:    'root'
    )
  end

  %w(
    /opt/pelias
    /opt/pelias/logs
    /opt/pelias/geonames-data
    /opt/pelias/osm-data
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
