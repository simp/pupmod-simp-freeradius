# == Class: freeradius::v2::modules::ldap
#
# Set up the LDAP module configuration.
#
# == Parameters
#
# [*server*]
# [*identity*]
# [*password*]
# [*ldap_base_dn*]
# [*filter*]
# [*base_filter*]
# [*ldap_connections_number*]
# [*ldap_timeout*]
# [*ldap_timelimit*]
# [*net_timeout*]
# [*port*]
# [*start_tls*]
# [*app_pki_ca_dir*]
# [*app_pki_ca*]
#   If you change this from the default, you will need to ensure that you
#   manage the file and that apache restarts when the file is updated.
#
# [*app_pki_key*]
#   If you change this from the default, you will need to ensure that you
#   manage the file and that apache restarts when the file is updated.
#
# [*randfile*]
# [*require_cert*]
# [*default_profile*]
# [*profile_attribute*]
# [*access_attr*]
# [*dictionary_mapping*]
# [*password_attribute*]
# [*edir_account_policy_check*]
# [*groupname_attribute*]
# [*groupmembership_filter*]
# [*groupmembership_attribute*]
#   If this does not contain a value then Group Membership Checking will not
#   be enabled.
#
# [*compare_check_items*]
# [*do_xlat*]
# [*access_attr_used_for_allow*]
# [*chase_referrals*]
# [*rebind*]
# [*set_auth_type*]
# [*ldap_debug*]
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
  $app_pki_ca_dir             = '/etc/pki/cacerts',
  $app_pki_ca                 = "/etc/pki/public/${::fqdn}.pub",
  $app_pki_key                = "/etc/pki/private/${::fqdn}.pem",
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
