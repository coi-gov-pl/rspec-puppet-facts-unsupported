require 'spec_helper'

RSpec.describe RSpec::Puppet::Facts::Unsupported do
  describe '::VERSION' do
    let(:version) { Puppet::Examples::Helpers::VERSION }
    context 'as String' do
      subject { version }
      it { is_expected.not_to be nil }
      it { is_expected.to match(/^v?[0-9]+(.[0-9]+)*$/) }
    end
    context 'as Gem::Version' do
      let(:req) { Gem::Requirement.new('~> 0') }
      let(:gversion) { Gem::Version.new(version) }
      subject { req }
      it { is_expected.to be =~ gversion }
    end
  end
end
