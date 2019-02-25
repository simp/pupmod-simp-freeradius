require 'spec_helper'

describe 'radius_version', :type => :fact do

  before :each do
    Facter.clear
  end

  context 'when freeradius is installed' do
    it 'should return a value' do
      Facter::Core::Execution.expects(:which).with('radiusd').returns('/usr/sbin/radiusd')
      Facter::Core::Execution.expects(:exec).with('/usr/sbin/radiusd -v').returns(File.read File.expand_path('../../../files/radiusd_version_info', __FILE__))

      expect(Facter.fact(:radius_version).value).to eq '3.0.13'
    end
  end

  context 'when radiusd returns junk' do
    it 'should return unknown' do
      Facter::Core::Execution.expects(:which).with('radiusd').returns('/usr/sbin/radiusd')
      Facter::Core::Execution.expects(:exec).with('/usr/sbin/radiusd -v').returns('This is not the radius you are looking for')

      expect(Facter.fact(:radius_version).value).to eq 'unknown'
    end
  end

end
