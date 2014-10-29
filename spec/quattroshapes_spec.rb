require 'spec_helper'

describe 'pelias::quattroshapes' do
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

    it 'should ark quattroshapes-data' do
      expect(chef_run).to put_ark('quattroshapes-data').with(
        owner:    'pelias',
        url:      'http://data.mapzen.com/quattroshapes/quattroshapes-simplified.tar.gz',
        checksum: 'e89cd4cb232aaea00d14972247ac8229a74378968901af4661b8aa7fada23bcb',
        path:     '/opt/pelias'
      )
    end

    it 'should define the log' do
      resource = chef_run.log('log quattroshapes data load')
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
