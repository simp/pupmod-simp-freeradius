# @summary Add a client to `/etc/raddb/clients.d/`
#
# @see clients.conf(5) for additional information.
#
# @param secret
#   If you do not specify a secret, then one will be created for you using
#   `$name` as the id.
#
# @param ipaddr
#   If set to something with a ':' in it, will be treated as ipv6addr instead.
#
# @param client_name
# @param coa_server
# @param idle_timeout
# @param lifetime
# @param login
# @param max_connections
# @param nas_type
# @param password
# @param proto
# @param require_message_authenticator
# @param response_window
# @param shortname
# @param virtual_server
#
# @author https://github.com/simp/pupmod-simp-freeradius/graphs/contributors
#
define freeradius::v3::client (
  Variant[Simplib::IP,
          Simplib::IP::CIDR]       $ipaddr,
  String                           $client_name                   = $name,
  String                           $secret                        = simplib::passgen("freeradius_${name}"),
  Optional[Enum['udp','tcp','*']]  $proto                         = undef,
  Optional[String]                 $shortname                     = undef,
  Boolean                          $require_message_authenticator = true,
  Optional[Freeradius::Nas]        $nas_type                      = undef,
  Optional[String]                 $login                         = undef,
  Optional[String]                 $password                      = undef,
  Optional[Float[0.0]]             $response_window               = undef,
  Optional[String]                 $virtual_server                = undef,
  Optional[String]                 $coa_server                    = undef,
  Integer                          $max_connections               = 16,
  Integer                          $lifetime                      = 0,
  Integer                          $idle_timeout                  = 30,
) {

  include 'freeradius'

  ensure_resource ( 'file', "${freeradius::confdir}/clients.d",
    {
      ensure => 'directory',
      owner  => 'root',
      group  => $freeradius::group,
      mode   => '0640',
    })

  file { "${freeradius::confdir}/clients.d/${name}.conf":
    owner   => 'root',
    group   => $freeradius::group,
    mode    => '0640',
    content => template('freeradius/3/clients.d/client.erb'),
    notify  => Service['radiusd']
  }

}
