require 'spec_helper'

describe 'freeradius::modules::ldap' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      let(:facts) { facts }

      context 'base v3' do
        let(:facts) { facts.merge({:radius_version => '3', :grub_version => '2'})}
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_class('freeradius::modules::ldap') }
        it { is_expected.to create_class('freeradius::v3::modules::ldap') }
      end
      context 'base v2' do
        let(:facts) { facts.merge({:radius_version => '2', :grub_version => '2'})}
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_class('freeradius::modules::ldap') }
        it { is_expected.to create_class('freeradius::v2::modules::ldap') }
      end
    end
  end
end
