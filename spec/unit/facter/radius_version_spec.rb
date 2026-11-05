require 'spec_helper'

describe 'radius_version', type: :fact do
  before :each do
    Facter.clear
    allow(Facter::Core::Execution).to receive(:which).and_call_original
    allow(Facter::Core::Execution).to receive(:execute).and_call_original
  end

  context 'when freeradius is installed' do
    it 'returns a value' do
      allow(Facter::Core::Execution).to receive(:which).with('radiusd').and_return('/usr/sbin/radiusd')
      allow(Facter::Core::Execution).to receive(:execute).with('/usr/sbin/radiusd -v', on_fail: nil).and_return(File.read(File.expand_path('../../../files/radiusd_version_info', __FILE__)))

      expect(Facter.fact(:radius_version).value).to eq '3.0.13'
    end
  end

  context 'when radiusd returns junk' do
    it 'returns unknown' do
      allow(Facter::Core::Execution).to receive(:which).with('radiusd').and_return('/usr/sbin/radiusd')
      allow(Facter::Core::Execution).to receive(:execute).with('/usr/sbin/radiusd -v', on_fail: nil).and_return('This is not the radius you are looking for')

      expect(Facter.fact(:radius_version).value).to eq 'unknown'
    end
  end

  context 'when radiusd cannot be run' do
    it 'returns unknown' do
      allow(Facter::Core::Execution).to receive(:which).with('radiusd').and_return('/usr/sbin/radiusd')
      allow(Facter::Core::Execution).to receive(:execute).with('/usr/sbin/radiusd -v', on_fail: nil).and_return(nil)

      expect(Facter.fact(:radius_version).value).to eq 'unknown'
    end
  end

  context 'when freeradius is not installed' do
    it 'is not set' do
      allow(Facter::Core::Execution).to receive(:which).with('radiusd').and_return(nil)
      expect(Facter::Core::Execution).not_to receive(:execute).with('/usr/sbin/radiusd -v', on_fail: nil)

      expect(Facter.value(:radius_version)).to be_nil
    end
  end
end
