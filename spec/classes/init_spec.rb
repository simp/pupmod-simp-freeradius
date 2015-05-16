require 'spec_helper'

describe 'freeradius' do
  base_facts = {
    :lsbmajdistrelease  => '6',
    :operatingsystem    => 'RedHat',
    :hardwaremodel      => 'x86_64',
    :grub_version       => '2',
    :uid_min            => '1000',
    :fqdn               => 'foo.test.domain'
  }

  let(:facts) {base_facts}

  it { should compile.with_all_deps }
  it { should create_class('freeradius') }
  it { should create_class('freeradius::modules') }
  it { should contain_package('freeradius-ldap.x86_64') }
  it { should contain_package('freeradius-utils.x86_64') }
  it { should contain_package('freeradius.x86_64').that_comes_before('Service[radiusd]') }
  it { should contain_package('freeradius-ldap.x86_64').that_comes_before('Service[radiusd]') }
  it { should contain_package('freeradius-utils.x86_64').that_comes_before('Service[radiusd]') }
  it { should create_service('radiusd').with({
      :ensure    => 'running',
      :require  => [
        'Package[freeradius.x86_64]',
        'Package[freeradius-ldap.x86_64]',
        'Package[freeradius-utils.x86_64]'
      ]
    })
  }
end
