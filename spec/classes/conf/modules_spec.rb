require 'spec_helper'

describe 'freeradius::conf::modules' do

  base_facts_rhel_6 = {
    :operatingsystemmajrelease  => '6',
    :operatingsystem    => 'RedHat',
    :hardwaremodel      => 'x86_64',
    :radius_version     => '2',
    :grub_version       => '2',
    :uid_min            => '1000',
    :fqdn               => 'foo.example.com',
    :init_systems       => [ "rc", "upstart", "sysv" ]

  }
  base_facts_rhel_7 = {
    :operatingsystemmajrelease  => '7',
    :operatingsystem    => 'RedHat',
    :hardwaremodel      => 'x86_64',
    :radius_version     => '3',
    :grub_version       => '3',
    :uid_min            => '1000',
    :fqdn               => 'foo.example.com',
    :init_systems       => [ "rc", "systemd", "sysv" ]
  }

  context 'base_rhel_6' do
    let(:facts) {base_facts_rhel_6}

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to create_class('freeradius::conf::modules') }
    it { is_expected.to create_file('/etc/raddb/conf/modules.inc').with_content(/eap.conf/) }
  end
  context 'rhel_6_include_sql' do
    let(:facts) {base_facts_rhel_6}
    let(:params) {{
      :include_sql => true,
      :include_mysql_counter => true,
      :include_sqlippool => true
    }}

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to create_file('/etc/raddb/conf/modules.inc').with_content(/sql.conf/) }
    it { is_expected.to create_file('/etc/raddb/conf/modules.inc').with_content(/counter.conf/) }
    it { is_expected.to create_file('/etc/raddb/conf/modules.inc').with_content(/sqlippool.conf/) }
  end

  context 'base_rhel_7' do
    let(:facts) {base_facts_rhel_7}

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to create_class('freeradius::conf::modules') }
    it { is_expected.to create_file('/etc/raddb/conf/modules.inc').with_content(/mods-enabled/) }
  end
  context 'rhel_7_include_sql' do
    let(:facts) {base_facts_rhel_7}
    let(:params) {{
      :include_sql => true,
      :include_mysql_counter => true,
      :include_sqlippool => true
    }}

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to create_file('/etc/raddb/conf/modules.inc').with_content(/sql.conf/) }
    it { is_expected.to create_file('/etc/raddb/conf/modules.inc').with_content(/counter.conf/) }
    it { is_expected.to create_file('/etc/raddb/conf/modules.inc').with_content(/sqlippool.conf/) }
  end
end
