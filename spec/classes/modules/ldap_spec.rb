require 'spec_helper'

$file_v3 = "ca_path = /etc/radius_simp/pki/cacerts/\n    certificate_file = /etc/radius_simp/pki/public/foo.example.com.pub\n    private_key_file = /etc/radius_simp/pki/private/foo.example.com.pem\n"

$file_v2 = "ca_path = /etc/radius_simp/pki/cacerts/\n    certificate_file = /etc/radius_simp/pki/public/foo.example.com.pub\n    keyfile = /etc/radius_simp/pki/private/foo.example.com.pem\n"

describe 'freeradius::modules::ldap' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      let(:facts) { facts }

      context 'base v3' do
        let(:facts) { facts.merge({:radius_version => '3', :grub_version => '2'})}
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_class('freeradius::modules::ldap') }
        it { is_expected.to create_class('freeradius::v3::modules::ldap') }
        it { is_expected.to create_file('/etc/raddb/mods-enabled/ldap').with_content(/#{$file_v3}/)}
      end
      context 'base v2' do
        let(:facts) { facts.merge({:radius_version => '2', :grub_version => '2'})}
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_class('freeradius::modules::ldap') }
        it { is_expected.to create_class('freeradius::v2::modules::ldap') }
        it { is_expected.to create_file('/etc/raddb/modules/ldap').with_content(/#{$file_v2}/)}
      end
    end
  end
end
