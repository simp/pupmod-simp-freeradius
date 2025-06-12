require 'spec_helper'

describe 'freeradius::v3::listener', type: :define do
  context 'supported operating systems' do
    on_supported_os.each_value do |facts|
      let(:facts) { facts }
      let(:pre_condition) { "include  'freeradius'" }
      context 'with default parameters' do
        let(:title) { 'test1' }
        let(:params) do
          {
            confdir: '/etc/raddb',
            listen_type: 'auth',
            group: 'radiusd',
          }
        end

        it { is_expected.to contain_concat('listener.test1') }
        it {
          is_expected.to contain_freeradius__v3__listen('/etc/raddb/conf.d/listener.test1-fragment')
            .with(
              target: '/etc/raddb/conf.d/listener.test1',
              order: 100,
              listen_type: 'auth',
              ipaddr: 'ALL',
              port: nil,
              interface: nil,
              per_socket_clients: nil,
              max_pps: nil,
              max_connections: nil,
              idle_timeout: nil,
            )
        }
      end
    end
  end
end
