# == Class: freeradius
#
# Configure a Freeradius server.
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
# * Nick Markowski <nmarkowski@keywcorp.com>
#
class freeradius (
  $pki                     = simplib::lookup('simp_options::pki', { 'default_value' => false, 'value_type' => Boolean }),
  $app_pki_external_source = simplib::lookup('simp_options::pki::source', { 'default_value' => '/etc/pki/simp' }),
  $firewall                = simplib::lookup('simp_options::firewall', { 'default_value' => false, 'value_type' => Boolean }),
  $freeradius_name         = $::freeradius::params::freeradius_name,
  $freeradius_ver          = $::freeradius::params::freeradius_ver
) inherits freeradius::params {

  include '::freeradius::install'
  include '::freeradius::config'
  include '::freeradius::service'

  Class['freeradius::install'] ->
  Class['freeradius::config'] ~>
  Class['freeradius::service'] ->
  Class['freeradius']
}
