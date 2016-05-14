require 'spec_helper'

describe 'freeradius::conf::log' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      let(:facts) { facts }

      context "on #{os}" do
        it { is_expected.to create_class('freeradius::conf::log') }
        it { is_expected.to create_file('/etc/raddb/conf/log.inc') }
      end
    end
  end
end
