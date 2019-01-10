require 'spec_helper'

describe 'freeradius::conf::security' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      let(:facts) { facts }
      let(:pre_condition) { "include 'freeradius::service'" }
      let(:params) {{
        :max_attributes => 200
      }}

      it { is_expected.to create_class('freeradius::conf::security') }
      it { is_expected.to create_file('/etc/raddb/conf/security.inc').with_content(/max_attributes = 200/) }
    end
  end
end
