# == Class: freeradius::conf::listen
#
# Set up a directory for listener includes.
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
#
class freeradius::conf::listen {
  file { '/etc/raddb/conf/listen.inc':
    ensure => 'directory',
    owner  => 'root',
    group  => 'radiusd',
    mode   => '0640',
    before => Service['radiusd']
  }
}
