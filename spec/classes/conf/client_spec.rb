require 'spec_helper'

describe 'freeradius::conf::client' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      let(:facts) { facts }

      it { is_expected.to create_class('freeradius::conf::client') }
      it { is_expected.to create_file('/etc/raddb/conf/clients').with_ensure('directory') }
    end
  end
end
