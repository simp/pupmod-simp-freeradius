require 'spec_helper_acceptance'

test_name 'freeradius class'

describe 'freeradius class' do

  clients = hosts_with_role(hosts, 'client')
  servers = hosts_with_role(hosts, 'server')
  ldapserver = find_at_most_one_host_with_role(hosts,'ldap')   # There can only be one.

  let(:ldapserver_fqdn) {fact_on(ldapserver, 'fqdn')}
  let(:base_dn) { fact_on(ldapserver, 'domain').split('.').map{ |d| "DC=#{d}" }.join(',') }
  let(:results_base_dn) { fact_on(ldapserver, 'domain').split('.').map{ |d| "dc=#{d}" }.join(',') }
  let(:add_users)   { File.read(File.expand_path('templates/add_users.ldif.erb', File.dirname(__FILE__))) }

  let(:ldapserver_manifest) {
    <<-EOS
      include 'simp_openldap::server'
      EOS
  }

  let(:manifest) {
    <<-EOS
      class { 'freeradius':
         app_pki_external_source => '/etc/pki/simptest',
         pki                     => 'simp'
      }
    EOS
  }

  context 'setup ldap server' do
    let(:ldapserver_hieradata)  { ERB.new(File.read(File.expand_path('templates/ldap_with_tls.hieradata.erb', File.dirname(__FILE__)))).result(binding) }

    it 'should configure ldapserver' do
      set_hieradata_on(ldapserver, ldapserver_hieradata)
      apply_manifest_on(ldapserver, ldapserver_manifest, :catch_failures => true)
    end

    #sanity check
    it 'should be able to connect using tls and use ldapsearch' do
      on(ldapserver, "ldapsearch -ZZ -LLL -D cn=LDAPAdmin,ou=People,#{base_dn} -H ldap://#{ldapserver_fqdn} -x -w suP3rP@ssw0r!")
    end

    it 'should add test users ' do
      create_remote_file(ldapserver, '/tmp/add_users.ldif', ERB.new(add_users).result(binding))
      on(ldapserver, "ldapadd -Z -D cn=LDAPAdmin,ou=People,#{base_dn} -H ldap://#{ldapserver_fqdn} -w suP3rP@ssw0r! -x -f /tmp/add_users.ldif")
      result = on(ldapserver, "ldapsearch -LLL -Z -D cn=LDAPAdmin,ou=People,#{base_dn} -H ldap://#{ldapserver_fqdn} -w suP3rP@ssw0r! -x cn=radius")
      expect(result.stdout).to include("dn: cn=radius,ou=Group,#{results_base_dn}")
      result2 = on(ldapserver, "ldapsearch -LLL -Z -D cn=LDAPAdmin,ou=People,#{base_dn} -H ldap://#{ldapserver_fqdn} -w suP3rP@ssw0r! -x cn=radius1")
      expect(result2.stdout).to include("dn: uid=radius1,ou=Radiusclient,#{results_base_dn}")
    end

  end

  context 'set up radius server' do

    servers.each do |server|
    end
  end

#  clients.each do |client|
#  end
end

#  hosts.each do |host|
#    context 'with defaults' do
#      let(:hieradata) {{
#        'simp_options::auditd'    => false,
#        'simp_options::syslog'    => false,
#        'simp_options::logrotate' => false,
#        'auditd::enable'          => false,
#      }}
#
#      it 'should work with no errors' do
#        set_hieradata_on(host, hieradata)
#        # It needs to apply twice because it needs to know what version is
#        # installed in order to configure it.
#        apply_manifest_on(host, manifest, :catch_failures => true)
#        apply_manifest_on(host, manifest, :catch_failures => true)
#      end
#
#      it 'should be idempotent' do
#        apply_manifest_on(host, manifest, :catch_changes => true)
#      end
#
##      it "'aide' package should be installed" do
##        check_for_package(host, 'aide')
##      end
##
##      it 'should generate the database' do
##        on(host, 'ls /var/lib/aide/aide.db.gz')
##      end
##
##      it 'should retain the output database for SCAP xccdf_org.ssgproject.content_rule_aide_build_database' do
##        on(host, 'ls /var/lib/aide/aide.db.new.gz')
##      end
#
##      it 'should generate an empty report when no problems are found' do
##        on(host, '/usr/local/sbin/update_aide')
##        on(host, '/usr/sbin/aide --check')
##        report = on(host, 'cat /var/log/aide/aide.report').stdout
##        expect(report).to eq ''
##      end
#
##      it 'should generate a valid report when problems are found' do
##        on(host, 'touch /etc/yum.conf')
##        on(host, '/usr/sbin/aide --check', :acceptable_exit_codes => changes_detected)
##        on(host, "grep 'found differences between database and filesystem' /var/log/aide/aide.report")
##        on(host, "grep 'changed: /etc/yum.conf' /var/log/aide/aide.report")
##      end
#
##      it 'should not generate /var/log/aide/aide.log' do
##        on(host, 'ls /var/log/aide/aide.log', :acceptable_exit_codes => 2)
##      end
##    end
#
##    context 'with syslog and logrotate enabled' do
##      let(:hieradata) {{
##        'simp_options::auditd'    => false ,
##        'simp_options::syslog'    => true ,
##        'simp_options::logrotate' => true,
##        'aide::syslog_format'     => true,
##        'auditd::enable'          => false,
##       }}
#
##      it 'should work with no errors' do
##        set_hieradata_on(host, hieradata)
##        apply_manifest_on(host, manifest, :catch_failures => true)
##        # rsyslog changes require a second run
##        apply_manifest_on(host, manifest, :catch_failures => true)
##      end
#
##      it 'should be idempotent' do
##        apply_manifest_on(host, manifest, :catch_changes => true)
##      end
#
##      it 'should generate an empty report and log nothing when no problems are found' do
##        on(host, '/usr/local/sbin/update_aide')
##        on(host, 'logrotate --force /etc/logrotate.simp.d/aide')
##        on(host, '/usr/sbin/aide --check')
##        report = on(host, 'cat /var/log/aide/aide.report').stdout
##        expect(report).to eq ''
##        log = on(host, 'cat /var/log/aide/aide.log').stdout
##        expect(log).to eq ''
##      end
#
#    end
