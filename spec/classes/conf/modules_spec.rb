require 'spec_helper'

describe 'freeradius::conf::modules' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      let(:facts) { facts }

      context 'base_rhel_6' do
        let(:facts) { facts.merge({:grub_version => '2', :radius_version => '2'})}

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_class('freeradius::conf::modules') }
        it { is_expected.to create_file('/etc/raddb/conf/modules.inc').with_content(/eap.conf/) }
      end
      context 'rhel_6_include_sql' do
        let(:facts) { facts.merge({:grub_version => '2', :radius_version => '2'})}
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
        let(:facts) { facts.merge({:grub_version => '3', :radius_version => '3'})}

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_class('freeradius::conf::modules') }
        it { is_expected.to create_file('/etc/raddb/conf/modules.inc').with_content(/mods-enabled/) }
      end
      context 'rhel_7_include_sql' do
        let(:facts) { facts.merge({:grub_version => '3', :radius_version => '3'})}
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
  end
end
