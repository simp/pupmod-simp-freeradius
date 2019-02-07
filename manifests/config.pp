# == Class: freeradius::config
#
# Configure a freeradius server.
#
class freeradius::config(
) {

  if $freeradius::pki {
    ::pki::copy { 'freeradius':
      source => $freeradius::app_pki_external_source,
      pki    => $freeradius::pki,
      group  => $freeradius::group,
    }
  }

  file { $freeradius::confdir:
    ensure => directory,
    owner  => 'root',
    group  => $freeradius::group,
    mode   => '0750',
  }

  if $freeradius::testcerts {
    exec { "${freeradius::confdir}/certs/bootstrap":
      path      => "/usr/bin:/usr/sbin:/bin:${freeradius::confdir}/certs",
      unless    => "test -f ${freeradius::confdir}/certs/server.pem",
      logoutput => true,
      require   => Package[$freeradius::freeradius_name]
    }
    file { "${freeradius::confdir}/certs":
      owner        => 'root',
      group        => $freeradius::group,
      mode         => '0750',
      recurse      => true,
      recurselimit => 1
    }
  }

  if $freeradius::use_rsync {
    include 'freeradius::conf::rsync'
  } else {
    if $facts['radius_version'] and $facts['radius_version'] != 'unknown'] {
      if versioncmp($facts['radius_verson'], '3.0') < 0 {
        warning("{$module_name} : This module is designed to work with freeradius version 3.X. The current version installed is $facts['radius_version']")
      } else {
        include 'freeradius::v3::conf'
      }
    } else {
      warning("{$module_name} : The version freeradius installed is unknown.  This message is expected if puppet has just installed freeradius. If it repeats, there is something wrong with the freeradius package installation.")
    }
  }
}
