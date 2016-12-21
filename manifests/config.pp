# == Class: freeradius::config
#
# Configure a freeradius server.
#
# This can only be defined *once* in a namespace.
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
# * Nick Markowski <nmarkowski@keywcorp.com>
#
class freeradius::config(
  $logdir      = '/var/log/freeradius'
) inherits freeradius {

  file { $::freeradius::app_pki_dir:
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755'
  }

  if $::freeradius::pki {
    ::pki::copy { $::freeradius::app_pki_dir:
      pki     => $::freeradius::pki,
      source  => $::freeradius::app_pki_external_source,
      group   => 'radiusd',
      require => File[$::freeradius::app_pki_dir],
    }
  }
  else {
    file { "${::freeradius::app_pki_dir}/pki":
      ensure => 'directory',
      owner  => 'root',
      group  => 'root',
      mode   => '0640'
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
  if $::operatingsystem in ['RedHat', 'CentOS'] {
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
    warning("${::operatingsystem} not yet supported. Current options are RedHat and CentOS")
  }
}
