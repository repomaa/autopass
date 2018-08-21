require 'bundler/gem_tasks'

ENV['ENV'] ||= 'development'

if ENV['ENV'] == 'development'
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec)

  task default: :spec
end
