def gem_present(name)
  !Bundler.rubygems.find_name(name).empty?
end

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

test_tasks = [:spec]

if gem_present 'rubocop'
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
  test_tasks.unshift(:rubocop)
end

task test: test_tasks

task default: :test
