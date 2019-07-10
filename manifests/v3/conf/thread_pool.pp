# @summary Add a 'thread pool' section to the freeradius configuration
#
#
# @see For detailed information on the parameters, extract the original
#      /etc/raddb/radiusd.conf from the freeradius rpm using
#      rpm2cpio < free radius rpm> | cpio -idmv
#
# @param start_servers
# @param max_servers
# @param min_spare_servers
# @param max_spare_servers
# @param max_requests_per_server
# @param max_queue_size
# @param auto_limit_acct
#
class freeradius::v3::conf::thread_pool (
  Integer           $start_servers           = 5,
  Integer           $max_servers             = 32,
  Integer           $min_spare_servers       = 3,
  Integer           $max_spare_servers       = 10,
  Integer           $max_requests_per_server = 0,
  Optional[Integer] $max_queue_size          = undef,
  Boolean           $auto_limit_acct         = false
) {

  include 'freeradius'

  ensure_resource ('file',  "${freeradius::confdir}/conf.d",
    {
      ensure => 'directory',
      owner  => 'root',
      group =>  $freeradius::group,
      mode   => '0640',
      purge  => true,
      before => Service['radiusd'],
    })

  file { "${freeradius::confdir}/conf.d/thread_pool.inc":
    ensure  => 'file',
    owner   => 'root',
    group   =>  $freeradius::group,
    mode    => '0640',
    content => template('freeradius/3/conf.d/thread_pool.erb'),
    notify  => Service['radiusd']
  }

}
