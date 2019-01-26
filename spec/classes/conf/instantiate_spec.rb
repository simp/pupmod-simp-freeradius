require 'spec_helper'

describe 'freeradius::conf::instantiate' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      let(:facts) { facts }
      let(:pre_condition) { 'include "freeradius::service"' }

      it { is_expected.to create_class('freeradius::conf::instantiate') }
      it { is_expected.to create_file('/etc/raddb/conf.d/instantiate.inc').with_content(/logintime/) }

      context 'keep_defaults_false' do
        let(:params) {{
          :keep_defaults => false,
          :content       => 'test_content'
        }}

        it { is_expected.to create_file('/etc/raddb/conf.d/instantiate.inc').with_content(/test_content/) }
      end
    end
  end
end
