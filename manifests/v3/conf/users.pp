#
# == Class: freeradius::v3::users
#
# Set up the freeradius users entries.
#
class freeradius::v3::conf::users {

  assert_private()

  Class['freeradius::config']
  -> Class['freeradius::v3::conf::users']
  ~> Service['radiusd']

  concat { 'radius_user_file':
    ensure => present,
    path   => "${freeradius::confdir}/mods-config/files/authorize",
    owner  => 'root',
    group  => $freeradius::group,
    mode   => '0640',
    order  => 'numeric'
  }

  $_header = @("EOF")
# This file is managed by Puppet.  Changes will be overwritten
# at the next puppet run.
#
 | EOF

  concat::fragment { 'radius_user_header':
    target  => "${freeradius::confdir}/mods-config/files/authorize",
    content => $_header,
    order   => 0
  }

}
