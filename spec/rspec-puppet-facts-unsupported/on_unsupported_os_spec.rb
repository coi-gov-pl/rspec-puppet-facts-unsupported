require 'spec_helper'

RSpec::Matchers.define :contain_os do |expected_os|
  match do |all_oss|
    !all_oss.select do |os_group|
      actual_os, = os_group
      actual_os == expected_os
    end.empty?
  end
  description do
    "contain operating system described as #{expected.inspect}"
  end
end

RSpec.shared_examples "it doesn't contain supported OS's described in metadata.json" do
  it { is_expected.not_to contain_os('centos-6-x86_64') }
  it { is_expected.not_to contain_os('centos-7-x86_64') }
  it { is_expected.not_to contain_os('ubuntu-14.04-x86_64') }
  it { is_expected.not_to contain_os('ubuntu-16.04-x86_64') }
end

RSpec.describe RspecPuppetFactsUnsupported do
  describe '#on_unsupported_os' do
    before(:each) { RspecPuppetFactsUnsupported.verbose = false }
    let(:target) { Class.new { extend RspecPuppetFactsUnsupported } }
    subject { target.on_unsupported_os(opts) }

    context 'with no parameters given' do
      let(:opts) { {} }
      it { is_expected.to be_a Hash }
      it { is_expected.to have_at_least(2).items }
      it_behaves_like "it doesn't contain supported OS's described in metadata.json"
    end

    context 'with :order opt' do
      context 'set to 11111' do
        let(:opts) { { order: 11_111 } }
        it { is_expected.to be_a Hash }
        it { is_expected.to have_at_least(2).items }
        describe 'first returned operating system\'s facts' do
          it { expect(Hash[*subject.first]).to contain_os('fedora-23-x86_64') }
        end
        context 'with verbose => true' do
          before(:each) { RspecPuppetFactsUnsupported.verbose = true }
          it { expect { subject }.to output(/^Shuffling unsupported OS's facts with seed: 11111/).to_stderr }
          it { expect { subject }.to output(/export RSPEC_PUPPET_FACTS_UNSUPPORTED_ORDER=11111/).to_stderr }
        end
        it_behaves_like "it doesn't contain supported OS's described in metadata.json"
      end
      context 'set to :random' do
        let(:opts) { { order: :random } }
        it { is_expected.to be_a Hash }
        it { is_expected.to have_at_least(2).items }
        context 'with verbose => true' do
          before(:each) { RspecPuppetFactsUnsupported.verbose = true }
          it { expect { subject }.to output(/^Shuffling unsupported OS's facts with seed: \d+/).to_stderr }
          it { expect { subject }.to output(/export RSPEC_PUPPET_FACTS_UNSUPPORTED_ORDER=\d+/).to_stderr }
        end
        it_behaves_like "it doesn't contain supported OS's described in metadata.json"
      end
    end

    context 'with :limit opt set to 100' do
      let(:opts) { { limit: 100 } }
      it { is_expected.to be_a Hash }
      it { is_expected.to have_at_least(25).items }
      it { is_expected.to contain_os('scientific-7-x86_64') }
      it { is_expected.to contain_os('oraclelinux-6-x86_64') }
      it { is_expected.to contain_os('debian-8-x86_64') }
      it { is_expected.to contain_os('debian-7-x86_64') }
      it_behaves_like "it doesn't contain supported OS's described in metadata.json"
    end

    context 'with :hardwaremodels opt set to "/IBM/" and :filters opt to facterversion: "/^3\./"' do
      let(:opts) do
        { hardwaremodels: '/IBM/', filters: { facterversion: '/^3\./' } }
      end
      it { is_expected.to be_a Hash }
      it { is_expected.to have_at_least(2).items }
      it { is_expected.to contain_os('aix-7100-IBM,8231-E1D') }
      it_behaves_like "it doesn't contain supported OS's described in metadata.json"
    end

    context 'with :hardwaremodels opt set to "i86pc"' do
      let(:opts) do
        { hardwaremodels: 'i86pc' }
      end
      it { is_expected.to be_a Hash }
      it { is_expected.to have_at_least(1).items }
      it { is_expected.to contain_os('solaris-11-i86pc') }
      it_behaves_like "it doesn't contain supported OS's described in metadata.json"
    end
  end
end
