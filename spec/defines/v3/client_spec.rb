require 'spec_helper'

describe 'freeradius::v3::client', type: :define do
  context 'supported operating systems' do
    on_supported_os.each_value do |facts|
      let(:facts) { facts }
      let(:pre_condition) { "include  'freeradius'" }
      context 'with default parameters' do
        let(:title) { 'test_client' }
        let(:params) do
          {
            ipaddr: '1.2.3.4',
            secret: 'MyLittlePony',
          }
        end

        it { is_expected.to create_file('/etc/raddb/clients.d') }
        it {
          is_expected.to create_file('/etc/raddb/clients.d/test_client.conf').with_content(<<~EOM)
            client test_client {
              ipaddr = 1.2.3.4
              secret = MyLittlePony
              require_message_authenticator = yes
            }
          EOM
        }
      end

      context 'with non-default parameters' do
        let(:title) { 'test2_client' }
        let(:params) do
          {
            ipaddr: '2620:0:2d0:200::7/32',
            secret: 'MyLittlePony',
            nas_type: 'cisco',
            coa_server: 'TwilightSparkle',
            login: 'RainbowDash',
            password: 'FlutterShy',
            virtual_server: 'PinkiePie',
            shortname: 'Scootaloo',
          }
        end

        it { is_expected.to create_file('/etc/raddb/clients.d') }
        it {
          is_expected.to create_file('/etc/raddb/clients.d/test2_client.conf').with_content(<<~EOM)
            client test2_client {
              ipv6addr = 2620:0:2d0:200::7/32
              secret = MyLittlePony
              shortname = Scootaloo
              require_message_authenticator = yes
              nas_type = cisco
              login = RainbowDash
              password = FlutterShy
              virtual_server = PinkiePie
              coa_server = TwilightSparkle
            }
          EOM
        }
      end
    end
  end
end
