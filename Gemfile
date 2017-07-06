source ENV['GEM_SOURCE'] || 'https://rubygems.org'

RVERSION = Gem::Version.new(RUBY_VERSION.dup)

def req(req_s)
  Gem::Requirement.new(req_s)
end

group :test do
  gem 'rspec', '~> 3',                         require: false
  gem 'rspec-collection_matchers', '~> 1.1.3', require: false
  gem 'rubocop', '~> 0.49',                    require: false if req('>= 2.0') =~ RVERSION
  gem 'simplecov', '~> 0.14.1',                require: false
end

group :development do
  gem 'bundler', '~> 1.15.1',             require: false
  gem 'pry-byebug', '~> 3.4', '>= 3.4.2', require: false if req('>= 2.0') =~ RVERSION
  gem 'rake', '~> 10',                    require: false
end

# Specify your gem's dependencies in rspec-puppet-facts-unsupported.gemspec
gemspec
