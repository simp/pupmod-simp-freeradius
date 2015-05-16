require 'spec_helper'

describe 'freeradius::users' do

  it { should create_class('freeradius::users') }
  it { should create_file('/etc/raddb/users.inc').with_ensure('directory') }
  it { should create_file('/etc/raddb/users') }
end
