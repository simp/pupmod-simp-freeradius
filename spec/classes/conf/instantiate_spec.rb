require 'spec_helper'

describe 'freeradius::conf::instantiate' do

  it { should create_class('freeradius::conf::instantiate') }
  it { should create_file('/etc/raddb/conf/instantiate.inc').with_content(/logintime/) }

  context 'keep_defaults_false' do
    let(:params) {{
      :keep_defaults => false,
      :content       => 'test_content'
    }}

    it { should create_file('/etc/raddb/conf/instantiate.inc').with_content(/test_content/) }
  end
end
