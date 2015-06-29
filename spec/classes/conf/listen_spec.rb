require 'spec_helper'

describe 'freeradius::conf::listen' do

  it { is_expected.to create_class('freeradius::conf::listen') }
  it { is_expected.to create_file('/etc/raddb/conf/listen.inc') }
end
