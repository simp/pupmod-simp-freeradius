# This module will rsync the configurations files to $freeradius::confdir
# It does not remove any other files that exist in that directory
#
# The defaults in this module use the freeradius share set up
# by the simp module in the simp::server::rsync_shares manifest.
#
# == Parameters
#
# @param rsync_source
#  The  source  on the rsync server
#
# @param rsync_server
#   Default: 127.0.0.1
#   If $use_rsync_radiusd_conf is true, specify the rsync server from
#   which to pull here.
#
# @param radius_rsync_user
#   Since radius holds sensitive information, the rsync space should be accordingly protected.
#   This has been designed with the assuption that you will utilize
#   the internal simplib::passgen mechanism to set the password. You can optionally specify
#   $radius_rsync_password
#
# @param radius_rsync_password
#   If no password is specified, simplib::passgen will be used
#
# @param rsync_timeout
#   Default: '2'
#   If $use_rsync_radiusd_conf is true, specify the rsync connection
#   timeout here.
#
# @param rsync_bwlimit
#   rsync bandwidth limit
class freeradius::config::rsync (
  String                  $rsync_source           = "freeradius_${::environment}_${facts['os']['name']}/",
  Simplib::Host           $rsync_server           = simplib::lookup('simp_options::rsync::server', { 'default_value' => '127.0.0.1'}),
  String                  $radius_rsync_user      = "freeradius_systems_${::environment}_${facts['os']['name'].downcase}",
  String                  $radius_rsync_password  = simplib::passgen($radius_rsync_user),
  Integer                 $rsync_timeout          = simplib::lookup('simp_options::rsync::timeout', { 'default_value' => 2}),
  Optional[Integer]       $rsync_bwlimit          = undef,
) {

  assert_private()

  include 'rsync'

  Class['freeradius::config']
  -> Class['freeradius::config::rsync']

  rsync { 'freeradius':
    source   => $rsync_source,
    target   => $::freeradius::confdir,
    server   => $rsync_server,
    timeout  => $rsync_timeout,
    notify   => Service['radiusd'],
    bwlimit  => $rsync_bwlimit,
    user     => $radius_rsync_user,
    password => $radius_rsync_password
  }

  file { "${freeradius::confdir}/radiusd.conf":
    ensure  => 'file',
    owner   => 'root',
    group   => $freeradius::group,
    require => Rsync['freeradius'],
    mode    => '0640',
  }
}
