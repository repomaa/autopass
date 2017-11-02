# frozen_string_literal: true

guard :rspec, cmd: 'bundle exec rspec' do
  require 'guard/rspec/dsl'
  dsl = Guard::RSpec::Dsl.new(self)

  # RSpec files
  rspec = dsl.rspec
  watch(rspec.spec_helper) { rspec.spec_dir }
  watch(rspec.spec_support) { rspec.spec_dir }
  watch(rspec.spec_files)

  watch(%r{^lib/(.+)\.rb$}) { |m| rspec.spec.call(m[1]) }

  # shared examples
  watch(
    %r{^(#{Regexp.escape(rspec.spec_dir)}/.+)/shared_examples/.+\.rb$}
  ) do |m|
    m[1]
  end
end
