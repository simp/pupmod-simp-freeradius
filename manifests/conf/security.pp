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
# [*max_attributes*]
# [*reject_delay*]
# [*status_server*]
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
#
class freeradius::conf::security (
  $max_attributes = '200',
  $reject_delay   = '1',
  $status_server  = true
) {

  file { '/etc/raddb/conf/security.inc':
    ensure  => 'file',
    owner   => 'root',
    group   => 'radiusd',
    mode    => '0640',
    content => template('freeradius/conf/security.erb'),
    notify  => Service['radiusd']
  }

  #validate_integer($max_attributes)
  #validate_integer($reject_delay)
  #validate_bool($status_server)
}
