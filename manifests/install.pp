# Class freeradius::install
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
# * Nick Markowski <nmarkowski@keywcorp.com>
#
class freeradius::install inherits freeradius {
  assert_private()

  group { 'radiusd':
    ensure => 'present',
    gid    => '95'
  }

  user { 'radiusd':
    ensure    => 'present',
    uid       => '95',
    gid       => 'radiusd',
    allowdupe => false,
    shell     => '/sbin/nologin',
    home      => '/var/run/radiusd',
    require   => Group['radiusd']
  }

  package { [$::freeradius::freeradius_ver,
            "${::freeradius::freeradius_name}-ldap.${::hardwaremodel}",
            "${::freeradius::freeradius_name}-utils.${::hardwaremodel}"]:
    ensure  => 'latest',
    require => User['radiusd']
  }
}
