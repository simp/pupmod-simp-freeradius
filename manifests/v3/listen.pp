# @summary Add a 'listen' section to a freeradius configuration file.
#
# @param target
#  The concat target to add this section to
#
# @param listen_type
#
# @param order
#  Indicates the order for this element amoung the concat fragments.
#
# The following parameters are all configuration parameters.
#
# @see For detailed information on the parameters, extract the original
#      /etc/raddb/radiusd.conf from the freeradius rpm using
#      rpm2cpio < free radius rpm> | cpio -idmv
#
# @param idle_timeout
# @param interface
# @param ipaddr
#  Be careful not to use the same IP address on more than one listener
# @param lifetime
# @param max_connections
# @param max_pps
# @param per_socket_clients
# @param port
#
define freeradius::v3::listen (
  Stdlib::Absolutepath    $target,
  Freeradius::Listen      $listen_type,
  Optional[Integer]       $idle_timeout       = undef,
  Optional[String]        $interface          = undef,
  Simplib::Host           $ipaddr             = 'ALL',
  Optional[Integer]       $lifetime           = undef,
  Optional[Integer]       $max_connections    = undef,
  Optional[Integer]       $max_pps            = undef,
  Integer[1]              $order              = 100,
  Optional[String]        $per_socket_clients = undef,
  Optional[Simplib::Port] $port               = undef
) {

  concat::fragment  { "listen.${name}.${listen_type}":
    content => template('freeradius/3/conf.d/listen.erb'),
    target  => $target,
    order   => $order
  }
}
