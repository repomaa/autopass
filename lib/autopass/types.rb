require 'dry-types'
require 'pathname'
require 'autopass/env_hash'
require 'autopass/util'

module Autopass
  # Dry-types used in config deserialization
  module Types
    include Dry::Types.module

    String = Coercible::String.constructor do |value|
      Util.silence_warnings do
        format(Coercible::String[value], ENV_HASH)
      end
    end

    Pathname = Instance(::Pathname).constructor do |value|
      if value.is_a?(::Pathname)
        value.expand_path
      else
        ::Pathname.new(String[value]).expand_path
      end
    end

    SpaceSeparatedArray = Strict::Array.of(String).constructor do |value|
      value.is_a?(::Array) ? value : String[value].split(/\s+/)
    end
  end
end
