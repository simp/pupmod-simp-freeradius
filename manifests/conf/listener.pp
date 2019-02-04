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
  Freeradius::Listen   $listen_type,
  Simplib::Host        $ipaddr             = 'ALL',
  Simplib::Port        $port               = 0,
  Optional[String]     $interface          = undef,
  Optional[String]     $per_socket_clients = undef,
  Stdlib::Absolutepath $confdir            = simplib::lookup('freeradius::confdir', { 'default_value' => '/etc/raddb'})
) {

  include 'freeradius'


  file { "${confdir}/listen.${name}":
    ensure  => 'file',
    owner   => 'root',
    group   => 'radiusd',
    content => template('freeradius/conf.d/listen.erb'),
    notify  => Service['radiusd']
  }

}
