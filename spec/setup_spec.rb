require 'spec_helper'

describe 'pelias::setup' do
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

  it 'should notify to create the ES restart lockfile' do
    resource = chef_run.service('elasticsearch')
    expect(resource).to notify('file[/etc/.elasticsearch_initial_install.lock]').to(:create).immediately
  end

  it 'should define the es initial install lockfile' do
    resource = chef_run.file('/etc/.elasticsearch_initial_install.lock')
    expect(resource).to do_nothing
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
