require 'spec_helper'

describe 'pelias::user' do
  before do
    stub_command('npm -g list bower').and_return(true)
  end
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  it 'should create the pelias user' do
    expect(chef_run).to create_user_account('pelias').with(
      manage_home:  true,
      create_group: true,
      ssh_keygen:   false,
      home:         '/home/pelias'
    )
  end
end
