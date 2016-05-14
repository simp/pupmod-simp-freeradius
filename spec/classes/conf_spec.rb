require 'spec_helper'

describe 'freeradius::conf' do
  context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      if ['RedHat','CentOS'].include?(os_facts[:operatingsystem]) &&
                                      os_facts[:operatingsystemmajrelease].to_s < '7'
        let(:facts) { os_facts.merge({ :radius_version    => '2.1.0' })}
        let(:ver){ 'v2' }
      else
        let(:facts) { os_facts.merge({ :radius_version    => '3.0.1' })}
        let(:ver){ 'v3' }
      end

      context "on #{os}" do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_class("freeradius::#{ver}::conf") }
        it { is_expected.to create_file('/var/log/freeradius').with_ensure('directory') }
        it { is_expected.to create_file('/etc/raddb/radiusd.conf').with_content(/raddbdir/) }
      end
    end
  end
end
