# == Class: freeradius::conf::modules
#
# Manage the 'modules' section of radiusd.conf.
#
# You can only call this *once* within a node scope. If you try to call it more
# than once, it will fail your manifest compilation due to conflicting
# resources.
#
# See /etc/raddb/radiusd.conf.sample for additional information.
#
# == Parameters
#
# [*include_eap*]
#   Include eap.conf
#
# [*include_sql*]
#   The SQL related configuration
#
# [*include_mysql_counter*]
#   Active the mysql counter module.
#   Implies $include_sql
#
# [*include_sqlippool*]
#   Manage IP addresses in an SQL table.
#   Implies $include_sql
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
#
class freeradius::conf::modules (
  $include_eap = true,
  $include_sql = false,
  $include_mysql_counter = false,
  $include_sqlippool = false
) {
  validate_bool($include_eap)
  validate_bool($include_sql)
  validate_bool($include_mysql_counter)
  validate_bool($include_sqlippool)

  include '::freeradius'

  if $::operatingsystem in ['RedHat', 'CentOS'] {
    if $::radius_version != 'unknown' {
      if (versioncmp($::radius_version, '3') >= 0) {
        file { '/etc/raddb/conf/modules.inc':
          ensure  => 'file',
          owner   => 'root',
          group   => 'radiusd',
          mode    => '0640',
          content => template('freeradius/3/conf/modules.erb'),
          notify  => Service['radiusd']
        }
      }
      else {
        file { '/etc/raddb/conf/modules.inc':
          ensure  => 'file',
          owner   => 'root',
          group   => 'radiusd',
          mode    => '0640',
          content => template('freeradius/2/conf/modules.erb'),
          notify  => Service['radiusd']
        }
      }
    }
    else {
      warning('FreeRADIUS does not yet appear to be installed. Please install FreeRADIUS and then continue.')
    }
  }
  else {
    warning("${::operatingsystem} not yet supported. Current options are RedHat and CentOS")
  }
}
