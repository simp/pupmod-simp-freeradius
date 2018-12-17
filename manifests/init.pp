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

# @param firewall
#   If true set rules to open ports on  firewall
#
# @param freeradius_name
#   name of the package
#
# @param logdir  logging directory
# @param package_ensure
#   String to pass to the freeradius package ensure attribute
#
# @param freeradius_ver
#   version of the package to install
#
# @author https://github.com/simp/pupmod-simp-simp/graphs/contributors
#
#
#
class freeradius (
  Variant[Boolean,Enum['simp']]  $pki                     = simplib::lookup('simp_options::pki', { 'default_value' => false }),
  Boolean                        $firewall                = simplib::lookup('simp_options::firewall', { 'default_value' => false}),
  String                         $freeradius_name         = 'freeradius2',

  String                         $freeradius_ver          = "freeradius2.${facts['hardwaremodel']}",
  Stdlib::Absolutepath           $app_pki_dir             = '/etc/pki/simp_apps/freeradius/x509',
  Stdlib::Absolutepath           $app_pki_cert            = "${app_pki_dir}/public/${::fqdn}.pub",
  Stdlib::Absolutepath           $app_pki_key             = "${app_pki_dir}/private/${::fqdn}.pem",
  Stdlib::Absolutepath           $app_pki_ca              = "${app_pki_dir}/cacerts/cacerts.pem"
  Stdlib::Absolutepath           $app_pki_external_source = simplib::lookup('simp_options::pki::source', { 'default_value' => '/etc/pki/simp/x509' }),
  Stdlib::Absolutepath           $logdir                  = '/var/log/freeradius',
  String                         $package_ensure          = simplib::lookup('simp_options::package_ensure', { 'default_value' => 'installed' }),

) {

  include '::freeradius::install'
  include '::freeradius::config'
  include '::freeradius::service'

  Class['freeradius::install'] ->
  Class['freeradius::config'] ~>
  Class['freeradius::service'] ->
  Class['freeradius']
}
