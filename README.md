# Puppet::Examples::Helpers

[![Build Status](https://travis-ci.org/coi-gov-pl/rspec-puppet-facts-unsupported.svg?branch=develop)](https://travis-ci.org/coi-gov-pl/rspec-puppet-facts-unsupported)

Helpers to generate unsupported OS facts to test for proper fail.

Using new `on_unsupported_os` method you can get a number of random provided OS's with their factsto be used in rspec-puppet tests

```ruby
on_unsupported_os.first(2).to_h.each do |os, facts|
  context "on unsupported #{os}" do
    let(:facts) { facts }
    it { is_expected.to compile.and_raise_error(/Unsupported operating system/) }
  end
end
```

## Installation

Add this to your puppet module's Gemfile:

```ruby
group :system_tests do
  # [..]
  gem 'rspec-puppet-facts-unsupported'
end
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rspec-puppet-facts-unsupported

## Usage

```ruby
# in rspec-puppet test
require 'spec_helper'

describe '::vagrant', type: :class do
  on_unsupported_os.first(2).to_h.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      it { is_expected.to compile.and_raise_error(/Unsupported operating system/) }
    end
  end
end
```

## Development

After checking out the repo, run `bundle` to install dependencies. Then, run `bundle exec rake spec` to run the tests. You can also run `bundle exec rake console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/coi-gov-pl/rspec-puppet-facts-unsupported. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [Apache 2.0](https://opensource.org/licenses/Apache-2.0).

## Code of Conduct

Everyone interacting in the Puppet::Examples::Helper project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/coi-gov-pl/rspec-puppet-facts-unsupported/blob/master/CODE_OF_CONDUCT.md).
