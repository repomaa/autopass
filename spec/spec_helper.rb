require 'pry'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = 'spec/examples.txt'
  config.disable_monkey_patching!
  config.warnings = true

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end

  config.expose_dsl_globally = true
  config.profile_examples = 10
  config.order = :random
  Kernel.srand config.seed

  def fixture(file)
    File.expand_path(File.join('..', 'fixtures', file), __FILE__)
  end
end

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

include Autopass

# Need to do this before requiring project files
ENV['TEST_VAR'] = 'test'
