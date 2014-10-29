require 'spec_helper'

describe 'pelias::api' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  it 'should deploy the api' do
    expect(chef_run).to deploy_deploy('/opt/pelias/pelias-api').with(
      user:     'pelias',
      repo:     'https://github.com/pelias/api.git',
      revision: 'master',
      migrate:  false
    )
  end

  it 'should notify npm install' do
    resource = chef_run.deploy('/opt/pelias/pelias-api')
    expect(resource).to notify('execute[npm install pelias-api]').to(:run).immediately
  end

  it 'should define npm install pelias-api' do
    resource = chef_run.execute('npm install pelias-api')
    expect(resource).to do_nothing
  end

  it 'should include pelias::api_service' do
    expect(chef_run).to include_recipe 'pelias::api_service'
  end

end
