require 'spec_helper'

describe 'freeradius::conf::listen::add', :type => :define do
  let(:title) {'test_add_listen'}
  let(:params) {{
    :listen_type => 'proxy'
  }}

  it { should create_file('/etc/raddb/conf/listen.inc/test_add_listen').with_content(/type = proxy/) }
end
