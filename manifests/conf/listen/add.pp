# == Define: freeradius::conf::listen::add
#
# Add a 'listen' section to freeradius.
#
# See /etc/raddb/radiusd.conf.sample for additional information.
#
# == Parameters
#
# [*name*]
#   The name variable should be set uniquely. Take care that you do not try
#   to use the same $ipaddr value in two different statements!
#
# [*listen_type*]
# [*ipaddr*]
# [*port*]
# [*interface*]
# [*per_socket_clients*]
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
#
define freeradius::conf::listen::add (
  Freeradius::Listen  $listen_type,
  Simplib::Netlist    $ipaddr             = '*',
  Simplib::Port       $port               = 0,
  String              $interface           = undef,
  Optional[String]    $per_socket_clients = undef
) {

  file { "/etc/raddb/conf/listen.inc/${name}":
    ensure  => 'file',
    owner   => 'root',
    group   => 'radiusd',
    content => template('freeradius/conf/listen.erb'),
    notify  => Service['radiusd']
  }

}
