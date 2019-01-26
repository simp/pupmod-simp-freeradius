require 'spec_helper'

describe 'freeradius::conf::log' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      let(:facts) { facts }
      let(:pre_condition) { "include 'freeradius'" }

      context "on #{os}" do
        it { is_expected.to create_class('freeradius::conf::log') }
        it { is_expected.to create_file('/etc/raddb/conf.d/log.inc').with_content(<<-EOM)
log {
  destination = syslog
  file = /var/log/freeradius/radius.log
  syslog_facility = local6
  stripped_names = no
  auth = yes
  auth_badpass = no
  auth_goodpass = no
  msg_denied = "You are already logged in - access denied"
}
EOM
        }
      end
    end
  end
end
