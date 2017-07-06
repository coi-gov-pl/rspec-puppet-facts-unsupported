def gem_present(name)
  !Bundler.rubygems.find_name(name).empty?
end

if gem_present 'simplecov'
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec/'
    add_filter '/vendor/'
  end
  SimpleCov.refuse_coverage_drop
end

require 'pry' if gem_present 'pry'

require 'bundler/setup'
require 'rspec/collection_matchers'
require 'rspec-puppet-facts-unsupported'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
