# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rspec-puppet-facts-unsupported/version'

Gem::Specification.new do |spec|
  spec.name          = 'rspec-puppet-facts-unsupported'
  spec.version       = RspecPuppetFactsUnsupported::VERSION
  spec.authors       = ['Suszyński Krzysztof']
  spec.email         = ['krzysztof.suszynski@coi.gov.pl']

  spec.summary       = 'Helpers to generate unsupported OS facts to test for proper fail'
  spec.description   = 'Using new `on_unsupported_os` method you can get a number of random provided OS\'s' \
                       ' with their factsto be used in rspec-puppet tests'
  spec.homepage      = 'https://github.com/coi-gov-pl/rspec-puppet-facts-unsupported'
  spec.license       = 'Apache-2.0'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 1.9.0'

  spec.add_development_dependency 'bundler', '~> 1.15'
end
