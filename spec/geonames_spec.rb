require 'spec_helper'

describe 'pelias::geonames' do
  before do
    stub_command('pgrep -f elasticsearch').and_return(true)
  end
  context 'with index_data = true' do
    let(:chef_run) do
      ChefSpec::Runner.new do |node|
        node.set[:pelias][:geonames][:index_data]     = true
        node.set[:pelias][:geonames][:alpha2_country_codes]  = %w(IT DE)
      end.converge(described_recipe)
    end

    it 'should deploy geonames' do
      expect(chef_run).to deploy_deploy('/opt/pelias/geonames').with(
        user:     'pelias',
        repo:     'https://github.com/pelias/geonames.git',
        revision: 'master',
        migrate:  false
      )
    end

    it 'should define execute npm install geonames' do
      resource = chef_run.execute('npm install geonames')
      expect(resource).to do_nothing
    end

    it 'should notify npm install' do
      resource = chef_run.deploy('/opt/pelias/geonames')
      expect(resource).to notify('execute[npm install geonames]').to(:run).immediately
    end

    %w(IT DE).each do |c|
      it "should download geonames for #{c}" do
        expect(chef_run).to run_execute("download geonames for #{c}").with(
          user: 'pelias',
          command: "./bin/pelias-geonames -d #{c} >/opt/pelias/logs/geonames_#{c}.out 2>/opt/pelias/logs/geonames_#{c}.err",
          cwd: '/opt/pelias/geonames/current',
          timeout: 7200,
          environment: { 'HOME' => '/home/pelias', 'PELIAS_CONFIG' => '/etc/pelias/pelias.json', 'OSMIUM_POOL_THREADS' => '10' }
        )
      end

      it "should notify to write a log message for #{c}" do
        resource = chef_run.execute("download geonames for #{c}")
        expect(resource).to notify("log[log geonames load for #{c}]").to(:write).immediately
      end

      it "should notify to load geonames for #{c}" do
        resource = chef_run.execute("download geonames for #{c}")
        expect(resource).to notify("execute[load geonames for #{c}]").to(:run).immediately
      end

      it "should define a log message for #{c}" do
        resource = chef_run.log("log geonames load for #{c}")
        expect(resource).to do_nothing
      end

      it "should define execute load geonames for #{c}" do
        resource = chef_run.execute("load geonames for #{c}")
        expect(resource).to do_nothing
      end
    end
  end

end
