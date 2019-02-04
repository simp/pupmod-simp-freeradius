# == Class: freeradius::conf::thread_pool
#
# Add a 'thread pool' section to the freeradius configuration..
#
# @see /etc/raddb/radiusd.conf.sample for additional information.
#
# == Parameters
#
# @params start_servers
# @params max_servers
# @params min_spare_servers
# @params max_spare_servers
# @params max_requests_per_server
#
class freeradius::conf::thread_pool (
  Integer   $start_servers           = 5,
  Integer   $max_servers             = 32,
  Integer   $min_spare_servers       = 3,
  Integer   $max_spare_servers       = 10,
  Integer   $max_requests_per_server = 0
) {

  include 'freeradius'

  ensure_resource ('file',  "${freeradius::confdir}/conf.d",
    {
      ensure => 'directory',
      owner  => 'root',
      group  => 'radiusd',
      mode   => '0640',
      purge  => true,
      before => Service['radiusd'],
    })

  file { "${freeradius::confdir}/conf.d/thread_pool.inc":
    ensure  => 'file',
    owner   => 'root',
    group   => 'radiusd',
    mode    => '0640',
    content => template('freeradius/conf.d/thread_pool.erb'),
    notify  => Service['radiusd']
  }

}
