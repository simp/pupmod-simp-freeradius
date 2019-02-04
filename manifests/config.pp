# == Class: freeradius::config
#
# Configure a freeradius server.
#
# This can only be defined *once* in a namespace.

class freeradius::config(
) {

  if $freeradius::pki {
    ::pki::copy { 'freeradius':
      source => $::freeradius::app_pki_external_source,
      pki    => $::freeradius::pki,
      group  => 'radiusd',
    }
  }

  file { $freeradius::confdir:
    owner => 'root',
    group => 'radiusd',
    mode  => '0750',
  }

  file { "${freeradius::confdir}/certs":
    owner   => 'root',
    group   => 'radiusd',
    mode    => '0750',
    recurse => true
  }

  # Version specific configuration
  if $facts['os']['name']in ['RedHat', 'CentOS'] {
    if defined('$::radius_version') and ($::radius_version != 'unknown') {
      if (versioncmp($::radius_version, '3') >= 0) {
        $ver = '3'
        include "freeradius::v${ver}::conf"
      }
      else {
        warning('Only version 3 and later is supported at this time.')
      }

    }
    else {
      warning('FreeRADIUS does not yet appear to be installed. Please install FreeRADIUS and then continue.')
    }
  }
  else {
    warning("${facts['os']['name']} not yet supported. Current options are RedHat and CentOS")
  }
}
