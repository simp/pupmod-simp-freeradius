# == Class: freeradius::config
#
# Manage the permissions on directories and files
# and then either rsync content or create content.
#
class freeradius::config(
) {

  assert_private()

  if $freeradius::pki {
    ::pki::copy { 'freeradius':
      source => $freeradius::app_pki_external_source,
      pki    => $freeradius::pki,
      group  => $freeradius::group,
    }
  }

  $config_file_settings = {
    owner  => 'root',
    group  => $freeradius::group,
    mode   => '0640',
  }

  file { $freeradius::confdir:
    ensure => 'directory',
    *      => $config_file_settings
  }

  if $freeradius::testcerts {
    exec { "${freeradius::confdir}/certs/bootstrap":
      path      => "/usr/bin:/usr/sbin:/bin:${freeradius::confdir}/certs",
      unless    => "test -f ${freeradius::confdir}/certs/server.pem",
      logoutput => true,
      require   => Package[$freeradius::freeradius_name]
    }
    file { "${freeradius::confdir}/certs":
      ensure       => 'directory',
      recurse      => true,
      recurselimit => 1,
      *            => $config_file_settings
    }
  }

  file { ["${freeradius::confdir}/mods-config",
          "${freeradius::confdir}/mods-available",
          "${freeradius::confdir}/mods-enabled",
          "${freeradius::confdir}/sites-available"]:
    ensure  => 'directory',
    require => File[$freeradius::confdir],
    *       => $config_file_settings
  }

  file { "${freeradius::confdir}/sites-enabled":
    ensure  => 'directory',
    recurse => true,
    require => File[$freeradius::confdir],
    purge   => $freeradius::manage_sites_enabled,
    *       => $config_file_settings
  }

  if $freeradius::use_rsync {
    include 'freeradius::config::rsync'
  }
  else {
    if $facts['radius_version'] and $facts['radius_version'] != 'unknown' {
      if versioncmp($facts['radius_version'], '3') < 0 {
        warning("${module_name} : This module is designed to work with freeradius version 3.X. The current version installed is ${facts['radius_version']}")
      }
      else {
        include 'freeradius::v3::conf'
      }
    }
    else {
      warning("${module_name} : The version freeradius installed is unknown.")
    }
  }
}
