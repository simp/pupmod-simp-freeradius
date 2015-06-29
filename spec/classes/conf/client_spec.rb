require 'spec_helper'

describe 'freeradius::conf::client' do

  it { is_expected.to create_class('freeradius::conf::client') }
  it { is_expected.to create_file('/etc/raddb/conf/clients').with_ensure('directory') }
end
