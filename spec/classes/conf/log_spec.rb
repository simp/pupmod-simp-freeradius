require 'spec_helper'

describe 'freeradius::conf::log' do

  it { is_expected.to create_class('freeradius::conf::log') }
  it { is_expected.to create_file('/etc/raddb/conf/log.inc') }
end
