# == Class: freeradius::v3::modules::ldap
#
# Set up the LDAP module configuration.
#
# == Parameters
#
# @param base_dn
#
# @param app_pki_key
#   Path and name of the private SSL key file
#
# @param app_pki_cert
#   Path and name of the public SSL certificate
#
# @param app_pki_ca_dir
#   Path to the CA.
#
# @param base_filter
# @param client_scope
# @param client_attribute_identifier
# @param client_attribute_secret
# @param client_attribute_shortname
# @param client_attribute_nas_type
# @param client_attribute_virtual_server
# @param client_attribute_require_message_authenticator
# @param default_profile
# @param filter
# @param group_scope
# @param group_name_attribute
# @param group_membership_filter
#
# @param group_membership_attribute
#   If this does not contain a value then Group Membership Checking will not
#   be enabled.
#
# @param group_cacheable_name
# @param group_cacheable_dn
# @param identity
# @param ldap_connections_number
# @param ldap_debug
# @param ldap_timeout
# @param ldap_timelimit
# @param options_chase_referrals
# @param options_idle
# @param options_interval
# @param options_net_timeout
# @param options_probes
# @param options_rebind
# @param password
# @param pool_start
# @param pool_min
# @param pool_max
# @param pool_spare
# @param pool_uses
# @param pool_lifetime
# @param pool_idle_timeout
# @param port
# @param profile_attribute
# @param random_file
# @param require_cert
# @param start_tls
# @param user_access_attribute
# @param user_access_positive
# @param user_scope
# @param server
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
#
class freeradius::v3::modules::ldap (
  String                       $ldap_base_dn                                   = simplib::lookup('simp_options::ldap::base_dn'),
  String                       $password                                       = simplib::lookup('simp_options::ldap::bind_pw'),
  String                       $identity                                       = simplib::lookup('simp_options::ldap::bind_dn', { 'default_value' => "cn=hostAuth,ou=Hosts,%{lookup('simp_options::ldap::base_dn')}", 'value_type' => String }),
  Array[Simplib::Uri]          $server                                         = simplib::lookup('simp_options::ldap::uri', { 'default_value'     => ["ldap://%{lookup('simp_options::puppet::server')}"]}),
  Stdlib::AbsolutePath         $app_pki_ca_dir                                 = $::freeradius::app_pki_ca_dir,
  Stdlib::AbsolutePath         $app_pki_cert                                   = $::freeradius::app_pki_cert,
  Stdlib::AbsolutePath         $app_pki_key                                    = $::freeradius::app_pki_key,
  String                       $base_filter                                    = '(objectclass=radiusprofile)',
  Optional[Freeradius::Scope]  $client_scope                                   = undef,
  String                       $client_attribute_identifier                    = 'radiusClientIdentifier',
  String                       $client_attribute_secret                        = 'radiusClientSecret',
  Optional[String]             $client_attribute_shortname                     = undef,
  Optional[String]             $client_attribute_nas_type                      = undef,
  Optional[String]             $client_attribute_virtual_server                = undef,
  Optional[String]             $client_attribute_require_message_authenticator = undef,
  Optional[String]             $default_profile                                = undef,
  String                       $filter                                         = '(uid=%{%{Stripped-User-Name}:-%{User-Name}})',
  Optional[Freeradius::Scope]  $group_scope                                    = undef,
  String                       $group_name_attribute                           = 'cn',
  String                       $group_membership_filter                        = '(|(&(objectClass=GroupOfNames)(member=%{control:Ldap-UserDn}))(&(objectClass=GroupOfUniqueNames)(uniquemember=%{control:Ldap-UserDn})))',
  String                       $group_membership_attribute                     = 'radiusGroupName',
  Boolean                      $group_cacheable_name                           = false,
  Boolean                      $group_cacheable_dn                             = false,
  Integer[1]                   $ldap_connections_number                        = 5,
  Optional[String]             $ldap_debug                                     = undef,
  Integer                      $ldap_timeout                                   = 4,
  Integer                      $ldap_timelimit                                 = 3,
  Boolean                      $options_chase_referrals                        = false,
  Integer                      $options_idle                                   = 60,
  Integer                      $options_interval                               = 3,
  Integer                      $options_net_timeout                            = 1,
  Integer                      $options_probes                                 = 3,
  Boolean                      $options_rebind                                 = false,
  Integer[1]                   $pool_start                                     = 5,
  Integer[1]                   $pool_min                                       = 4,
  Integer[1]                   $pool_max                                       = 10,
  Integer[1]                   $pool_spare                                     = 3,
  Integer[0]                   $pool_uses                                      = 0,
  Integer[0]                   $pool_lifetime                                  = 0,
  Integer[1]                   $pool_idle_timeout                              = 60,
  Simplib::Port                $port                                           = 389,
  Optional[String]             $profile_attribute                              = undef,
  Stdlib::AbsolutePath         $random_file                                    = '/dev/urandom',
  String                       $require_cert                                   = 'demand',
  Boolean                      $start_tls                                      = true,
  Optional[String]             $user_access_attribute                          = undef,
  Optional[String]             $user_access_positive                           = undef,
  Optional[Freeradius::Scope]  $user_scope                                     = undef,
) {

  file { '/etc/raddb/mods-enabled/ldap':
    owner   => 'root',
    group   => 'radiusd',
    mode    => '0640',
    content => template('freeradius/3/modules/ldap.erb'),
    require => File['/etc/raddb/mods-enabled'],
    notify  => Service['radiusd']
  }

}
