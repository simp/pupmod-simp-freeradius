require 'spec_helper'

describe 'freeradius::conf::security' do
  let(:params) {{
    :max_attributes => '200'
  }}

  it { should create_class('freeradius::conf::security') }
  it { should create_file('/etc/raddb/conf/security.inc').with_content(/max_attributes = 200/) }
end
