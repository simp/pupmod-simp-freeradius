require 'spec_helper'

describe 'freeradius::users' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      let(:facts) { facts }

      it { is_expected.to create_class('freeradius::users') }
      it { is_expected.to create_file('/etc/raddb/users.inc').with_ensure('directory') }
      it { is_expected.to create_file('/etc/raddb/users') }
    end
  end
end
