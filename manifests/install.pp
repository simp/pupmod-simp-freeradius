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

  package { ["$::freeradius::freeradius",
            "${::freeradius::freeradius_name}-ldap",
            "${::freeradius::freeradius_name}-utils"]:
    ensure  => $::freeradius::package_ensure,
    require => User['radiusd']
  }

  exec { '/etc/raddb/certs/bootstrap':
    path      => '/usr/bin:/usr/sbin:/bin:/etc/raddb/certs',
    unless    => 'test -f /etc/raddb/certs/server.pem',
    logoutput => true,
    require   => Package["$::freeradius::freeradius"]
  }

}
