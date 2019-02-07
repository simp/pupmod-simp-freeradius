# == Class: freeradius::v3::conf::modules
#
# Manage the 'modules' section of radiusd.conf.
#
# See /etc/raddb/radiusd.conf.sample for additional information.
#
# @params include_sql
#   The SQL related configuration
#
# @params include_mysql_counter
#   Active the mysql counter module.
#   Implies $include_sql
#
# @params include_sqlippool
#   Manage IP addresses in an SQL table.
#   Implies $include_sql
#
class freeradius::v3::conf::modules (
  Boolean   $include_sql           = false,
  Boolean   $include_mysql_counter = false,
  Boolean   $include_sqlippool     = false
) {

  file { '/etc/raddb/conf.d/modules.inc':
    ensure  => 'file',
    owner   => 'root',
    group   => 'radiusd',
    mode    => '0640',
    content => template('freeradius/3/conf.d/modules.erb'),
    notify  => Service['radiusd']
  }
}
