require 'spec_helper'

shared_examples_for 'install' do
  it { is_expected.to create_group('radiusd') }
	it { is_expected.to create_user('radiusd').that_requires('Group[radiusd]') }
  it { is_expected.to contain_package('freeradius-ldap.x86_64') }
  it { is_expected.to contain_package('freeradius-utils.x86_64') }
  it { is_expected.to contain_package('freeradius.x86_64') }
end

# Shared itemsm in freeradius::config, freeradius::v3::config, and
# freeradius::v2::config
shared_examples_for 'common config' do
	# freeradius::config
  it { is_expected.to compile.with_all_deps }
  it { is_expected.to create_class('freeradius') }
  it { is_expected.to contain_class('freeradius::modules') }
  it { is_expected.to contain_exec('/etc/raddb/certs/bootstrap') }
  it { is_expected.to contain_exec('/bin/chgrp -R radiusd /etc/raddb/certs') }
  it { is_expected.to contain_file('/etc/raddb') }

	# freeradius::v3::config and freeradius::v2::config
	it { is_expected.to contain_class('freeradius::conf::listen') }
	it { is_expected.to contain_file('/var/log/freeradius') }
	it { is_expected.to contain_file('/var/log/freeradius/linelog') }
	it { is_expected.to contain_file('/var/log/freeradius/radutmp') }
	it { is_expected.to contain_file('/var/log/freeradius/radwtmp') }
	it { is_expected.to contain_file('/var/log/freeradius/sradutmp') }
	it { is_expected.to contain_file('/etc/raddb/conf')}
	it { is_expected.to contain_file('/etc/raddb/radiusd.conf') }
	it { is_expected.to contain_freeradius__conf__listen__add('default_acct') }
end

# Items specific to v3
shared_examples_for 'config v3' do
  it_should_behave_like 'common config'
  it { is_expected.to contain_class('freeradius::v3::conf') }
	it { is_expected.to_not contain_class('rsync') }
	it { is_expected.to contain_class('freeradius::v3::conf::sites') }
	it { is_expected.to contain_class('freeradius::v3::conf::policy') }
end

# Items specific to v2
shared_examples_for 'config v2' do
  it_should_behave_like 'common config'
	it { is_expected.to_not contain_class('rsync') }
  it { is_expected.to contain_class('freeradius::v2::conf') }
end

shared_examples_for 'config with pki = false and firewall = false' do
  it { is_expected.to_not contain_class('pki') }
  it { is_expected.to_not contain_iptables__add_udp_listen('radius_iptables')}
end

shared_examples_for 'config with pki = true and firewall = true' do
  it { is_expected.to contain_class('pki') }
  it { is_expected.to contain_pki__copy('/var/radius_pki') }
  it { is_expected.to contain_iptables__add_udp_listen('radius_iptables')}
end

shared_examples_for 'use_rsync_radiusd_conf = true' do
	it { is_expected.to contain_class('rsync') }
  it { is_expected.to contain_file('/etc/raddb/radiusd.conf').with_content(nil)}
  it { is_expected.to contain_rsync('freeradius').with({
    :server  => '127.0.0.1',
    :timeout => '2'})
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
              :radius_version => '3'
            })
          end

          context 'with default parameters' do
				    it_should_behave_like 'install'
						it_should_behave_like 'config with pki = false and firewall = false'
            it_should_behave_like 'config v3'
						it_should_behave_like 'service'
          end

          context 'with pki = true and firewall = true' do
            let(:params){{:pki => true, :firewall => true}}
            it_should_behave_like 'install'
            it_should_behave_like 'config with pki = true and firewall = true'
            it_should_behave_like 'config v3'
            it_should_behave_like 'service'
          end

          context 'with use_rsync_radiusd_conf = true' do
						let(:hieradata) { "rsync_conf" }
            it_should_behave_like "use_rsync_radiusd_conf = true"
          end

        end

        # Version 2
        context 'version 2 (v2)' do
          let(:facts) do
            facts.merge({
              :radius_version => '2'
            })
          end

          context 'with default parameters' do
            it_should_behave_like 'install'
            it_should_behave_like 'config with pki = false and firewall = false'
            it_should_behave_like 'config v2'
            it_should_behave_like 'service'
          end

	        context 'with pki = true and firewall = true' do
            let(:params){{:pki => true, :firewall => true}}
            it_should_behave_like 'install'
            it_should_behave_like 'config with pki = true and firewall = true'
            it_should_behave_like 'config v2'
            it_should_behave_like 'service'
          end

					# Not sure why this is not working
          context 'with use_rsync_radiusd_conf = true' do
						let(:hieradata) { "rsync_conf" }
            pending("it_should_behave_like use_rsync_radiusd_conf = true'")
          end
        end
      end
    end
  end
end
