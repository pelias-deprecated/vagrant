require 'spec_helper'

describe 'pelias::quattroshapes' do
  before do
    stub_command('pgrep -f elasticsearch').and_return(true)
  end
  context 'with index_data = true' do
    let(:chef_run) do
      ChefSpec::Runner.new do |node|
        node.set[:pelias][:quattroshapes][:index_data] = true
        node.set[:pelias][:quattroshapes][:alpha3_country_codes] = %w(ITA)
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

    %w(ITA).each do |c|
      it "should create pelias template for #{c}" do
        expect(chef_run).to create_template("/opt/pelias/quattroshapes-pipeline/current/example/#{c}_index_quattroshapes.js").with(
          source:     'index_quattroshapes.js.erb',
          mode:       0644,
          variables:  { country: c }
        )
      end

      it "should download the data file #{c}.tgz" do
        expect(chef_run).to create_remote_file_if_missing("/opt/pelias/data/quattroshapes/#{c}.tgz").with(
          source: "http://data.mapzen.com/quattroshapes/alpha3/#{c}.tgz",
          mode:   0644,
          backup: false
        )
      end

      it "should notify to extract quattroshapes for #{c}" do
        resource = chef_run.remote_file("/opt/pelias/data/quattroshapes/#{c}.tgz")
        expect(resource).to notify("execute[extract quattroshapes for #{c}]").to(:run).immediately
      end

      it "should define the extract process for #{c}" do
        resource = chef_run.execute("extract quattroshapes for #{c}")
        expect(resource).to do_nothing
      end

      %w(admin0 admin1 admin2 local_admin locality neighborhood).each do |type|
        it "should define load quattroshapes for #{c} #{type}" do
          resource = chef_run.execute("load quattroshapes for #{c} #{type}")
          expect(resource).to do_nothing
        end
      end
    end
  end

  context 'with index_data = false' do
    let(:chef_run) do
      ChefSpec::Runner.new do |node|
        node.set[:pelias][:quattroshapes][:index_data] = false
        node.set[:pelias][:quattroshapes][:extracts] = %w(ITA)
      end.converge(described_recipe)
    end

    it 'should not deploy quattroshapes' do
      expect(chef_run).to_not deploy_deploy('/opt/pelias/quattroshapes-pipeline')
    end
  end

end
