require 'spec_helper'

describe 'freeradius::v3::listener', :type => :define do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      let(:facts) { facts }
      let(:pre_condition) {"include  'freeradius'"}
      context 'with default parameters' do
        let(:title) {'test1'}
        let(:params) {{
          :confdir     => '/etc/raddb',
          :listen_type => 'auth',
          :group       => 'radiusd'
        }}

        it { is_expected.to contain_concat('listener.test1') }
        it { is_expected.to contain_freeradius__v3__listen('/etc/raddb/conf.d/listener.test1-fragment')
#             .with({
#          :target             => '/etc/raddb/conf.d/listener.test1',
#          :order              => 100,
#          :listen_type        => 'auth',
#          :ipaddr             => 'ALL',
#          :port               => :undef,
#          :interface          => :undef,
#          :per_socket_clients => :undef,
#          :max_pps            => :undef,
#          :max_connections    => :undef,
#          :idle_timeout       => :undef
#        })
        }

      end
    end
  end
end
