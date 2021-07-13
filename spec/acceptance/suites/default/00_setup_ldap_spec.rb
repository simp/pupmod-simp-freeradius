require 'spec_helper_acceptance'

test_name 'Set up ldap server '

describe 'Setup openldap  server for freeradius' do
  ldap_server = only_host_with_role(hosts,'ldap')
  ldap_server_fqdn = fact_on(ldap_server, 'fqdn')

  _domains = fact_on(ldap_server, 'domain').split('.')
  _domains.map! { |d|
    "dc=#{d}"
  }
  base_dn = _domains.join(',')

  common_hieradata = File.read(File.expand_path('files/common_hieradata.yaml.erb', File.dirname(__FILE__)))

  context 'setup ldap server ' do

    let(:ldap_type)        { 'plain' }
    let(:server_hieradata) { File.read(File.expand_path("files/#{ldap_type}/server_hieradata.yaml.erb", File.dirname(__FILE__)))}
    let (:hieradata){ "#{common_hieradata}" + "\n#{server_hieradata}"}


    let(:test_user_ldif) { ERB.new(File.read(File.expand_path("files/#{ldap_type}/add_users.ldif.erb",File.dirname(__FILE__)))).result(binding) }

    it 'should install, openldap, and create users' do


      server_manifest = <<-EOM
        include 'simp_options'
        include 'simp_openldap::server'
      EOM

      # Apply
      set_hieradata_on(ldap_server, ERB.new(hieradata).result(binding), 'default')
      apply_manifest_on(ldap_server, server_manifest, catch_failures: true)
      apply_manifest_on(ldap_server, server_manifest, catch_failures: true)
      apply_manifest_on(ldap_server, server_manifest, catch_changes: true)

    end
    it 'should create users on ldap server' do
      # Create test.user
      create_remote_file(ldap_server, '/root/user_ldif.ldif', test_user_ldif)

      # Create test users from ldif
      on(ldap_server, "ldapadd -D cn=LDAPAdmin,ou=People,#{base_dn} -H ldap://#{ldap_server} -w suP3rP@ssw0r! -x -Z -f /root/user_ldif.ldif")

      result = on(ldap_server, "ldapsearch -LLL -Z -D cn=LDAPAdmin,ou=People,#{base_dn} -H ldap://#{ldap_server_fqdn} -w suP3rP@ssw0r! -x cn=radius")
      expect(result.stdout).to include("dn: cn=radius,ou=Group,#{base_dn}")
      result2 = on(ldap_server, "ldapsearch -LLL -Z -D cn=LDAPAdmin,ou=People,#{base_dn} -H ldap://#{ldap_server_fqdn} -w suP3rP@ssw0r! -x cn=radius1")
      expect(result2.stdout).to include("dn: uid=radius1,ou=People,#{base_dn}")
    end

  end
end
