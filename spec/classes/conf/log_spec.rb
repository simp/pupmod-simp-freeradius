require 'spec_helper'

describe 'freeradius::conf::log' do

  it { should create_class('freeradius::conf::log') }
  it { should create_file('/etc/raddb/conf/log.inc') }
end
