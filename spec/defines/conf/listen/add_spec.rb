require 'spec_helper'

describe 'freeradius::conf::listen::add', :type => :define do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      let(:facts) { facts }
      let(:title) {'test_add_listen'}
      let(:params) {{
        :listen_type => 'proxy'
      }}

      it { is_expected.to create_file('/etc/raddb/conf/listen.inc/test_add_listen').with_content(/type = proxy/) }
    end
  end
end
