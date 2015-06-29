require 'spec_helper'

describe 'freeradius::users' do

  it { is_expected.to create_class('freeradius::users') }
  it { is_expected.to create_file('/etc/raddb/users.inc').with_ensure('directory') }
  it { is_expected.to create_file('/etc/raddb/users') }
end
