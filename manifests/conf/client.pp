#
# == Class: freeradius::conf::client
#
# Set up a directory for client includes.
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
#
class freeradius::conf::client {
  file { '/etc/raddb/conf/clients':
    ensure => 'directory',
    owner  => 'root',
    group  => 'radiusd',
    mode   => '0640'
  }
}
