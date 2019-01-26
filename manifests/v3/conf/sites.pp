# == Class: freeradius::conf::sites
#
# Manage the 'sites' section of radiusd.conf.
#
# You can only call this *once* within a node scope. If you try to call it more
# than once, it will fail your manifest compilation due to conflicting
# resources.
#
# See /etc/raddb/radiusd.conf.sample for additional information.
#
# == Parameters
#
# @param enable_default
#  Boolean:
#   Whether or not to enable the default site from the FreeRADIUS package.
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


  if $enable_default {
    file { '/etc/raddb/sites-enabled/default':
      ensure => 'file',
      owner  => 'root',
      group  => 'radiusd',
      mode   => '0640',
      source => 'puppet:///modules/freeradius/sites/default',
      notify => Service['radiusd']
    }
  }

  if $enable_inner_tunnel {
    file { '/etc/raddb/sites-enabled/inner-tunnel':
      ensure => link,
      owner  => 'root',
      group  => 'radiusd',
      mode   => '0640',
      target => '/etc/raddb/sites-available/inner-tunnel',
      notify => Service['radiusd']
    }
  }

}
