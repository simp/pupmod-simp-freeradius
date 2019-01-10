# == Class: freeradius::v3::conf
#
# Configure a freeradius server.
#
# This can only be defined *once* in a namespace.
#
# See radiusd.conf(5) and /etc/raddb/radiusd.conf.sample for additional information.
#
# If you use this class and do not set 'use_rsync_radiusd_conf = true' then
# you *must* also declare the follwing classes within the node scope:
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
#
# @param radius_ports
#   Type: Array
#   Default: ['1812','1813']
#   The ports where radius will listen.
#
# @param radius_rsync_user
#   Since radius holds sensitive information, the rsync space should be accordingly protected.
#   This has been designed with the assuption that you will utilize
#   the internal passgen mechanism to set the password. You can optionally specify
#   $radius_rsync_password
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
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
#
class freeradius::v3::conf (
  Integer[2,10]           $cleanup_delay          = 5,
  Simplib::Netlist        $trusted_nets           = simplib::lookup('simp_options::trusted_nets', { 'default_value' => ['127.0.0.1', '::1']}),
  Boolean                 $default_acct_listener  = true,
  Boolean                 $extended_expressions   = true,
  Boolean                 $hostname_lookups       = false,
  Stdlib::AbsolutePath    $localstatedir          = '/var',
  Stdlib::AbsolutePath    $logdir                 = $::freeradius::logdir,
  Integer[2,120]          $max_request_time       = 30,
  Integer[256]            $max_requests           = 1024,
  Boolean                 $proxy_requests         = false,
  String                  $rsync_source           = "freeradius_${::environment}_${facts['os']['name']}/",
  Simplib::Host           $rsync_server           = simplib::lookup('simp_options::rsync::server', { 'default_value' => '127.0.0.1'}),
  Integer                 $rsync_timeout          = simplib::lookup('simp_options::rsync::timeout', { 'default_value' => 2}),
  Optional[Integer]       $rsync_bwlimit          = undef,
  Array[Simplib::Port]    $radius_ports           = [1812, 1813],
  String                  $radius_rsync_user      = "freeradius_systems_${::environment}_${facts['os']['name'].downcase}",
  Optional[String]        $radius_rsync_password  = undef,
  Boolean                 $regular_expressions    = true,
  Boolean                 $use_rsync_radiusd_conf = false,
  Boolean                 $firewall               = $::freeradius::firewall,
) {

  include '::freeradius::v3::conf::sites'
  include '::freeradius::v3::conf::policy'

  file { $logdir:
    ensure => 'directory',
    owner  => 'radiusd',
    group  => 'radiusd',
    mode   => '0640',
  }

  file { [
    "${logdir}/linelog",
    "${logdir}/radutmp",
    "${logdir}/radwtmp",
    "${logdir}/sradutmp"
  ]:
    ensure => 'file',
    owner  => 'radiusd',
    group  => 'radiusd',
    mode   => '0640',
    before => Service['radiusd'],
  }

  file { '/etc/raddb/conf':
    ensure => 'directory',
    owner  => 'root',
    group  => 'radiusd',
    mode   => '0640',
    before => Service['radiusd'],
  }

  if $use_rsync_radiusd_conf {
    include '::rsync'

    file { '/etc/raddb/radiusd.conf':
      ensure => 'file',
      owner  => 'root',
      group  => 'radiusd',
      mode   => '0640',
      notify => Service['radiusd'],
    }

    $_password = $radius_rsync_password ? {
      'nil'   => passgen($radius_rsync_user),
      default => $radius_rsync_password
    }

    rsync { 'freeradius':
      source   => $rsync_source,
      target   => '/etc/raddb',
      server   => $rsync_server,
      timeout  => $rsync_timeout,
      notify   => [
        File['/etc/raddb'],
        Service['radiusd']
      ],
      bwlimit  => $rsync_bwlimit,
      user     => $radius_rsync_user,
      password => $_password
    }
  }
  else {
    file { '/etc/raddb/radiusd.conf':
      ensure  => 'file',
      owner   => 'root',
      group   => 'radiusd',
      mode    => '0640',
      content => template('freeradius/3/radiusd.conf.erb'),
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

  if $firewall {
    iptables::listen::udp { 'radius_iptables':
      trusted_nets => $trusted_nets,
      dports       => $radius_ports
    }
  }
}
