require 'spec_helper'

describe 'freeradius::conf::thread_pool' do
  let(:params) {{
    :max_servers => '32'
  }}

  it { is_expected.to create_class('freeradius::conf::thread_pool') }
  it { is_expected.to create_file('/etc/raddb/conf/thread_pool.inc').with_content(/max_servers = 32/) }
end
