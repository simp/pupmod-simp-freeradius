# == Define: freeradius::conf::client::add
#
# Add a client to /etc/raddb/conf/clients/
#
#
# See clients.conf(5) for additional information.
#
# == Parameters
#
# @param secret  [required]
#   If you do not specify a secret, then one will be created for you using $name
#   as the id.
# @param ipaddr  [required]
#   If set to something with a ':' in it, will be treated as ipv6addr instead.
#
# @param client_name
# @param netmask
# @param shortname
# @param require_message_authenticator
# @param nas_type
# @param login
# @param password
# @param virtual_server
# @param coa_server
#
# @author SIMP Team <https://simp-project.com>
#
define freeradius::conf::client (
  Simplib::IP                    $ipaddr,
  String                         $client_name                   = $name,
  String                         $secret                        = simplib::passgen("freeradius_${name}"),
  Optional[Integer]              $netmask                       = undef,
  Optional[String]               $shortname                     = undef,
  Boolean                        $require_message_authenticator = true,
  Optional[Freeradius::Nas]      $nas_type                      = undef,
  Optional[String]               $login                         = undef,
  Optional[String]               $password                      = undef,
  Optional[String]               $virtual_server                = undef,
  Optional[String]               $coa_server                    = undef
) {

  ensure_resource ('file', '/etc/raddb/conf/clients',
    {
      ensure => 'directory',
      owner  => 'root',
      group  => 'radiusd',
      mode   => '0640'
    }
  )

  file { "/etc/raddb/conf/clients/${name}.conf":
    owner   => 'root',
    group   => 'radiusd',
    mode    => '0640',
    content => template('freeradius/conf/client.erb'),
    notify  => Service['radiusd']
  }

}
