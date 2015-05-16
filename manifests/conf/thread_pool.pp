# == Class: freeradius::conf::thread_pool
#
# Add a 'thread pool' section to the freeradius configuration..
#
# You can only call this *once* within a node scope. If you try to call it more
# than once, it will fail your manifest compilation due to conflicting
# resources.
#
# See /etc/raddb/radiusd.conf.sample for additional information.
#
# == Parameters
#
# [*start_servers*]
# [*max_servers*]
# [*min_spare_servers*]
# [*max_spare_servers*]
# [*max_requests_per_server*]
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
#
class freeradius::conf::thread_pool (
  $start_servers = '5',
  $max_servers = '32',
  $min_spare_servers = '3',
  $max_spare_servers = '10',
  $max_requests_per_server = '0'
) {

  file { '/etc/raddb/conf/thread_pool.inc':
    ensure  => 'file',
    owner   => 'root',
    group   => 'radiusd',
    mode    => '0640',
    content => template('freeradius/conf/thread_pool.erb'),
    notify  => Service['radiusd']
  }

  validate_integer($start_servers)
  validate_integer($max_servers)
  validate_integer($min_spare_servers)
  validate_integer($max_spare_servers)
  validate_integer($max_requests_per_server)
}
