#
# Add a 'listen' section to a freeradius site or other configuration file
# that uses concat to create the file.
#
# @param target
#  The concat target to add this section to
#
# @param order
#  Indicates the order for this element amoung the concat fragments.
#
# The following parameters are all configuration parameters.
# @see See /etc/raddb/radiusd.conf.sample for additional information.
#
# @param idle_timeout
# @param ipaddr
#  be carefull not to use the same ip address in more than on listener
# @param interface
# @param lifetime
# @param listen_type
# @param max_epps
# @param max_connections
# @param per_socket_clients
# @param port
#
define freeradius::v3::listen (
  Stdlib::Absolutepath    $target,
  Freeradius::Listen      $listen_type,
  Integer[1]              $order              = 100,
  Simplib::Host           $ipaddr             = 'ALL',
  Optional[Simplib::Port] $port               = undef,
  Optional[String]        $interface          = undef,
  Optional[String]        $per_socket_clients = undef,
  Optional[Integer]       $max_epps           = undef,
  Optional[Integer]       $lifetime           = undef,
  Optional[Integer]       $max_connections    = undef,
  Optional[Integer]       $idle_timeout       = undef,
) {

  concat::fragment  { "listen.${name}.${listen_type}":
    content => template('freeradius/3/conf.d/listen.erb'),
    target  => $target,
    order   => $order
  }

}
