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
# == Authors
#
# * Kendall Moore <kmoore@keywcorp.com>
#
class freeradius::v3::conf::sites (
  $enable_default      = true,
  $enable_inner_tunnel = true
){
  include '::freeradius'

  if $::operatingsystem in ['RedHat', 'CentOS'] {
    if defined('$::radius_version') and ($::radius_version != 'unknown') {
      if (versioncmp($::radius_version, '3') >= 0) {
        file { '/etc/raddb/conf/sites.inc':
          ensure  => 'file',
          owner   => 'root',
          group   => 'radiusd',
          mode    => '0640',
          content => template('freeradius/3/conf/sites.erb'),
          notify  => Service['radiusd']
        }

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
      }
    }
    else {
      warning('FreeRADIUS does not yet appear to be installed. Please install FreeRADIUS and then continue.')
    }
  }
  else {
    warning("${::operatingsystem} not yet supported. Current options are RedHat and CentOS")
  }

  #validate_bool($enable_default)
  #validate_bool($enable_inner_tunnel)
}
