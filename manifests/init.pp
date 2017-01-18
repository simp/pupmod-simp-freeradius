# == Class: freeradius
#
# Configure a Freeradius server.
#
# @param pki
#   * If 'simp', include SIMP's pki module and use pki::copy to manage
#     application certs in /etc/pki/simp_apps/freeradius/x509
#   * If true, do *not* include SIMP's pki module, but still use pki::copy
#     to manage certs in /etc/pki/simp_apps/freeradius/x509
#   * If false, do not include SIMP's pki module and do not use pki::copy
#     to manage certs.  You will need to appropriately assign a subset of:
#     * app_pki_dir
#     * app_pki_key
#     * app_pki_cert
#     * app_pki_ca
#     * app_pki_ca_dir
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
# * Nick Markowski <nmarkowski@keywcorp.com>
#
class freeradius (
  $pki                     = simplib::lookup('simp_options::pki', { 'default_value' => false, 'value_type' => Variant[Boolean, Enum['simp']] }),
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
