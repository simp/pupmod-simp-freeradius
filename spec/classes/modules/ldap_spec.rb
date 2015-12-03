require 'spec_helper'

describe 'freeradius::modules::ldap' do

  let(:facts) {{
    :operatingsystem   => 'RedHat',
    :radius_version    => '3.0.1',
    :operatingsystemmajrelease => '7',
    :hardwaremodel     => 'x86_64',
    :grub_version      => '2',
    :uid_min           => '1000'
  }}

  context 'base' do
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to create_class('freeradius::modules::ldap') }
    it { is_expected.to create_class('freeradius::3::modules::ldap') }
  end
end
