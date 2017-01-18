# == Class: freeradius::config
#
# Configure a freeradius server.
#
# This can only be defined *once* in a namespace.
#
# @param app_pki_external_source
#   * If pki = 'simp' or true, this is the directory from which certs will be
#     copied, via pki::copy.  Defaults to /etc/pki/simp/x509.
#
#   * If pki = false, this variable has no effect.
#
# @param app_pki_dir
#   This variable controls the basepath of $app_pki_key, $app_pki_cert,
#   $app_pki_ca, $app_pki_ca_dir, and $app_pki_crl.
#   It defaults to /etc/pki/simp_apps/freeradius/x509.
#
# @param app_pki_key
#   Path and name of the private SSL key file
#
# @param app_pki_cert
#   Path and name of the public SSL certificate
#
# @param app_pki_ca_dir
#   Path to the CA.
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
# * Nick Markowski <nmarkowski@keywcorp.com>
#
class freeradius::config(
  $app_pki_external_source = simplib::lookup('simp_options::pki::source', { 'default_value' => '/etc/pki/simp/x509' }),
  $app_pki_dir             = '/etc/pki/simp_apps/freeradius/x509',
  $app_pki_cert            = "${app_pki_dir}/public/${facts['fqdn']}.pub",
  $app_pki_key             = "${app_pki_dir}/private/${facts['fqdn']}.pem",
  $app_pki_ca_dir          = "${app_pki_dir}/cacerts",
  $logdir                  = '/var/log/freeradius'
) inherits freeradius {

  if $::freeradius::pki {
    ::pki::copy { 'freeradius':
      source => $app_pki_external_source,
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
