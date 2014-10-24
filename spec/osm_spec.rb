require 'spec_helper'

describe 'pelias::osm' do
  before do
    stub_command('npm -g list bower').and_return(true)
  end

  context 'with index_data = true' do
    let(:chef_run) do
      ChefSpec::Runner.new do |node|
        node.set[:pelias][:osm][:index_data] = true
        node.set[:pelias][:osm][:extracts] = {
          'rome'      => 'http://rome.osm.pbf',
          'florence'  => 'http://florence.osm.pbf'
        }
      end.converge(described_recipe)
    end

    it 'should deploy pelias-osm' do
      expect(chef_run).to deploy_deploy('/opt/pelias/pelias-osm').with(
        user:     'pelias',
        repo:     'https://github.com/mapzen/pelias-openstreetmap.git',
        revision: 'master',
        migrate:  false
      )
    end

    it 'should define execute npm install pelias-osm' do
      resource = chef_run.execute('npm install pelias-osm')
      expect(resource).to do_nothing
    end

    it 'should notify npm install' do
      resource = chef_run.deploy('/opt/pelias/pelias-osm')
      expect(resource).to notify('execute[npm install pelias-osm]').to(:run).immediately
    end

    %w(florence rome).each do |c|
      it "should create pelias template for #{c}" do
        expect(chef_run).to create_template("/etc/pelias/#{c}_pelias.json").with(
          source:     'pelias.json.erb',
          mode:       0644,
          variables:  { osm_data_file: "#{c}.osm.pbf" }
        )
      end

      it "should download the data file #{c}.osm.pbf" do
        expect(chef_run).to create_remote_file_if_missing("/opt/pelias/osm-data/#{c}.osm.pbf").with(
          source: "http://#{c}.osm.pbf",
          mode:   0644,
          backup: false
        )
      end

      it 'should notify to write a log message' do
        resource = chef_run.remote_file("/opt/pelias/osm-data/#{c}.osm.pbf")
        expect(resource).to notify("log[log osm load #{c}]").to(:write).immediately
      end

      it "should notify to load #{c} into elasticsearch" do
        resource = chef_run.remote_file("/opt/pelias/osm-data/#{c}.osm.pbf")
        expect(resource).to notify("execute[load osm #{c}]").to(:run).immediately
      end

      it 'should define a log message' do
        resource = chef_run.log("log osm load #{c}")
        expect(resource).to do_nothing
      end

      it "should define an osm load action for #{c}" do
        resource = chef_run.execute("load osm #{c}")
        expect(resource).to do_nothing
      end
    end
  end

  context 'with index_data = false' do
    let(:chef_run) do
      ChefSpec::Runner.new do |node|
        node.set[:pelias][:osm][:index_data] = false
        node.set[:pelias][:osm][:extracts] = {
          'rome'      => 'http://rome.osm.pbf',
          'florence'  => 'http://florence.osm.pbf'
        }
      end.converge(described_recipe)
    end

    it 'should not deploy pelias-osm' do
      expect(chef_run).to_not deploy_deploy('/opt/pelias/pelias-osm')
    end
  end

end
