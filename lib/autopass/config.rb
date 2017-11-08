require 'autopass/types'
require 'autopass/core_ext/hash'
require 'dry-struct'
require 'yaml'

module Autopass
  # Autopass config
  class Config < Dry::Struct
    constructor_type :strict_with_defaults

    # Config for keybindings
    class KeyBindings < Dry::Struct
      constructor_type :strict_with_defaults

      attribute :copy_username, Types::String.default('Alt+u')
      attribute :copy_password, Types::String.default('Alt+p')
      attribute :autotype_tan, Types::String.default('Alt+t')
      attribute :open_browser, Types::String.default('Alt+o')
      attribute :copy_otp, Types::String.default('Alt+c')
    end

    attribute :prompt, Types::String.default('Search:')
    attribute :use_cache, Types::Bool.default(true)
    attribute :cache_key, Types::String.optional.default(nil)
    attribute(:cache_file, Types::Pathname.default do
      (
        Pathname.new(ENV.fetch('XDG_CACHE_HOME', '~/.cache')) +
        'autopass/autopass.cache'
      ).expand_path
    end)

    attribute(:password_store, Types::Pathname.default do
      Pathname.new(
        ENV.fetch('PASSWORD_STORE_DIR', '~/.password-store')
      ).expand_path
    end)

    attribute :username_key, Types::String.default('user')
    attribute :password_key, Types::String.default('pass')
    attribute :autotype, Types::SpaceSeparatedArray.optional.default(nil)
    attribute :autotype_1, Types::SpaceSeparatedArray.optional.default(nil)
    attribute :autotype_2, Types::SpaceSeparatedArray.optional.default(nil)
    attribute :autotype_3, Types::SpaceSeparatedArray.default(%w[:otp])

    (4..5).each do |i|
      attribute(
        :"autotype_#{i}", Types::SpaceSeparatedArray.optional.default(nil)
      )
    end

    attribute :key_bindings, Types.Constructor(KeyBindings).default(
      KeyBindings.new
    )

    attribute :alt_delay, Types::Float.default(0.5)
    attribute :clip_command, Types::String.default('xclip')
    attribute :browsers, Types::SpaceSeparatedArray.default(
      %w[chrome chromium firefox opera]
    )

    def initialize(*)
      super
      self.autotype ||= [username_key, ':tab', password_key]
      self.autotype_1 ||= [password_key]
      self.autotype_2 ||= [username_key]
      return if !use_cache || cache_key
      raise ArgumentError, 'Missing option: cache_key'
    end

    def self.load(file)
      yaml = File.read(file)
      load_yaml(yaml)
    end

    def self.load_yaml(yaml)
      config_hash = YAML.safe_load(yaml).deep_symbolize_keys
      new(config_hash)
    end

    def merge(attributes)
      self.class.new(to_h.merge(attributes.deep_symbolize_keys))
    end

    def to_h
      super.merge(key_bindings: key_bindings.to_h)
    end

    private

    attr_writer :autotype, :autotype_1, :autotype_2
  end
end
