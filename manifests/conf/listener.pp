# == Define: freeradius::conf::listener
#
# Add a 'listen' section to freeradius.
#
# @param listen_type
# @param ipaddr
#  be carefull not to use the same ip address in more than on listener
# @param port
# @param interface
# @param per_socket_clients
#
# @see See /etc/raddb/radiusd.conf.sample for additional information.
#
define freeradius::conf::listener (
  Freeradius::Listen  $listen_type,
  Simplib::Host       $ipaddr             = 'ALL',
  Simplib::Port       $port               = 0,
  Optional[String]    $interface          = undef,
  Optional[String]    $per_socket_clients = undef
) {

  ensure_resource ( 'file', '/etc/raddb/conf/listen.inc',
    {
      ensure => 'directory',
      owner  => 'root',
      group  => 'radiusd',
      mode   => '0640',
      before => Service['radiusd']
    }
  )

  file { "/etc/raddb/conf/listen.inc/${name}":
    ensure  => 'file',
    owner   => 'root',
    group   => 'radiusd',
    content => template('freeradius/conf/listen.erb'),
    notify  => Service['radiusd']
  }

}
