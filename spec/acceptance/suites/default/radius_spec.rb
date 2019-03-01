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

  let(:radiusserver_manifest) {
    <<-EOR
      include 'simp_openldap::client'

      include 'freeradius'

      Class['simp_openldap::client'] -> Class['freeradius']

      #setup a test user, localclient and remote client"
      $_testuser = @("EOTU"/L)
        Cleartext-Password := "password"
        Reply-Message := "Hello World"
       | EOTU

        freeradius::v3::conf::user { 'testuser':
          content => $_testuser
        }

        freeradius::v3::client { 'localhost':
          ipaddr => '127.0.0.1',
          secret => 'testing123',
          require_message_authenticator => false,
          nas_type => 'other',
          }

        freeradius::v3::client { 'mynetwork':
          ipaddr => '10.0.71.0/24',
          secret => 'testing123'
          }
    EOR
  }

  let(:radiusserver_useldap_only_manifest) {
    <<-EOR
    # This class will set up the simp default site which allows only ldap
    #  authentication.  Note:  the ldap module is set up because
    #  freeradius::ldap = true. (see hieradata)
      include 'freeradius'
      include 'freeradius::v3::modules::ldap'
      include 'freeradius::v3::sites::ldap'

      Class['freeradius'] -> [Class['freeradius::v3::sites::ldap'],Class['freeradius::v3::modules::ldap']]

      #setup a test user, localclient and remote client"
      $_testuser = @("EOTU"/L)
        Cleartext-Password := "password"
        Reply-Message := "Hello World"
       | EOTU

        freeradius::v3::conf::user { 'testuser':
          content => $_testuser
        }

        freeradius::v3::client { 'localhost':
          ipaddr => '127.0.0.1',
          secret => 'testing123',
          require_message_authenticator => false,
          nas_type => 'other',
          }
    EOR
  }


  let(:the_hieradata)  { ERB.new(File.read(File.expand_path('templates/ldap_with_tls.hieradata.erb', File.dirname(__FILE__)))).result(binding) }

  context 'setup ldap server' do

    it 'should configure ldapserver' do
      set_hieradata_on(ldapserver, the_hieradata)
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
      expect(result2.stdout).to include("dn: uid=radius1,ou=People,#{results_base_dn}")
    end

  end

  context 'set up radius server' do

    servers.each do |server|
      it 'should configure the radius server' do
        set_hieradata_on(server, the_hieradata)
        apply_manifest_on(server, radiusserver_manifest)
        # it takes two runs because it needs to know the version.
        apply_manifest_on(server, radiusserver_manifest, :catch_failures => true)
      end

      it 'should authenticate testuser' do
        result = on(server, "radtest testuser password localhost 0 testing123")
        expect(result.stdout).to include("Hello World")
      end
    end
  end

  context 'set up radius server to use ldap only' do

    servers.each do |server|
      it 'should configure the radius server' do
        apply_manifest_on(server,radiusserver_useldap_only_manifest)
      end

      it 'should not authenticate testuser' do
        result = on(server, "radtest testuser password localhost 0 testing123", :accept_all_exit_codes => true )
        expect(result.stdout).to include("Received Access-Reject")
      end

      it 'should authenticate ldap user' do
        resultldap = on(server,"radtest radius1 foobarbaz localhost 0 testing123")
        expect(resultldap.stdout).to include("Received Access-Accept")
      end
    end
  end

end
