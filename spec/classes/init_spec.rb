require 'spec_helper'

shared_examples_for 'install' do
  it { is_expected.to create_group('radiusd') }
	it { is_expected.to create_user('radiusd').that_requires('Group[radiusd]') }
  it { is_expected.to contain_package('freeradius-ldap') }
  it { is_expected.to contain_package('freeradius-utils') }
  it { is_expected.to contain_package('freeradius') }
end

shared_examples_for 'common config' do
	# freeradius::config
  it { is_expected.to compile.with_all_deps }
  it { is_expected.to create_class('freeradius') }
  it { is_expected.to contain_file('/etc/raddb') }
  it { is_expected.to contain_file('/etc/raddb/mods-enabled')}
  it { is_expected.to contain_file('/etc/raddb/mods-config')}
  it { is_expected.to contain_file('/etc/raddb/mods-available')}
  it { is_expected.to contain_file('/etc/raddb/sites-available')}
  it { is_expected.to contain_file('/etc/raddb/sites-enabled').with(:purge => false)}
end

shared_examples_for 'config with pki = false and firewall = false' do
  it { is_expected.to_not contain_class('pki') }
  it { is_expected.to_not contain_pki__copy('freeradius')}
  it { is_expected.to_not create_file('/etc/pki/simp_apps/freeradius/x509')}
  it { is_expected.to_not contain_iptables__listen__udp('radius_iptables_udp')}
  it { is_expected.to_not contain_iptables__listen__tcp_stateful('radius_iptables_tcp')}
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
  it { is_expected.to contain_iptables__listen__udp('radius_iptables_udp')}
  it { is_expected.to contain_iptables__listen__tcp_stateful('radius_iptables_tcp')}
end

shared_examples_for 'config v3' do
  it_should_behave_like 'common config'
  it_should_behave_like 'v3 conf users default'
  it { is_expected.to contain_class('freeradius::v3::radiusd_conf::log' )}
  it { is_expected.to contain_class('freeradius::v3::radiusd_conf::security' )}
  it { is_expected.to contain_class('freeradius::v3::radiusd_conf::thread_pool' )}
  it { is_expected.to contain_class('freeradius::v3::radiusd_conf::instantiate' )}
  it { is_expected.to contain_class('freeradius::v3::conf::users' )}
  it {is_expected.to contain_file('/etc/raddb/conf.d')}
  it {is_expected.to contain_file('/etc/raddb/clients.d')}
  it {is_expected.to contain_file('/var/log/freeradius')}
end

shared_examples_for 'v3 conf users default' do
  it { is_expected.to create_class('freeradius::v3::conf::users') }
  it { is_expected.to contain_concat('radius_user_file').with_path('/etc/raddb/mods-config/files/authorize') }
  it { is_expected.to contain_concat__fragment('radius_user_header').with_content(/# This file is managed by Puppet./) }
end

shared_examples_for 'use_rsync and testcerts' do
	it { is_expected.to contain_class('freeradius::config::rsync') }
	it { is_expected.to contain_class('rsync') }
  it { is_expected.to contain_file('/etc/raddb/radiusd.conf').with_content(nil)}
  it { is_expected.to contain_rsync('freeradius').with({
    :source  => "freeradius_#{environment}_#{facts[:os][:name]}/",
    :user    => "freeradius_systems_#{environment}_#{facts[:os][:name].downcase}",
    :server  => '127.0.0.1',
    :timeout => 2})
  }
  it { is_expected.to contain_file('/etc/raddb/certs')}
  it { is_expected.to contain_exec('/etc/raddb/certs/bootstrap')}
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

          context 'with manage sites enabled on ' do
            let(:params) {{
              :manage_sites_enabled => true
            }}
            it { is_expected.to contain_file('/etc/raddb/sites-enabled').with(:purge => true)}
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
            it_should_behave_like "use_rsync and testcerts"
          end

          #  Test v3 manifests
          context 'v3::conf with default parameters' do
            expected_content_radius_conf = File.read(File.join(File.dirname(__FILE__),
               '../files/3/','radius.conf.default'))
            expected_content_log = File.read(File.join(File.dirname(__FILE__),
               '../files/3/conf.d/','log.default'))
            expected_content_security = File.read(File.join(File.dirname(__FILE__),
               '../files/3/conf.d/','security.default'))
            expected_content_thread_pool = File.read(File.join(File.dirname(__FILE__),
               '../files/3/conf.d/','thread_pool.default'))
            it_should_behave_like 'config v3'
            it { is_expected.to_not contain_iptables__listen__udp('radius_iptables') }
            it {is_expected.to contain_file('/etc/raddb/radiusd.conf').with_content(expected_content_radius_conf)}
            it {is_expected.to contain_file('/etc/raddb/conf.d/log.inc').with_content(expected_content_log)}
            it {is_expected.to contain_file('/etc/raddb/conf.d/security.inc').with_content(expected_content_security)}
            it {is_expected.to contain_file('/etc/raddb/conf.d/thread_pool.inc').with_content(expected_content_thread_pool)}
            it {is_expected.to contain_file('/etc/raddb/conf.d/instantiate.inc').with_content(<<-EOM)
instantiate {
}
EOM
            }
          end

          context 'v3::conf with changed parameters' do
            let(:facts) do
              facts.merge({
                :radius_version => '3',
                :hardwaremodel  => 'i386',
              })
            end
            let(:hieradata) { 'conf_v3_params' }
            expected2_content_radius_conf = File.read(File.join(File.dirname(__FILE__),
               '../files/3/','radius.conf.with_params'))
            expected2_content_log = File.read(File.join(File.dirname(__FILE__),
               '../files/3/conf.d/','log.with_params'))
            expected2_content_security = File.read(File.join(File.dirname(__FILE__),
               '../files/3/conf.d/','security.with_params'))
            expected2_content_thread_pool = File.read(File.join(File.dirname(__FILE__),
               '../files/3/conf.d/','thread_pool.with_params'))

            it {is_expected.to contain_file('/etc/raddb/radiusd.conf').with_content(expected2_content_radius_conf)}
            it {is_expected.to contain_file('/etc/raddb/conf.d/log.inc').with_content(expected2_content_log)}
            it {is_expected.to contain_file('/etc/raddb/conf.d/security.inc').with_content(expected2_content_security)}
            it {is_expected.to contain_file('/etc/raddb/conf.d/thread_pool.inc').with_content(expected2_content_thread_pool)}
            it { is_expected.to contain_iptables__listen__udp('radius_iptables_udp') }
            it { is_expected.to contain_iptables__listen__tcp_stateful('radius_iptables_tcp') }
            it { is_expected.to_not contain_class('freeradius::v3::conf::users') }
            it { is_expected.to contain_file('/etc/raddb/clients.conf').with_source('/tmp/myclientsource') }
            it { is_expected.to contain_file('/etc/raddb/mods-config/files/authorize').with_source('/tmp/myusersource') }
          end
        end

        context 'version 2 (v2)' do
          let(:facts) do
            facts.merge({
              :radius_version => '2',
              :hardwaremodel  => 'x86_64',
            })
          end
          context 'default params' do
            it 'should fail' do
              expect {
                should raise_error(Puppet::Error, /This module is designed to work with freeradius version 3.X/)
              }
            end
          end
          context 'v2 with rsync ' do
            let(:hieradata) { "rsync_conf" }
            it_should_behave_like "use_rsync and testcerts"
            it { is_expected.to_not contain_class('freeradius::v3::conf')}
            it_should_behave_like 'config with pki = false and firewall = false'
          end
        end
      end
    end
  end
end
