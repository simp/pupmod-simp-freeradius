require 'spec_helper'

shared_examples_for 'install' do
  it { is_expected.to create_group('radiusd') }
	it { is_expected.to create_user('radiusd').that_requires('Group[radiusd]') }
  it { is_expected.to contain_package('freeradius-ldap') }
  it { is_expected.to contain_package('freeradius-utils') }
  it { is_expected.to contain_package('freeradius') }
  it { is_expected.to contain_exec('/etc/raddb/certs/bootstrap') }
end

# Shared itemsm in freeradius::config, freeradius::v3::config, and
# freeradius::v2::config
shared_examples_for 'common config' do
	# freeradius::config
  it { is_expected.to compile.with_all_deps }
  it { is_expected.to create_class('freeradius') }
  it { is_expected.to contain_file('/etc/raddb') }
  it { is_expected.to contain_file('/etc/raddb/certs').with(:recurse => true) }

end

# Items specific to v3
shared_examples_for 'config v3' do
  it_should_behave_like 'common config'
  it { is_expected.to contain_class('freeradius::v3::conf') }
	it { is_expected.to_not contain_class('rsync') }
end

shared_examples_for 'config with pki = false and firewall = false' do
  it { is_expected.to_not contain_class('pki') }
  it { is_expected.to_not contain_pki__copy('freeradius')}
  it { is_expected.to_not create_file('/etc/pki/simp_apps/freeradius/x509')}
  it { is_expected.to_not contain_iptables__listen__udp('radius_iptables')}
end

shared_examples_for 'config with pki = true' do
  it { is_expected.to_not contain_class('pki')}
  it { is_expected.to create_file('/etc/pki/simp_apps/freeradius/x509') }
  it { is_expected.to contain_pki__copy('freeradius').with(:source => '/etc/pki/simp/x509') }
end

shared_examples_for 'config with pki = simp and firewall = true' do
  it { is_expected.to contain_class('pki') }
  it { is_expected.to create_file('/etc/pki/simp_apps/freeradius/x509') }
  it { is_expected.to contain_pki__copy('freeradius').with(:source => '/etc/pki/simp/x509') }
  it { is_expected.to contain_iptables__listen__udp('radius_iptables')}
end

shared_examples_for 'use_rsync_radiusd_conf = true' do
	it { is_expected.to contain_class('rsync') }
  it { is_expected.to contain_file('/etc/raddb/radiusd.conf').with_content(nil)}
  it { is_expected.to contain_rsync('freeradius').with({
    :source  => "freeradius_#{environment}_#{facts[:os][:name]}/",
    :user    => "freeradius_systems_#{environment}_#{facts[:os][:name].downcase}",
    :server  => '127.0.0.1',
    :timeout => 2})
  }
end

shared_examples_for 'service' do
  it { is_expected.to create_service('radiusd').with_ensure('running') }
end

describe 'freeradius' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts){ facts }

        # Version 3
				context 'version 3 (v3)' do
          let(:facts) do
            facts.merge({
              :radius_version => '3',
              :hardwaremodel  => 'x86_64'
            })
          end

          context 'with default parameters' do
				    it_should_behave_like 'install'
						it_should_behave_like 'config with pki = false and firewall = false'
            it_should_behave_like 'config v3'
						it_should_behave_like 'service'
          end

          context 'with pki = true' do
            let(:params){{:pki => true}}
            it_should_behave_like 'config with pki = true'
          end

          context 'with pki = simp and firewall = true' do
            let(:params){{:pki => 'simp', :firewall => true}}
            it_should_behave_like 'install'
            it_should_behave_like 'config with pki = simp and firewall = true'
            it_should_behave_like 'config v3'
            it_should_behave_like 'service'
          end

          context 'with use_rsync_radiusd_conf = true' do
						let(:hieradata) { "rsync_conf" }
            it_should_behave_like "use_rsync_radiusd_conf = true"
          end

          context 'with use_rsync_radiusd_conf = true' do
						let(:hieradata) { "rsync_conf" }
            it_should_behave_like "use_rsync_radiusd_conf = true"
          end
        end
      end
    end
  end
end
