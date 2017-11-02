# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'autopass/version'

Gem::Specification.new do |spec|
  spec.name          = 'autopass'
  spec.version       = Autopass::VERSION
  spec.authors       = ['Joakim Reinert']
  spec.email         = ['mail@jreinert.com']

  spec.summary       = 'A rofi frontend for pass'
  spec.homepage      = 'https://github.com/jreinert/autopass'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^spec/})
  end

  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.8'
  spec.add_development_dependency 'guard-rspec', '~> 4.7'
  spec.add_development_dependency 'pry-byebug', '~> 3.5'
  spec.add_development_dependency 'rake', '~> 12.2'
  spec.add_development_dependency 'rspec', '~> 3.7'
  spec.add_development_dependency 'rubocop', '~> 0.5'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.1'
  spec.add_development_dependency 'simplecov', '~> 0.9'

  spec.add_dependency 'dry-struct', '~> 0.3'
  spec.add_dependency 'dry-types', '~> 0.1'
end
