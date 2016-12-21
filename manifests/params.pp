# Class freeradius::params
#
class freeradius::params {
  if $::operatingsystem in ['RedHat','CentOS'] and ( versioncmp($::operatingsystemmajrelease,'6') < 0 ) {
    $freeradius_name = 'freeradius2'
  }
  else {
    $freeradius_name = 'freeradius'
  }
  $freeradius_ver = "${freeradius_name}.${::hardwaremodel}"
  $app_pki_dir = '/etc/radius_simp'
}
