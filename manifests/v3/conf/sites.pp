# == Class: freeradius::v3::conf::sites
#
# Manage the 'sites' section of radiusd.conf.
#
# See /etc/raddb/radiusd.conf.sample for additional information.
#
# == Parameters
#
# @param enable_default
#  Boolean:
#   Whether or not to enable the simp default ldap as the default site.  This will
#   configure Radius to listen on all interfaces from all IP address
#   and verify using ldap.
#   You must use freeradius::v3::modules::ldap or something else to configure
#   the ldap module.
#  Default: true
#
# @param enable_inner_tunnel
#  Boolean:
#   Whether or not to enable the inner_tunnel site.
#  Default: true
#
class freeradius::v3::conf::sites (
  Boolean    $enable_default      = true,
  Boolean    $enable_inner_tunnel = true
){

  file { "${freeradius::confdir}/sites-available/simp-ldap-default":
    ensure => 'file',
    owner  => 'root',
    group  => $freeradius::group,
    mode   => '0640',
    source => 'puppet:///modules/freeradius/sites/default',
  }

  if $enable_default {
    file { "${freeradius::confdir}/sites-enabled/default":
      ensure => link,
      owner  => 'root',
      group  => $freeradius::group,
      mode   => '0640',
      target => "${freeradius::confdir}/sites-available/simp-ldap-default",
      notify => Service['radiusd']
    }
  }

  if $enable_inner_tunnel {
    file { "${freeradius::confdir}/sites-enabled/inner-tunnel":
      ensure => link,
      owner  => 'root',
      group  =>  $freeradius::group,
      mode   => '0640',
      target => "${freeradius::confdir}/sites-available/inner-tunnel",
      notify => Service['radiusd']
    }
  }

}
