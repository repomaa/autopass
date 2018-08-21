require 'autopass/env_hash'

describe 'ENV_HASH' do
  it 'contains env variables accessible by symbols' do
    expect(ENV_HASH[:HOME]).to eq(ENV['HOME'])
  end
end
