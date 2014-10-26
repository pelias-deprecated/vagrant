require 'spec_helper'

describe 'pelias::api_service' do
  before do
    stub_command('npm -g list bower').and_return(true)
  end
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  it 'should enable and start the runit service pelias-api' do
    expect(chef_run).to enable_runit_service('pelias-api').with(
      log:            true,
      default_logger: true,
      sv_timeout:     60,
      env:            { 'PELIAS_CONFIG' => '/etc/pelias/pelias.json', 'NODE_ENV' => 'dev', 'PORT' => '3100' }
    )
  end

  it 'runit hack for 100% test coverage: should define a service pelias-api' do
    resource = chef_run.service('pelias-api')
    expect(resource).to do_nothing
  end
end
