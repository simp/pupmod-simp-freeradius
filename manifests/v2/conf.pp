# == Class: freeradius::v2::conf
#
# Configure a freeradius server.
#
# This can only be defined *once* in a namespace.
#
# See radiusd.conf(5) and ${freeradius::confdir/radiusd.conf.sample for
# additional information.
#
# If you use this class and do not set 'use_rsync_radiusd_conf = true' then
# you *must* also declare the following classes within the node scope:
# * freeradius::conf::client
# * freeradius::conf::instantiate
# * freeradius::conf::listener
# * freeradius::conf::log
# * freeradius::conf::modules
# * freeradius::conf::security
# * freeradius::conf::thread_pool
#
# == Parameters
#
# @param use_rsync_radiusd_conf
#   If set to true, then the variables here will not be used, instead the
#   system will use a radiusd.conf that is pulled from rsync. To make this
#   work, you will need to create your own radiusd.conf in the freeradius
#   rsync directory on the puppet server.
#
# @param rsync_server
#   Default: 127.0.0.1
#   If $use_rsync_radiusd_conf is true, specify the rsync server from
#   which to pull here.
#
# @param rsync_timeout
#   Default: '2'
#   If $use_rsync_radiusd_conf is true, specify the rsync connection
#   timeout here.
#
# @param trusted_nets
#   An array of networks that are allowed to access the radius server.
#
# @param localstatedir
# @param logdir
# @param expose_shadow
#   If set to true use the POSIX extended ACLs to give the radiusd
#   user access to /etc/shadow.
#
# @param radius_port
#   The port where radius will listen.
#
# @param radius_rsync_user
#   Since radius holds sensitive information, the rsync space should
#   be accordingly protected.
#   This define has been designed with the assuption that you will
#   utilize the internal passgen mechanism to set the password. You
#   can optionally specify $radius_rsync_password
#
# @param radius_rsync_password
#   If no password is specified, passgen will be used
#
# @param max_request_time
# @param cleanup_delay
# @param max_requests
# @param default_acct_listener
#   Whether or not to set up the default acct listener.
#
# @param hostname_lookups
# @param allow_core_dumps
# @param regular_expressions
# @param extended_expressions
# @param proxy_requests
#
class freeradius::v2::conf (
  Boolean                 $use_rsync_radiusd_conf = false,
  String                  $rsync_source           = "freeradius_${::environment}_${facts['os']['name']}/",
  Simplib::Host           $rsync_server           = simplib::lookup('simp_options::rsync::server', { 'default_value' => '127.0.0.1', 'value_type' => String }),
  Integer                 $rsync_timeout          = simplib::lookup('simp_options::rsync::timeout', { 'default_value' => 2, 'value_type' => Integer }),
  Optional[Integer]       $rsync_bwlimit          = undef,
  Simplib::Netlist        $trusted_nets           = simplib::lookup('simp_options::trusted_nets', { 'default_value' => ['127.0.0.1', '::1'], 'value_type' => Array[String] }),
  Stdlib::Absolutepath    $localstatedir          = '/var',
  Boolean                 $expose_shadow          = false,
  Simplib::Port           $radius_port            = 1812,
  Optional[String]        $radius_rsync_password  = undef,
  Integer[2,120]          $max_request_time       = 30,
  Integer[2,10]           $cleanup_delay          = 5,
  Integer[256]            $max_requests           = 1024,
  Boolean                 $default_acct_listener  = true,
  Boolean                 $hostname_lookups       = false,
  Boolean                 $allow_core_dumps       = false,
  Boolean                 $regular_expressions    = true,
  Boolean                 $extended_expressions   = true,
  Boolean                 $proxy_requests         = false,
  String                  $radius_rsync_user      = "freeradius_systems_${::environment}_${facts['os']['name'].downcase}",
) {

  file { $freeradius::logdir :
    ensure => 'directory',
    owner  => 'radiusd',
    group  => 'radiusd',
    mode   => '0640',
  }

  file { [
    "${freeradius::logdir}/linelog",
    "${freeradius::logdir}/radutmp",
    "${freeradius::logdir}/radwtmp",
    "${freeradius::logdir}/sradutmp"
  ]:
    ensure => 'file',
    owner  => 'radiusd',
    group  => 'radiusd',
    mode   => '0640',
    before => Service['radiusd'],
  }

  file { "${freeradius::confdir}/conf":
    ensure => 'directory',
    owner  => 'root',
    group  => 'radiusd',
    mode   => '0640',
    before => Service['radiusd'],
  }

  if $use_rsync_radiusd_conf {

    include '::rsync'

    file { "${freeradius::confdir}/radiusd.conf":
      ensure => 'file',
      owner  => 'root',
      group  => 'radiusd',
      mode   => '0640',
      notify => Service['radiusd'],
    }

    $_password = $radius_rsync_password ? {
      undef   => passgen($radius_rsync_user),
      default => $radius_rsync_password
    }

    rsync { 'freeradius':
      source   => $rsync_source,
      target   => $freeradius::confdir,
      server   => $rsync_server,
      timeout  => $rsync_timeout,
      notify   => [
        File[$freeradius::confdir],
        Service['radiusd']
      ],
      bwlimit  => $rsync_bwlimit,
      user     => $radius_rsync_user,
      password => $_password
    }
  }
  else {
    include freeradius::v2::modules
    file { "${freeradius::confdir}/radiusd.conf":
      ensure  => 'file',
      owner   => 'root',
      group   => 'radiusd',
      mode    => '0640',
      content => template('freeradius/2/radiusd.conf.erb'),
      notify  => Service['radiusd'],
    }
  }

  if $default_acct_listener {
    freeradius::conf::listener { 'default_acct':
      ipaddr      => 'ALL',
      port        => 0,
      listen_type => 'acct'
    }
  }

  if $freeradius::firewall {
    iptables::listen::udp { 'radius_iptables':
      trusted_nets => $trusted_nets,
      dports       => $radius_port
    }
  }

  # Hack to ensure that the passgen function is loaded.
  if false { passgen(false) }
}
