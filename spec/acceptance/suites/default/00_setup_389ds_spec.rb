require 'spec_helper_acceptance'

test_name 'Set up ds389 server '

describe 'Setup 389ds server for freeradius' do
  # stunnel just needs to be set, it does not effect this test
  stunnel_setting = true
  ldap_server = only_host_with_role(hosts, '389ds')
  ldap_server_fqdn = fact_on(ldap_server, 'fqdn')

  facter_found_domains = fact_on(ldap_server, 'domain').split('.')
  facter_found_domains.map! do |d|
    "dc=#{d}"
  end
  base_dn = facter_found_domains.join(',')
  common_hieradata = File.read(File.expand_path('files/common_hieradata.yaml.erb', File.dirname(__FILE__)))

  context 'setup 389ds ldap server ' do
    let(:root_pw)          { 'suP3rP@ssw0r!' }
    let(:ldap_type)        { '389ds' }
    let(:server_hieradata) { File.read(File.expand_path("files/#{ldap_type}/server_hieradata.yaml.erb", File.dirname(__FILE__))) }
    let(:hieradata)        { common_hieradata.to_s + "\n#{server_hieradata}" }
    let(:add_testuser)     { File.read(File.expand_path("files/#{ldap_type}/add_testuser.erb", File.dirname(__FILE__))) }
    let(:ds_root_name)     { 'accounts' }

    it 'installs 389ds accounts instance' do
      server_manifest = <<~EOM
        include 'simp_options'
        include 'simp_ds389::instances::accounts'
      EOM

      # Apply
      set_hieradata_on(ldap_server, ERB.new(hieradata).result(binding), 'default')
      apply_manifest_on(ldap_server, server_manifest, catch_failures: true)
      apply_manifest_on(ldap_server, server_manifest, catch_failures: true)
      apply_manifest_on(ldap_server, server_manifest, catch_changes: true)
    end

    # Create test users
    it 'adds the test users' do
      create_remote_file(ldap_server, '/root/ldap_add_user', ERB.new(add_testuser).result(binding))
      on(ldap_server, 'chmod +x /root/ldap_add_user')
      on(ldap_server, '/root/ldap_add_user')
      result = on(ldap_server, "dsidm #{ds_root_name} -b #{base_dn} user list")
      expect(result.stdout).to include('radius1')
      expect(result.stdout).to include('radius2')
      expect(result.stdout).to include('notradius')
    end
  end
end
