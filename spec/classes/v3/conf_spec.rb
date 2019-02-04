require 'spec_helper'

shared_examples_for 'conf v3 no rsync' do
  it { is_expected.to_not contain_class('rsync') }
  it { is_expected.to contain_class('freeradius::v3::conf::sites' )}
  it { is_expected.to contain_class('freeradius::v3::modules' )}
  it { is_expected.to contain_class('freeradius::conf::log' )}
  it { is_expected.to contain_class('freeradius::conf::security' )}
  it { is_expected.to contain_class('freeradius::conf::thread_pool' )}
  it {is_expected.to contain_file('/etc/raddb/conf.d')}
  it {is_expected.to contain_file('/var/log/freeradius')}
end
#  The logic is tested in the init_spec test.
#  These test were added to test the parameters and templates
describe 'freeradius::v3::conf' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do

        let(:common_params) {{
            :firewall       => false,
            :sysconfdir     => '/etc',
            :confdir        => '/etc/raddb',
            :logdir         => '/var/log/freeradius',
            :trusted_nets   => ['127.0.0.1', '::1'],
        }}

        let(:pre_condition) { 'include "freeradius::service"'}

        context 'with default parameters' do
          let(:facts) do
            facts.merge({
              :radius_version => '3',
              :hardwaremodel  => 'x86_64'
            })
          end
          # set parammeters from main module
          let(:params) { common_params.merge( { :firewall => true } ) }
          expected_content_radius_conf = File.read(File.join(File.dirname(__FILE__),
             '../../files/3/','radius.conf.default'))

          it_should_behave_like 'conf v3 no rsync'
          it { is_expected.to contain_iptables__listen__udp('radius_iptables') }
          it { is_expected.to_not contain_class('rsync') }
          it {is_expected.to contain_file('/etc/raddb/radiusd.conf').with_content(expected_content_radius_conf)}
        end

        context 'with special params' do
          let(:facts) do
            facts.merge({
              :radius_version => '3',
              :hardwaremodel  => 'i386'
            })
          end
          let(:params) {common_params.merge ( {
            :cleanup_delay        => 10,
            :hostname_lookups     => 'yes',
            :localstatedir        => '/var/local',
            :max_request_time     => 120,
            :proxy_requests       => true,
            :max_requests         => 2024,
            :include_trigger      => true,
          })}
          expected_content_radius_conf = File.read(File.join(File.dirname(__FILE__),
             '../../files/3/','radius.conf.with_params'))

          it_should_behave_like 'conf v3 no rsync'
          it {is_expected.to contain_file('/etc/raddb/radiusd.conf').with_content(expected_content_radius_conf)}
        end

        context 'with rsync'  do
          let(:facts) do
            facts.merge({
              :radius_version => '3',
              :hardwaremodel  => 'x86_64'
            })
          end
          let(:params) { common_params.merge ( {
            :use_rsync_radiusd_conf => true
          } ) }

          it { is_expected.to contain_class('rsync') }
          it {is_expected.to contain_file('/etc/raddb/radiusd.conf')}
        end

      end
    end
  end
end
