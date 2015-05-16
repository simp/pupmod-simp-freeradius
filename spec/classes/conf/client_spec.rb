require 'spec_helper'

describe 'freeradius::conf::client' do

  it { should create_class('freeradius::conf::client') }
  it { should create_file('/etc/raddb/conf/clients').with_ensure('directory') }
end
