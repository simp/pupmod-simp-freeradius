# == Class: freeradius::v2::modules
#
# The Freeradius modules space.
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
#
class freeradius::v2::modules {
  file { '/etc/raddb/modules':
    ensure => 'directory',
    owner  => 'root',
    group  => 'radiusd',
    mode   => '0640'
  }

  if $freeradius::ldap {
    include 'freeradius::v2::modules::ldap'
  }
}
