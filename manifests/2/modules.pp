# == Class: freeradius::2::modules
#
# The Freeradius modules space.
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
#
class freeradius::2::modules {
  file { '/etc/raddb/modules':
    ensure => 'directory',
    owner  => 'root',
    group  => 'radiusd',
    mode   => '0640'
  }
}
