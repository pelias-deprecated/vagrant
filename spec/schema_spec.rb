require 'spec_helper'

describe 'pelias::schema' do
  before do
    stub_command("curl -s 'localhost:9200/_cat/indices?v' | grep pelias").and_return(false)
  end

  context 'with create_index = true' do
    let(:chef_run) do
      ChefSpec::Runner.new do |node|
        node.set[:pelias][:schema][:create_index] = true
      end.converge(described_recipe)
    end

    it 'should deploy pelias-schema' do
      expect(chef_run).to deploy_deploy('/opt/pelias/pelias-schema').with(
        user:     'pelias',
        repo:     'https://github.com/pelias/schema.git',
        revision: 'master',
        migrate:  false
      )
    end

    it 'should define execute npm install pelias-schema' do
      resource = chef_run.execute('npm install pelias-schema')
      expect(resource).to do_nothing
    end

    it 'should notify npm install' do
      resource = chef_run.deploy('/opt/pelias/pelias-schema')
      expect(resource).to notify('execute[npm install pelias-schema]').to(:run).immediately
    end

    it 'should not drop the index' do
      expect(chef_run).to_not run_execute('node scripts/drop_index.js --force-yes')
    end

    it 'should try to create the index' do
      expect(chef_run).to run_execute('node scripts/create_index.js').with(
        user:           'pelias',
        cwd:            '/opt/pelias/pelias-schema/current',
        retries:        1,
        retry_delay:    15,
        environment: { 'PELIAS_CONFIG' => '/etc/pelias/pelias.json' }
      )
    end
  end

  context 'with drop_index = true, create_index = false' do
    let(:chef_run) do
      ChefSpec::Runner.new do |node|
        node.set[:pelias][:schema][:drop_index]    = true
        node.set[:pelias][:schema][:create_index]  = false
      end.converge(described_recipe)
    end

    it 'should deploy pelias-schema' do
      expect(chef_run).to deploy_deploy('/opt/pelias/pelias-schema').with(
        user:     'pelias',
        repo:     'https://github.com/pelias/schema.git',
        revision: 'master',
        migrate:  false
      )
    end

    it 'should define execute npm install pelias-schema' do
      resource = chef_run.execute('npm install pelias-schema')
      expect(resource).to do_nothing
    end

    it 'should notify npm install' do
      resource = chef_run.deploy('/opt/pelias/pelias-schema')
      expect(resource).to notify('execute[npm install pelias-schema]').to(:run).immediately
    end

    it 'should drop the index' do
      expect(chef_run).to run_execute('node scripts/drop_index.js --force-yes').with(
        user:         'pelias',
        cwd:          '/opt/pelias/pelias-schema/current',
        environment: { 'PELIAS_CONFIG' => '/etc/pelias/pelias.json' }
      )
    end

    it 'should not create the index' do
      resource = chef_run.execute('node scripts/create_index.js')
      expect(resource).to do_nothing
    end
  end

end
