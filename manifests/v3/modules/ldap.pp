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
  $ldap_base_dn                                   = simplib::lookup('simp_options::ldap::base_dn', { 'value_type'    => String }),
  $app_pki_ca_dir                                 = $::freeradius::config::app_pki_ca_dir,
  $app_pki_cert                                   = $::freeradius::config::app_pki_cert,
  $app_pki_key                                    = $::freeradius::config::app_pki_key,
  $base_filter                                    = '(objectclass=radiusprofile)',
  $client_scope                                   = 'nil',
  $client_attribute_identifier                    = 'radiusClientIdentifier',
  $client_attribute_secret                        = 'radiusClientSecret',
  $client_attribute_shortname                     = 'nil',
  $client_attribute_nas_type                      = 'nil',
  $client_attribute_virtual_server                = 'nil',
  $client_attribute_require_message_authenticator = 'nil',
  $default_profile                                = 'nil',
  $filter                                         = '(uid=%{%{Stripped-User-Name}:-%{User-Name}})',
  $group_scope                                    = 'nil',
  $group_name_attribute                           = 'cn',
  $group_membership_filter                        = '(|(&(objectClass=GroupOfNames)(member=%{control:Ldap-UserDn}))(&(objectClass=GroupOfUniqueNames)(uniquemember=%{control:Ldap-UserDn})))',
  $group_membership_attribute                     = 'radiusGroupName',
  $group_cacheable_name                           = false,
  $group_cacheable_dn                             = false,
  $identity                                       = simplib::lookup('simp_options::ldap::bind_dn', { 'default_value' => "cn=hostAuth,ou=Hosts,%{hiera('simp_options::ldap::base_dn')}", 'value_type' => String }),
  $ldap_connections_number                        = '5',
  $ldap_debug                                     = 'nil',
  $ldap_timeout                                   = '4',
  $ldap_timelimit                                 = '3',
  $options_chase_referrals                        = false,
  $options_idle                                   = '60',
  $options_interval                               = '3',
  $options_net_timeout                            = '1',
  $options_probes                                 = '3',
  $options_rebind                                 = false,
  $password                                       = simplib::lookup('simp_options::ldap::bind_pw', { 'value_type'    => String }),
  $pool_start                                     = '5',
  $pool_min                                       = '4',
  $pool_max                                       = '10',
  $pool_spare                                     = '3',
  $pool_uses                                      = '0',
  $pool_lifetime                                  = '0',
  $pool_idle_timeout                              = '60',
  $port                                           = '389',
  $profile_attribute                              = 'nil',
  $random_file                                    = '/dev/urandom',
  $require_cert                                   = 'demand',
  $start_tls                                      = true,
  $user_access_attribute                          = 'nil',
  $user_access_positive                           = 'nil',
  $user_scope                                     = 'nil',
  $server                                         = simplib::lookup('simp_options::ldap::uri', { 'default_value'     => ["ldap://%{hiera('simp_options::puppet::server')}"], 'value_type' => Array[String] })
) {

  file { '/etc/raddb/mods-enabled/ldap':
    owner   => 'root',
    group   => 'radiusd',
    mode    => '0640',
    content => template('freeradius/3/modules/ldap.erb'),
    notify  => Service['radiusd']
  }

  #validate_absolute_path($app_pki_ca)
  #validate_absolute_path($app_pki_key)
  #validate_absolute_path($random_file)
  if $user_scope != 'nil' {
    validate_array_member($user_scope, ['base','one','sub','children'])
  }
  if $group_scope != 'nil' {
    validate_array_member($group_scope, ['base','one','sub','children'])
  }
  if $client_scope != 'nil' {
    validate_array_member($client_scope, ['base','one','sub','children'])
  }
  #validate_bool($group_cacheable_name)
  #validate_bool($group_cacheable_dn)
  #validate_bool($options_chase_referrals)
  #validate_bool($options_rebind)
  #validate_bool($start_tls)
  #validate_integer($ldap_connections_number)
  #validate_integer($ldap_timeout)
  #validate_integer($ldap_timelimit)
  #validate_integer($options_idle)
  #validate_integer($options_interval)
  #validate_integer($options_net_timeout)
  #validate_integer($options_probes)
  #validate_integer($pool_start)
  #validate_integer($pool_min)
  #validate_integer($pool_max)
  #validate_integer($pool_spare)
  #validate_integer($pool_uses)
  #validate_integer($pool_lifetime)
  #validate_integer($pool_idle_timeout)
  #validate_port($port)
}
