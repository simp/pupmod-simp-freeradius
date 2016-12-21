require 'spec_helper'

describe 'freeradius::conf::listen' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      let(:facts) { facts }
      it { is_expected.to create_class('freeradius::conf::listen') }
      it { is_expected.to create_file('/etc/raddb/conf/listen.inc') }
    end
  end
end
