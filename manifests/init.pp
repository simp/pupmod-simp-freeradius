# @summary Configure a Freeradius server
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
#   Name of the package
#
# @param user
# @param uid
# @param group
# @param gid
#   The user and group information for the local system that is used to run
#   freeradius.
#
# @param sysconfdir
#   Top level configuration directory.
#
# @param confdir
#   The configuration directories where the radius files are kept.
#
# @param logdir  freeradius log directory
#
# @param testcerts
#   Whether or not freeradius should generate test certs at installation time.
#
# @param use_rsync
#   If true rsync will be used to copy configuration files into place.
#   The other configuration manifests only work with freeradius version 3 or later,
#   if you are using an earlier version you will need to copy files this way.
#   rsync will not remove any files so you can use a combination of rsync and manifests.
#
# @param package_ensure
#   String to pass to the freeradius package ensure attribute
#
# @param manage_sites_enabled
#   If true then only sites managed by puppet will be allowed in the sites-enabled
#   directory.  Files that are rsync'd are not "managed" by puppet.
#   Use the freeradius::v3::site define or a file resource to create sites.
#
#
# @author https://github.com/simp/pupmod-simp-freeradius/graphs/contributors
#
class freeradius (
  Variant[Boolean,Enum['simp']]  $pki                     = simplib::lookup('simp_options::pki', { 'default_value'         => false }),
  Boolean                        $firewall                = simplib::lookup('simp_options::firewall', { 'default_value'    => false}),
  Boolean                        $fips                    = simplib::lookup('simp_options::fips', {'default_value' => false }),
  String                         $freeradius_name         = 'freeradius',
  String                         $user                    = 'radiusd',
  Integer                        $uid                     = 95,
  String                         $group                   = 'radiusd',
  Integer                        $gid                     = 95,
  Boolean                        $testcerts               = false,
  Boolean                        $use_rsync               = false,

  Stdlib::Absolutepath           $app_pki_dir             = '/etc/pki/simp_apps/freeradius/x509',
  Stdlib::Absolutepath           $app_pki_cert            = "${app_pki_dir}/public/${::fqdn}.pub",
  Stdlib::Absolutepath           $app_pki_key             = "${app_pki_dir}/private/${::fqdn}.pem",
  Stdlib::Absolutepath           $app_pki_ca              = "${app_pki_dir}/cacerts/cacerts.pem",
  Stdlib::Absolutepath           $app_pki_ca_dir          = "${app_pki_dir}/cacerts",
  Stdlib::Absolutepath           $app_pki_external_source = simplib::lookup('simp_options::pki::source', { 'default_value' => '/etc/pki/simp/x509' }),
  Stdlib::Absolutepath           $sysconfdir              = '/etc',
  Stdlib::Absolutepath           $confdir                 = "${sysconfdir}/raddb",
  Stdlib::Absolutepath           $logdir                  = '/var/log/freeradius',
  Boolean                        $manage_sites_enabled    = false,
  String                         $package_ensure          = simplib::lookup('simp_options::package_ensure', { 'default_value' => 'installed' }),

) {

  if $fips or $facts['fips_enabled'] {
    warning('RADIUS, by design, must have MD5 support. FreeRADIUS (and RADIUS period) cannot be supported in FIPS mode.')
  } else {
    include 'freeradius::install'
    include 'freeradius::config'
    include 'freeradius::service'
    Class['freeradius::install'] -> Class['freeradius::config'] ~> Class['freeradius::service']
  }
}
