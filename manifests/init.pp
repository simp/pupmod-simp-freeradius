# == Class: freeradius
#
# Configure a Freeradius server.
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
#
class freeradius {
  include 'pki'
  include 'freeradius::modules'

  if $::operatingsystem in ['RedHat','CentOS'] and ( versioncmp($::operatingsystemmajrelease,'6') < 0 ) {
    $freeradius_name = 'freeradius2'
  }
  else {
    $freeradius_name = 'freeradius'
  }

  $l_freeradius_ver = "${freeradius::freeradius_name}.${::hardwaremodel}"

  exec { '/etc/raddb/certs/bootstrap':
    path      => '/usr/bin:/usr/sbin:/bin:/etc/raddb/certs',
    unless    => 'test -f /etc/raddb/certs/server.pem',
    logoutput => true,
    require   => Package[$l_freeradius_ver],
    before    => Service['radiusd']
  }

  exec { '/bin/chgrp -R radiusd /etc/raddb/certs':
    require => [
      Package[$l_freeradius_ver],
      Group['radiusd']
    ],
    before  => Service['radiusd']
  }

  exec { 'set_radius_key_perms':
    command   => "/usr/bin/setfacl -m g:radiusd:x /etc/pki/private; /usr/bin/setfacl -m g:radiusd:r /etc/pki/private/${::fqdn}.pem",
    onlyif    => "/usr/bin/getfacl /etc/pki/private | grep -q radiusd && /usr/bin/getfacl /etc/pki/private/${::fqdn}.pem | grep -q radiusd; test \$? -ne 0",
    subscribe => [
      File["/etc/pki/private/${::fqdn}.pem"],
      Group['radiusd'],
    ],
    require   => Package[$l_freeradius_ver],
    notify    => Service['radiusd']
  }

  file { '/etc/raddb':
    owner   => 'root',
    group   => 'radiusd',
    mode    => '0750',
    require => [ User['radiusd'], Package[$l_freeradius_ver] ]
  }

  group { 'radiusd':
    ensure => 'present',
    gid    => '95'
  }

  package { $l_freeradius_ver:
    ensure  => 'latest',
    require => User['radiusd']
  }

  package { "${freeradius::freeradius_name}-ldap.${::hardwaremodel}":
    ensure => 'latest'
  }

  package { "${freeradius::freeradius_name}-utils.${::hardwaremodel}":
    ensure => 'latest'
  }

  service { 'radiusd':
    ensure    => 'running',
    enable    => true,
    hasstatus => true,
    subscribe => [
      File["/etc/pki/private/${::fqdn}.pem"],
      File["/etc/pki/public/${::fqdn}.pub"],
      File['/etc/pki/cacerts']
    ],
    require   => [
      Package[$l_freeradius_ver],
      Package["${freeradius::freeradius_name}-ldap.${::hardwaremodel}"],
      Package["${freeradius::freeradius_name}-utils.${::hardwaremodel}"]
    ]
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
}
