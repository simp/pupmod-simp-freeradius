# == Class: freeradius::modules
#
# The Freeradius modules space.
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
#
class freeradius::v3::modules {
  file { '/etc/raddb/mods-available':
    ensure => 'directory',
    owner  => 'root',
    group  => 'radiusd',
    mode   => '0640'
  }
  file { '/etc/raddb/mods-enabled':
    ensure => 'directory',
    owner  => 'root',
    group  => 'radiusd',
    mode   => '0640'
  }
}
