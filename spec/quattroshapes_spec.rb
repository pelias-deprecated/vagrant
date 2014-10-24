require 'spec_helper'

describe 'pelias::quattroshapes' do
  before do
    stub_command('npm -g list bower').and_return(true)
  end

  context 'with index_data = true' do
    let(:chef_run) do
      ChefSpec::Runner.new do |node|
        node.set[:pelias][:quattroshapes][:index_data]     = true
      end.converge(described_recipe)
    end

    it 'should deploy quattroshapes-pipeline' do
      expect(chef_run).to deploy_deploy('/opt/pelias/quattroshapes-pipeline').with(
        user:     'pelias',
        repo:     'https://github.com/pelias/quattroshapes-pipeline.git',
        revision: 'master',
        migrate:  false
      )
    end

    it 'should define execute npm install quattroshapes-pipeline' do
      resource = chef_run.execute('npm install quattroshapes-pipeline')
      expect(resource).to do_nothing
    end

    it 'should notify npm install' do
      resource = chef_run.deploy('/opt/pelias/quattroshapes-pipeline')
      expect(resource).to notify('execute[npm install quattroshapes-pipeline]').to(:run).immediately
    end

    it 'should download quattroshapes if they do not exist' do
      expect(chef_run).to create_remote_file_if_missing('download quattroshapes').with(
        backup: false,
        path:   '/opt/pelias/quattroshapes-data/quattroshapes-simplified.tar.gz',
        source: 'http://data.pelias.mapzen.com/quattroshapes-simplified.tar.gz'
      )
    end

    it 'should notify to write a logfile' do
      resource = chef_run.remote_file('download quattroshapes')
      expect(resource).to notify('log[log quattroshapes data load]').to(:write).immediately
    end

    it 'should notify to extract quattroshapes data' do
      resource = chef_run.remote_file('download quattroshapes')
      expect(resource).to notify('execute[extract quattroshapes data]').to(:run).immediately
    end

    it 'should define the log' do
      resource = chef_run.log('log quattroshapes data load')
      expect(resource).to do_nothing
    end

    it 'should define the quattroshapes data extract' do
      resource = chef_run.execute('extract quattroshapes data')
      expect(resource).to do_nothing
    end

    %w(admin0 admin1 admin2 local_admin locality neighborhood).each do |t|
      it "should define load quattroshapes #{t}" do
        resource = chef_run.execute("load quattroshapes #{t}")
        expect(resource).to do_nothing
      end
    end
  end

end
