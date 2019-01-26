# == Class: freeradius::v2::modules::ldap
#
# Set up the LDAP module configuration.
#
# == Parameters
#
# @param server     ldap server
# @param identity   ldap bind user
# @param password   ldap bind user password
# @param ldap_base_dn
# @param filter
# @param base_filter
# @param ldap_connections_number
# @param ldap_timeout
# @param ldap_timelimit
# @param net_timeout
# @param port      ldap port
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
#
class freeradius::v2::modules::ldap (
  Array[String]                $server                     = simplib::lookup('simp_options::ldap::uri', { 'default_value'     => ["ldap://%{hiera('simp_options::puppet::server')}"], 'value_type' => Array[String] }),
  String                       $identity                   = simplib::lookup('simp_options::ldap::bind_dn', { 'default_value' => "cn=hostAuth,ou=Hosts,%{hiera('simp_options::ldap::base_dn')}", 'value_type' => String }),
  String                       $password                   = simplib::lookup('simp_options::ldap::bind_pw', { 'value_type'    => String }),
  String                       $ldap_base_dn               = simplib::lookup('simp_options::ldap::base_dn', { 'value_type'    => String }),
  String                       $filter                     = '(uid=%{%{Stripped-User-Name}:-%{User-Name}})',
  String                       $base_filter                = '(objectclass=radiusprofile)',
  Integer                      $ldap_connections_number    = 5,
  Integer                      $ldap_timeout               = 4,
  Integer                      $ldap_timelimit             = 3,
  Integer                      $net_timeout                = 1,
  Simplib::Port                $port                       = 389,
  Variant[Boolean,Enum['ssl']] $start_tls                  = true,
  Stdlib::AbsolutePath         $app_pki_ca_dir             = $::freeradius::app_pki_ca_dir,
  Stdlib::AbsolutePath         $app_pki_cert               = $::freeradius::app_pki_cert,
  Stdlib::AbsolutePath         $app_pki_key                = $::freeradius::app_pki_key,
  Stdlib::AbsolutePath         $randfile                   = '/dev/urandom',
  String                       $require_cert               = 'demand',
  Optional[String]             $default_profile            = undef,
  Optional[String]             $profile_attribute          = undef,
  Optional[String]             $access_attr                = undef,
  Stdlib::AbsolutePath         $dictionary_mapping         = '/etc/raddb/ldap.attrmap',
  String                       $password_attribute         = 'userPassword',
  Boolean                      $edir_account_policy_check  = false,
  String                       $groupname_attribute        = 'cn',
  String                       $groupmembership_filter     = '(|(&(objectClass=GroupOfNames)(member=%{control:Ldap-UserDn}))(&(objectClass=GroupOfUniqueNames)(uniquemember=%{control:Ldap-UserDn})))',
  Optional[String]             $groupmembership_attribute  = undef,
  Boolean                      $compare_check_items        = false,
  Boolean                      $do_xlat                    = false,
  Boolean                      $access_attr_used_for_allow = false,
  Boolean                      $chase_referrals            = false,
  Boolean                      $rebind                     = false,
  Boolean                      $set_auth_type              = true,
  Optional[String]             $ldap_debug                 = undef
) {


  file { '/etc/raddb/modules/ldap':
    owner   => 'root',
    group   => 'radiusd',
    mode    => '0640',
    content => template('freeradius/2/modules/ldap.erb'),
    require => File['/etc/raddb/modules'],
    notify  => Service['radiusd']
  }

}
