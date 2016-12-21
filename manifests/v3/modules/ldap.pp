# == Class: freeradius::v3::modules::ldap
#
# Set up the LDAP module configuration.
#
# == Parameters
#
# [*base_dn*]
# [*base_filter*]
# [*app_pki_ca_dir*]
#
# [*app_pki_cert*]
#   If you change this from the default, you will need to ensure that you
#   manage the file and that apache restarts when the file is updated.
#
# [*client_scope*]
# [*client_attribute_identifier*]
# [*client_attribute_secret*]
# [*client_attribute_shortname*]
# [*client_attribute_nas_type*]
# [*client_attribute_virtual_server*]
# [*client_attribute_require_message_authenticator*]
# [*default_profile*]
# [*filter*]
# [*group_scope*]
# [*group_name_attribute*]
# [*group_membership_filter*]
#
# [*group_membership_attribute*]
#   If this does not contain a value then Group Membership Checking will not
#   be enabled.
#
# [*group_cacheable_name*]
# [*group_cacheable_dn*]
# [*identity*]
# [*ldap_connections_number*]
# [*ldap_debug*]
# [*ldap_timeout*]
# [*ldap_timelimit*]
# [*options_chase_referrals*]
# [*options_idle*]
# [*options_interval*]
# [*options_net_timeout*]
# [*options_probes*]
# [*options_rebind*]
# [*password*]
# [*pool_start*]
# [*pool_min*]
# [*pool_max*]
# [*pool_spare*]
# [*pool_uses*]
# [*pool_lifetime*]
# [*pool_idle_timeout*]
# [*port*]
# [*app_pki_key*]
#
#   If you change this from the default, you will need to ensure that you
#   manage the file and that apache restarts when the file is updated.
#
# [*profile_attribute*]
# [*random_file*]
# [*require_cert*]
# [*start_tls*]
# [*user_access_attribute*]
# [*user_access_positive*]
# [*user_scope*]
# [*server*]
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
#
class freeradius::v3::modules::ldap (
  $ldap_base_dn                                   = simplib::lookup('simp_options::ldap::base_dn', { 'value_type'    => String }),
  $app_pki_ca_dir                                 = "${::freeradius::app_pki_dir}/pki/cacerts",
  $app_pki_cert                                   = "${::freeradius::app_pki_dir}/pki/public/${::fqdn}.pub",
  $app_pki_key                                    = "${::freeradius::app_pki_dir}/pki/private/${::fqdn}.pem",
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
