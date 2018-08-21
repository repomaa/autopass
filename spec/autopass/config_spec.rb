require 'autopass/config'
require 'yaml'

describe Config do
  let(:required_attributes) { { cache_key: 'ABCDEF' } }

  describe '.new' do
    subject(:config) { described_class.new(attributes) }

    context 'without required attributes' do
      let(:attributes) { {} }

      it 'raises an error' do
        expect { config }.to raise_error(ArgumentError)
      end
    end

    context 'without optional attributes' do
      let(:attributes) { required_attributes }

      shared_examples 'default value' do |option, expected_default_value|
        it "assigns expected default value for option #{option}" do
          actual_value = config.public_send(option)
          expect(actual_value).to eq(expected_default_value)
        end
      end

      include_examples 'default value', :prompt, 'Search:'

      context 'with XDG_CACHE_HOME unset' do
        before { ENV.delete('XDG_CACHE_HOME') }

        include_examples(
          'default value',
          :cache_file,
          Pathname.new('~/.cache/autopass/autopass.cache').expand_path
        )
      end

      context 'with XDG_CACHE_HOME set' do
        before { ENV['XDG_CACHE_HOME'] = '/test' }

        include_examples(
          'default value',
          :cache_file,
          Pathname.new('/test/autopass/autopass.cache')
        )
      end

      context 'with PASSWORD_STORE_DIR unset' do
        before { ENV.delete('PASSWORD_STORE_DIR') }

        include_examples(
          'default value',
          :password_store,
          Pathname.new('~/.password-store').expand_path
        )
      end

      context 'with PASSWORD_STORE_DIR set' do
        before { ENV['PASSWORD_STORE_DIR'] = '/test' }

        include_examples(
          'default value',
          :password_store,
          Pathname.new('/test')
        )
      end

      include_examples 'default value', :username_key, 'user'
      include_examples 'default value', :password_key, 'pass'
      include_examples 'default value', :autotype, ['user', ':tab', 'pass']
      include_examples 'default value', :autotype_1, ['pass']
      include_examples 'default value', :autotype_2, ['user']
      include_examples 'default value', :autotype_3, [':otp']

      context 'key_bindings' do
        subject(:config) do
          described_class.new(required_attributes).key_bindings
        end

        include_examples 'default value', :copy_username, 'Alt+u'
        include_examples 'default value', :copy_password, 'Alt+p'
        include_examples 'default value', :autotype_tan, 'Alt+t'
        include_examples 'default value', :open_browser, 'Alt+o'
        include_examples 'default value', :copy_otp, 'Alt+c'
      end

      include_examples 'default value', :alt_delay, 0.5
    end

    context 'with username_key set to non-default value' do
      let(:attributes) { required_attributes.merge(username_key: 'username') }

      it 'sets username_key to the given value' do
        expect(config.username_key).to eq('username')
      end

      context 'with autotype unset' do
        it 'sets autotype to contain value of username_key' do
          expect(config.autotype).to eq(%w[username :tab pass])
        end
      end

      context 'with autotype_2 unset' do
        it 'sets autotype_2 to value of username_key' do
          expect(config.autotype_2).to eq(['username'])
        end
      end

      context 'with autotype set' do
        let(:attributes) do
          required_attributes.merge(
            username_key: 'username', autotype: 'user :tab pass'
          )
        end

        it 'sets autotype to given value' do
          expect(config.autotype).to eq(%w[user :tab pass])
        end
      end

      context 'with autotype_2 set' do
        let(:attributes) do
          required_attributes.merge(
            username_key: 'username', autotype_2: 'pass'
          )
        end

        it 'sets autotype_2 to the given value' do
          expect(config.autotype_2).to eq(['pass'])
        end
      end
    end

    context 'with password_key set to non-default value' do
      let(:attributes) { required_attributes.merge(password_key: 'password') }

      it 'sets password_key to the given value' do
        expect(config.password_key).to eq('password')
      end

      context 'with autotype unset' do
        it 'sets autotype to contain value of password_key' do
          expect(config.autotype).to eq(%w[user :tab password])
        end
      end

      context 'with autotype_1 unset' do
        it 'sets autotype_1 to the value of password_key' do
          expect(config.autotype_1).to eq(['password'])
        end
      end

      context 'with autotype set' do
        let(:attributes) do
          required_attributes.merge(
            password_key: 'password', autotype: 'user :tab pass'
          )
        end

        it 'sets autotype to given value' do
          expect(config.autotype).to eq(%w[user :tab pass])
        end
      end

      context 'with autotype_2 unset' do
        let(:attributes) do
          required_attributes.merge(
            password_key: 'password', autotype_1: 'user'
          )
        end

        it 'sets autotype_1 to the given value' do
          expect(config.autotype_1).to eq(['user'])
        end
      end
    end
  end

  describe '.load' do
    subject(:config) { described_class.load(file_path) }

    let(:file_path) { fixture('config.yml') }

    before { allow(YAML).to receive(:safe_load).and_call_original }

    it 'parses the given yaml file' do
      described_class.load(file_path)
      expect(YAML).to have_received(:safe_load).with(File.read(file_path))
    end

    it 'overrides defaults' do
      expect(config.prompt).to eq('Test prompt:')
    end

    it 'deeply overrides defaults' do
      expect(config.key_bindings.copy_password).to eq('Alt+c')
    end

    it 'uses defaults for keys not included in config' do
      expect(config.alt_delay).to eq(0.5)
    end
  end

  describe '#to_h' do
    subject(:config) { described_class.new(required_attributes) }

    it 'returns a hash' do
      expect(config.to_h).to be_a(Hash)
    end

    it 'calls to hash on key_bindings' do
      expect(config.to_h[:key_bindings]).to be_a(Hash)
    end
  end

  describe '#merge' do
    subject(:config) { described_class.new(attributes).merge(other_attributes) }

    let(:attributes) { required_attributes.merge(autotype_1: 'user :tab pass') }

    let(:other_attributes) { { 'autotype_1' => 'user :tab pass :enter' } }

    it 'overrides attributes' do
      expect(config.autotype_1).to eq(%w[user :tab pass :enter])
    end
  end
end
