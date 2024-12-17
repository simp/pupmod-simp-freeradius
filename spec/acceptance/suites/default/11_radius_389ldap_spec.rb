require 'spec_helper_acceptance'

test_name 'freeradius class'

describe 'freeradius class' do
  servers = hosts_with_role(hosts, 'server')
  ldapserver = find_at_most_one_host_with_role(hosts, '389ds') # There can only be one.

  let(:ldap_server_fqdn) { fact_on(ldapserver, 'fqdn') }
  let(:ldap_type) { '389ds' }
  let(:base_dn) { fact_on(ldapserver, 'domain').split('.').map { |d| "DC=#{d}" }.join(',') }
  let(:results_base_dn) { fact_on(ldapserver, 'domain').split('.').map { |d| "dc=#{d}" }.join(',') }

  let(:radiusserver_useldap_only_manifest) do
    <<-EOR
    # This class will set up the simp default site which allows only ldap
    #  authentication.  Note:  the ldap module is set up because
    #  freeradius::ldap = true. (see hieradata)
      include 'freeradius'
      include 'simp_openldap::client'
      include 'freeradius::v3::modules::ldap'
      include 'freeradius::v3::sites::ldap'
      Class['simp_openldap::client'] -> Class['freeradius']

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
          ipaddr                        => '127.0.0.1',
          secret                        => 'testing123',
          require_message_authenticator => false,
          nas_type                      => 'other',
        }
    EOR
  end

  let(:the_hieradata) { ERB.new(File.read(File.expand_path('files/common_hieradata.yaml.erb', File.dirname(__FILE__)))).result(binding) }

  context 'set up radius server to use ldap only' do
    servers.each do |server|
      it 'configures the radius server' do
        set_hieradata_on(server, the_hieradata)
        apply_manifest_on(server, radiusserver_useldap_only_manifest, catch_failures: true)
        apply_manifest_on(server, radiusserver_useldap_only_manifest, catch_failures: true)
        apply_manifest_on(server, radiusserver_useldap_only_manifest, catch_changes: true)
      end

      it 'does not authenticate testuser' do
        result = on(server, 'radtest testuser password localhost 0 testing123', accept_all_exit_codes: true)
        expect(result.stdout).to include('Received Access-Reject')
      end
      it 'authenticates ldap user' do
        resultldap = on(server, 'radtest radius1 suP3rP@ssw0r! localhost 0 testing123')
        expect(resultldap.stdout).to include('Received Access-Accept')
      end
    end
  end
end
