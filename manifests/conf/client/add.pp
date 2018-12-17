# == Define: freeradius::conf::client::add
#
# Add a client to /etc/raddb/conf/clients/
#
# If you do not specify a password, then one will be created for you using $name
# as the id.
#
# See clients.conf(5) for additional information.
#
# == Parameters
#
# @param ipaddr
#   If set to something with a ':' in it, will be treated as ipv6addr instead.
#
# @param netmask
# @param secret
# @param shortname
# @param require_message_authenticator
# @param nas_type
# @param login
# @param password
# @param virtual_server
# @param coa_server
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
#
define freeradius::conf::client::add (
  String                         $client_name                   = $name,
  Optional[Simplib::IP]          $ipaddr                        = undef,
  Optional[String]               $netmask                       = undef,
  String                         $secret                        = simplib::passgen("freeradius_${name}"),
  Optional[String]               $shortname                     = undef,
  Boolean                        $require_message_authenticator = true,
  Freeradius::Nas                $nas_type                      = 'other',
  Optional[String]               $login                         = undef,
  Optional[String]               $password                      = undef,
  Optional[String]               $virtual_server                = undef,
  Optional[String]               $coa_server                    = undef
) {

  file { "/etc/raddb/conf/clients/${name}.conf":
    owner   => 'root',
    group   => 'radiusd',
    mode    => '0640',
    content => template('freeradius/conf/client.erb'),
    notify  => Service['radiusd']
  }

}
