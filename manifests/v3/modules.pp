# == Class: freeradius::modules
#
# The Freeradius modules space.
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
#
class freeradius::v3::modules (
  Boolean              $include_sql           = false,
  Boolean              $include_mysql_counter = false,
  Boolean              $include_sqlippool     = false,
) {

  include 'freeradius'

  file { "${freeradius::confdir}/conf.d/modules.inc":
    ensure  => 'file',
    owner   => 'root',
    group   => 'radiusd',
    mode    => '0640',
    content => template('freeradius/3/conf.d/modules.erb'),
    notify  => Service['radiusd']
  }

  file { "${freeradius::confdir}/mods-config":
    ensure => 'directory',
    owner  => 'root',
    group  => 'radiusd',
    mode   => '0640'
  }

  file { "${freeradius::confdir}/mods-available":
    ensure => 'directory',
    owner  => 'root',
    group  => 'radiusd',
    mode   => '0640'
  }

  file { "${freeradius::confdir}/mods-enabled":
    ensure => 'directory',
    owner  => 'root',
    group  => 'radiusd',
    mode   => '0640'
  }

  if $freeradius::ldap {
    include  freeradius::v3::modules::ldap
  }

}
