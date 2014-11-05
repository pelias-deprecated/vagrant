require 'spec_helper'

describe 'pelias::api' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }
  before do
    stub_command('pgrep -f elasticsearch').and_return(true)
  end

  it 'should git sync the api' do
    expect(chef_run).to sync_git('/opt/pelias/pelias-api').with(
      user:     'pelias',
      repo:     'https://github.com/pelias/api.git',
      revision: 'master'
    )
  end

  it 'should notify npm install' do
    resource = chef_run.git('/opt/pelias/pelias-api')
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
