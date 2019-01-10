# == Class: freeradius::config
#
# Configure a freeradius server.
#
# This can only be defined *once* in a namespace.

class freeradius::config(
) {

  if $::freeradius::pki {
    ::pki::copy { 'freeradius':
      source => $::freeradius::app_pki_external_source,
      pki    => $::freeradius::pki,
      group  => 'radiusd',
    }
  }

  # Version agnostic configuration
  include '::freeradius::modules'
  exec { '/etc/raddb/certs/bootstrap':
    path      => '/usr/bin:/usr/sbin:/bin:/etc/raddb/certs',
    unless    => 'test -f /etc/raddb/certs/server.pem',
    logoutput => true,
  }
  exec { '/bin/chgrp -R radiusd /etc/raddb/certs': }
  file { '/etc/raddb':
    owner => 'root',
    group => 'radiusd',
    mode  => '0750',
  }

  # Version specific configuration
  if $facts['os']['name']in ['RedHat', 'CentOS'] {
    if defined('$::radius_version') and ($::radius_version != 'unknown') {
      if (versioncmp($::radius_version, '3') >= 0) {
        $ver = '3'
      }
      else {
        $ver = '2'
      }

      include "::freeradius::v${ver}::conf"
    }
    else {
      warning('FreeRADIUS does not yet appear to be installed. Please install FreeRADIUS and then continue.')
    }
  }
  else {
    warning("${facts['os']['name']} not yet supported. Current options are RedHat and CentOS")
  }
}
