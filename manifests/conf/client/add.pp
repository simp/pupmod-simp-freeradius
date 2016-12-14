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
# [*ipaddr*]
#   If set to something with a ':' in it, will be treated as ipv6addr instead.
#
# [*netmask*]
# [*secret*]
# [*shortname*]
# [*require_message_authenticator*]
# [*nas_type*]
# [*login*]
# [*password*]
# [*virtual_server*]
# [*coa_server*]
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
#
define freeradius::conf::client::add (
  $client_name                   = $name,
  $ipaddr                        = '',
  $netmask                       = 'nil',
  $secret                        = 'nil',
  $shortname                     = 'nil',
  $require_message_authenticator = true,
  $nas_type                      = 'other',
  $login                         = 'nil',
  $password                      = 'nil',
  $virtual_server                = 'nil',
  $coa_server                    = 'nil'
) {

  file { "/etc/raddb/conf/clients/${name}.conf":
    owner   => 'root',
    group   => 'radiusd',
    mode    => '0640',
    content => template('freeradius/conf/client.erb'),
    notify  => Service['radiusd']
  }

  #validate_bool($require_message_authenticator)
  validate_array_member($nas_type,
    [
      'cisco','computone','livingston','max40xx','multitech',
      'netserver','pathras','patton','portslave','tc','usrhiper','other'])
}
