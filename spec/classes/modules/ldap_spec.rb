require 'spec_helper'

describe 'freeradius::modules::ldap' do

  let(:facts) {{
    :operatingsystem   => 'RedHat',
    :radius_version    => '3.0.1',
    :lsbmajdistrelease => '7',
    :hardwaremodel     => 'x86_64',
    :grub_version      => '2',
    :uid_min           => '1000'
  }}

  context 'base' do
    it { should compile.with_all_deps }
    it { should create_class('freeradius::modules::ldap') }
    it { should create_class('freeradius::3::modules::ldap') }
  end
end
