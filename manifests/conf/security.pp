# == Class: freeradius::conf::security
#
# Add a 'security' section to freeradius.
#
# You can only call this *once* within a node scope. If you try to call it more
# than once, it will fail your manifest compilation due to conflicting
# resources.
#
# See /etc/raddb/radiusd.conf.sample for additional information.
#
# == Parameters
#
# @param max_attributes
# @param reject_delay
# @param status_server
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
#
class freeradius::conf::security (
  Integer         $max_attributes = 200,
  Integer[1,5]    $reject_delay   = 1,
  Boolean         $status_server  = true
) {

  file { '/etc/raddb/conf/security.inc':
    ensure  => 'file',
    owner   => 'root',
    group   => 'radiusd',
    mode    => '0640',
    content => template('freeradius/conf/security.erb'),
    notify  => Service['radiusd']
  }

}
