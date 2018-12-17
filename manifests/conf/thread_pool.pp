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
  Integer   $start_servers           = 5,
  Integer   $max_servers             = 32,
  Integer   $min_spare_servers       = 3,
  Integer   $max_spare_servers       = 10,
  Integer   $max_requests_per_server = 0
) {

  file { '/etc/raddb/conf/thread_pool.inc':
    ensure  => 'file',
    owner   => 'root',
    group   => 'radiusd',
    mode    => '0640',
    content => template('freeradius/conf/thread_pool.erb'),
    notify  => Service['radiusd']
  }

}
