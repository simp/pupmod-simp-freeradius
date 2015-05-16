require 'spec_helper'

describe 'freeradius::conf::listen' do

  it { should create_class('freeradius::conf::listen') }
  it { should create_file('/etc/raddb/conf/listen.inc') }
end
