require 'spec_helper'

default_header = <<-EOF
# This file is managed by Puppet.  Changes will be overwritten
# at the next puppet run.
#
server default {
EOF

default_listen_auth = <<-EOF
listen {
  type = auth
  ipaddr = *
  port = 0
  limit {
    lifetime = 0
    idle_timeout = 30
    max_connections = 16
  }
}
EOF

default_listen_acct = <<-EOF
listen {
  type = acct
  ipaddr = *
  port = 0
  limit {
  }
}
EOF

default_footer = <<-EOF
  authorize {
    filter_username
    preprocess
    suffix
    eap {
      ok = return
    }
    unix
    ldap
    if ((ok || updated) && User-Password)
      update {
        control:Auth-Type := ldap
      }
    }
    expiration
    logintime
    pap
  }
  authenticate {
    Auth-Type PAP {
      ldap
    }
    digest
    Auth-Type LDAP {
      ldap
    }
    eap
  }
  preacct {
    preprocess
    acct_unique
    suffix
    files
  }
  accounting {
    detail
    unix
    attr_filter.accounting_response
  }
  session {
  }
  post-auth {
    update {
       &reply: += &session-state:
    }
    -sql
    exec
    remove_reply_message_if_eap
    Post-Auth-Type REJECT {
      -sql
      attr_filter.access_reject
      eap
      remove_reply_message_if_eap
    }
  }
  pre-proxy {
  }
  post-proxy {
    eap
  }
}
EOF

describe 'freeradius::v3::sites::ldap' do
  context 'supported operating systems' do
    on_supported_os.each_value do |facts|
      let(:facts) { facts }
      let(:pre_condition) { 'include "freeradius"' }

      context 'base v3 with defaults' do
        let(:facts) { facts.merge({ radius_version: '3' }) }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_class('freeradius::v3::sites::ldap') }
        it { is_expected.to create_concat('site_simp_ldap_default').with_path('/etc/raddb/sites-available/simp-ldap-default') }
        it { is_expected.to create_concat__fragment('site_ldap_header').with_content(default_header) }
        it { is_expected.to create_concat__fragment('site_ldap_footer').with_content(default_footer) }
        it { is_expected.to create_concat__fragment('listen.site_ldap_auth.auth').with_content(default_listen_auth) }
        it { is_expected.to create_concat__fragment('listen.site_ldap_acct.acct').with_content(default_listen_acct) }
        it { is_expected.to create_file('/etc/raddb/sites-enabled/default').with_target('/etc/raddb/sites-available/simp-ldap-default') }
      end

      context 'with no listener' do
        let(:facts) { facts.merge({ radius_version: '3' }) }
        let(:params) do
          {
            'include_listener' => false
          }
        end

        it { is_expected.to create_concat__fragment('site_ldap_header').with_content(default_header) }
        it { is_expected.to create_concat__fragment('site_ldap_footer').with_content(default_footer) }
        it { is_expected.not_to create_concat__fragment('listen.site_ldap_auth.auth') }
        it { is_expected.not_to create_concat__fragment('listen.site_ldap_acct.acct') }
      end
    end
  end
end
