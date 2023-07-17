# @summary This will create a site that will authenticate using LDAP and listen
# on the interface defined by `listen_ip`
#
# The Default is to listen on all interfaces.
#
# @see `/etc/raddb/sites-available/default` for more information on sites
#
# @param site_name
#   The name of the site
#
# @param enable
#   Whether to enable the site or not
#
# @param confdir
#   Configuration directory for freeradius
#
# @param include_listener
#  If set to true then 'listen' sections will be set up for the site.
#  Otherwise the listen_ip will be ignored and the user will be required
#  to set up a listener using the listener.pp module.
#
# @param group
#   Group radiusd runs under.
#
# @param listen_ip
#  The ip addresses to listen on.  See setting ipaddr  in sites-enabled/default.
#
# @param max_connections
# @param lifetime
# @param idle_timeout
#
class freeradius::v3::sites::ldap (
  String               $site_name        = 'default',
  Boolean              $enable           = true,
  Boolean              $include_listener = true,
  Simplib::Host        $listen_ip        = 'ALL',
  Stdlib::Absolutepath $confdir          = $freeradius::confdir,
  String               $group            = $freeradius::group,
  Integer              $max_connections  = 16,
  Integer              $lifetime         = 0,
  Integer              $idle_timeout     = 30
) inherits freeradius {

  $_target = "${confdir}/sites-available/simp-ldap-default"

  concat { 'site_simp_ldap_default':
    ensure => present,
    path   => $_target,
    owner  => 'root',
    group  => $group,
    mode   => '0640',
    notify => Service['radiusd'],
    order  => 'numeric'
  }

  concat::fragment { 'site_ldap_header':
    target  => $_target,
    content => epp('freeradius/3/sites/ldap_header.epp'),
    order   => 0
  }

  if $include_listener {
    freeradius::v3::listen { 'site_ldap_auth':
      target          => $_target,
      order           => 10,
      listen_type     => 'auth',
      ipaddr          => $listen_ip,
      port            => 0,
      max_connections => $max_connections,
      idle_timeout    => $idle_timeout,
      lifetime        => $lifetime
    }

    freeradius::v3::listen { 'site_ldap_acct':
      target      => $_target,
      order       => 11,
      listen_type => 'acct',
      ipaddr      => $listen_ip,
      port        => 0
    }
  }

  concat::fragment { 'site_ldap_footer':
    target  => $_target,
    order   => 100,
    content => epp('freeradius/3/sites/ldap_footer.epp')
  }

  if $enable {
    file {  "${confdir}/sites-enabled/${site_name}":
      ensure => 'link',
      target => $_target,
      owner  => 'root',
      group  => $group,
      notify => Service['radiusd'],
      mode   => '0640',
    }
  }
}
