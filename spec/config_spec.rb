require 'spec_helper'

describe 'pelias::config' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }
  before do
    stub_command('pgrep -f elasticsearch').and_return(true)
  end

  it 'should create the cfg dir' do
    expect(chef_run).to create_directory('/etc/pelias').with(
      recursive:  true,
      owner:      'pelias',
      mode:       0755
    )
  end

  it 'should create the esclient logdir' do
    expect(chef_run).to create_directory('/var/log/esclient').with(
      recursive:  true,
      owner:      'pelias',
      mode:       0755
    )
  end

  it 'should create the pelias config file' do
    expect(chef_run).to create_template('/etc/pelias/pelias.json').with(
      source:     'pelias.json.erb',
      mode:       0644,
      variables:  { osm_data_file: '' }
    )
  end

end
