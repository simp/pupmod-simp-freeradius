require 'spec_helper'

describe 'freeradius::v3::user', :type => :define do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      let(:facts) { facts }

      default_content = <<-EOF
Suffix == ".shell"
Service-Type = Login-User,
Login-Service = Telnet,
Login-IP-Host = your.shell.machine
EOF
      context 'add a user fragment' do
        let(:title) {'test_add_user'}
        let(:params) {{
          :content => 'test user stuff'
        }}

        it { is_expected.to contain_concat__fragment('radius_user_100.test_add_user').with({
          'target'  => '/etc/raddb/mods-config/files/authorize',
          'content' => 'test_add_user test user stuff'
        }) }
      end
      context 'add a default user fragment' do
        let(:title) {'user999'}
        let(:params) {{
          :content    =>  default_content,
          :is_default => true
        }}
        it { is_expected.to contain_concat__fragment('radius_user_100.user999').with({
          'target'  => '/etc/raddb/mods-config/files/authorize',
          'content' => <<-EOF
DEFAULT Suffix == ".shell"
        Service-Type = Login-User,
        Login-Service = Telnet,
        Login-IP-Host = your.shell.machine
EOF
        })}
      end

    end
  end
end
