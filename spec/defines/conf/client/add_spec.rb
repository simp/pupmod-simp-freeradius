require 'spec_helper'

describe 'freeradius::conf::client::add', :type => :define do
  let(:title) {'test_client'}
  let(:params) {{
    :ipaddr => '1.2.3.4.'
  }}

  it { is_expected.to create_file('/etc/raddb/conf/clients/test_client.conf') }
end
