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
    end
  end

end
