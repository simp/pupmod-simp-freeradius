require 'spec_helper'

#  The logic is tested in the init_spec test.
#  These test were added to test the parameters and templates
describe 'freeradius::v3::conf' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do

        context 'with default parameters' do
          let(:facts) do
            facts.merge({
              :radius_version => '3',
              :hardwaremodel  => 'x86_64'
            })
          end
          # set parammeters from main module
          let(:params) {{
            :logdir               => '/var/log/freeradius',
            :trusted_nets         => ['127.0.0.1', '::1'],
            :firewall             => true,
          }}
          expected_content_radius_conf = File.read(File.join(File.dirname(__FILE__),
             '../../files/3/','radius.conf.default'))
          it {is_expected.to contain_file('/etc/raddb/radiusd.conf').with_content(expected_content_radius_conf)}
        end

        context 'with special params' do
          let(:facts) do
            facts.merge({
              :radius_version => '3',
              :hardwaremodel  => 'i386'
            })
          end
          let(:params) {{
            :cleanup_delay        => 10,
            :hostname_lookups     => 'yes',
            :localstatedir        => '/var/local',
            :max_request_time     => 120,
            :proxy_requests       => true,
            :max_requests         => 2024,
            :trusted_nets         => ['127.0.0.1', '::1'],
            :firewall             => true,
            :logdir               => '/var/log/radiusx'
          }}
          expected_content_radius_conf = File.read(File.join(File.dirname(__FILE__),
             '../../files/3/','radius.conf.with_params'))
          it {is_expected.to contain_file('/etc/raddb/radiusd.conf').with_content(expected_content_radius_conf)}

        end
      end
    end
  end
end
