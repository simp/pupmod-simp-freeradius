# == Define: freeradius::conf::listener
#
# Add a 'listen' section to freeradius.
#
# @param group
#   The group radiusd service is run under.
#
# @param confdir
#   The configuration directory used for freeradius
#
# The following parameters are all configuration parameters.
# @see See /etc/raddb/radiusd.conf.sample for additional information.
#
# @param listen_type
# @param ipaddr
#  be carefull not to use the same ip address in more than on listener
# @param port
# @param interface
# @param per_socket_clients
#
#
define freeradius::v3::listener (
  Freeradius::Listen   $listen_type,
  Simplib::Host        $ipaddr             = 'ALL',
  Simplib::Port        $port               = 0,
  Optional[String]     $interface          = undef,
  Optional[String]     $per_socket_clients = undef,
  String               $group              = simplib::lookup('freeradius::group', { 'default_value' => 'radiusd'}),
  Stdlib::Absolutepath $confdir            = simplib::lookup('freeradius::confdir', { 'default_value' => '/etc/raddb'})
) {

  include 'freeradius'

  file { "${confdir}/listen.${name}":
    ensure  => 'file',
    owner   => 'root',
    group   => $group,
    content => template('freeradius/3/conf.d/listen.erb'),
    notify  => Service['radiusd']
  }

}
