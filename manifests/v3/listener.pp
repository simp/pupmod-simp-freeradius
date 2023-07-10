# @summary Create a global listener in the `conf.d` directory
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
# @param confdir
# @param group
# @param idle_timeout
# @param interface
# @param ipaddr
#  Be careful not to use the same ip address in more than one listener
# @param lifetime
# @param max_connections
# @param max_pps
# @param per_socket_clients
# @param port
#
define freeradius::v3::listener (
  Freeradius::Listen      $listen_type,
  Stdlib::Absolutepath    $confdir            = simplib::lookup( 'freeradius::confdir', {'default_value' => '/etc/raddb'} ),
  String                  $group              = simplib::lookup( 'freeradius::group', {'default_value' => 'radiusd'} ),
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

  $_target = "${confdir}/conf.d/listener.${name}"
  concat { "listener.${name}" :
      ensure => present,
      path   => $_target,
      owner  => 'root',
      group  => $group,
      mode   => '0640',
      notify => Service['radiusd'],
      order  => 'numeric'
    }


  freeradius::v3::listen  { "${_target}-fragment":
    target             => $_target,
    order              => $order,
    listen_type        => $listen_type,
    ipaddr             => $ipaddr,
    port               => $port,
    interface          => $interface,
    per_socket_clients => $per_socket_clients,
    max_pps            => $max_pps,
    lifetime           => $lifetime,
    max_connections    => $max_connections,
    idle_timeout       => $idle_timeout,
  }

}
