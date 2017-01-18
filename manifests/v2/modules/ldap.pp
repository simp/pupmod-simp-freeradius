# == Class: freeradius::v2::modules::ldap
#
# Set up the LDAP module configuration.
#
# == Parameters
#
# @param server
# @param identity
# @param password
# @param ldap_base_dn
# @param filter
# @param base_filter
# @param ldap_connections_number
# @param ldap_timeout
# @param ldap_timelimit
# @param net_timeout
# @param port
# @param start_tls
# @param app_pki_key
#   Path and name of the private SSL key file
#
# @param app_pki_cert
#   Path and name of the public SSL certificate
#
# @param app_pki_ca_dir
#   Path to the CA.
#
# @param randfile
# @param require_cert
# @param default_profile
# @param profile_attribute
# @param access_attr
# @param dictionary_mapping
# @param password_attribute
# @param edir_account_policy_check
# @param groupname_attribute
# @param groupmembership_filter
# @param groupmembership_attribute
#   If this does not contain a value then Group Membership Checking will not
#   be enabled.
#
# @param compare_check_items
# @param do_xlat
# @param access_attr_used_for_allow
# @param chase_referrals
# @param rebind
# @param set_auth_type
# @param ldap_debug
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
#
class freeradius::v2::modules::ldap (
  $server                     = simplib::lookup('simp_options::ldap::uri', { 'default_value'     => ["ldap://%{hiera('simp_options::puppet::server')}"], 'value_type' => Array[String] }),
  $identity                   = simplib::lookup('simp_options::ldap::bind_dn', { 'default_value' => "cn=hostAuth,ou=Hosts,%{hiera('simp_options::ldap::base_dn')}", 'value_type' => String }),
  $password                   = simplib::lookup('simp_options::ldap::bind_pw', { 'value_type'    => String }),
  $ldap_base_dn               = simplib::lookup('simp_options::ldap::base_dn', { 'value_type'    => String }),
  $filter                     = '(uid=%{%{Stripped-User-Name}:-%{User-Name}})',
  $base_filter                = '(objectclass=radiusprofile)',
  $ldap_connections_number    = '5',
  $ldap_timeout               = '4',
  $ldap_timelimit             = '3',
  $net_timeout                = '1',
  $port                       = '389',
  $start_tls                  = true,
  $app_pki_ca_dir             = $::freeradius::config::app_pki_ca_dir,
  $app_pki_cert               = $::freeradius::config::app_pki_cert,
  $app_pki_key                = $::freeradius::config::app_pki_key,
  $randfile                   = '/dev/urandom',
  $require_cert               = 'demand',
  $default_profile            = 'nil',
  $profile_attribute          = 'nil',
  $access_attr                = 'nil',
  $dictionary_mapping         = '/etc/raddb/ldap.attrmap',
  $password_attribute         = 'userPassword',
  $edir_account_policy_check  = false,
  $groupname_attribute        = 'cn',
  $groupmembership_filter     = '(|(&(objectClass=GroupOfNames)(member=%{control:Ldap-UserDn}))(&(objectClass=GroupOfUniqueNames)(uniquemember=%{control:Ldap-UserDn})))',
  $groupmembership_attribute  = 'nil',
  $compare_check_items        = false,
  $do_xlat                    = false,
  $access_attr_used_for_allow = false,
  $chase_referrals            = false,
  $rebind                     = false,
  $set_auth_type              = true,
  $ldap_debug                 = 'nil'
) {

  file { '/etc/raddb/modules/ldap':
    owner   => 'root',
    group   => 'radiusd',
    mode    => '0640',
    content => template('freeradius/2/modules/ldap.erb'),
    notify  => Service['radiusd']
  }

  validate_array_member($start_tls,[true,false,'ssl'])
  #validate_bool($edir_account_policy_check)
  #validate_bool($compare_check_items)
  #validate_bool($do_xlat)
  #validate_bool($access_attr_used_for_allow)
  #validate_bool($chase_referrals)
  #validate_bool($rebind)
  #validate_bool($set_auth_type)
}
