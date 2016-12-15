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
# * freeradius::conf::listen::add
# * freeradius::conf::log
# * freeradius::conf::modules
# * freeradius::conf::security
# * freeradius::conf::thread_pool
#
# == Parameters
#
# [*use_rsync_radiusd_conf*]
#   If set to true, then the variables here will not be used, instead the
#   system will use a radiusd.conf that is pulled from rsync. To make this
#   work, you will need to create your own radiusd.conf in the freeradius
#   rsync directory on the puppet server.
#
# [*rsync_server*]
#   Default: 127.0.0.1
#   If $use_rsync_radiusd_conf is true, specify the rsync server from
#   which to pull here.
#
# [*rsync_timeout*]
#   Default: '2'
#   If $use_rsync_radiusd_conf is true, specify the rsync connection
#   timeout here.
#
# [*trusted_nets*]
#   An array of networks that are allowed to access the radius server.
#
# [*localstatedir*]
# [*logdir*]
#
# [*radius_ports*]
#   Type: Array
#   Default: ['1812','1813']
#   The ports where radius will listen.
#
# [*radius_rsync_user*]
#   Since radius holds sensitive information, the rsync space should be accordingly protected.
#   This define has been designed with the assuption that you will utilize
#   the internal passgen mechanism to set the password. You can optionally specify
#   $radius_rsync_password
#
# [*radius_rsync_password*]
#   If no password is specified, passgen will be used
#
# [*max_request_time*]
# [*cleanup_delay*]
# [*max_requests*]
# [*default_acct_listener*]
#   Whether or not to set up the default acct listener.
#
# [*hostname_lookups*]
# [*allow_core_dumps*]
# [*regular_expressions*]
# [*extended_expressions*]
# [*proxy_requests*]
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
#
class freeradius::v3::conf (
  $cleanup_delay          = '5',
  $trusted_nets           = simplib::lookup('simp_options::trusted_nets', { 'default_value' => ['127.0.0.1', '::1'], 'value_type' => Array[String] }),
  $default_acct_listener  = true,
  $extended_expressions   = true,
  $hostname_lookups       = false,
  $localstatedir          = '/var',
  $logdir                 = $::freeradius::config::logdir,
  $max_request_time       = '30',
  $max_requests           = '1024',
  $proxy_requests         = false,
  $rsync_source           = "freeradius_${::environment}/",
  $rsync_server           = simplib::lookup('simp_options::rsync::server', { 'default_value' => '127.0.0.1', 'value_type' => String }),
  $rsync_timeout          = simplib::lookup('simp_options::rsync::timeout', { 'default_value' => '2', 'value_type' => Stdlib::Compat::Integer }),
  $rsync_bwlimit          = '',
  $radius_ports           = ['1812', '1813'],
  $radius_rsync_user      = "freeradius_systems_${::environment}",
  $radius_rsync_password  = 'nil',
  $regular_expressions    = true,
  $use_rsync_radiusd_conf = false,
  $firewall               = $::freeradius::firewall
) inherits ::freeradius::config {

  validate_between(to_integer($cleanup_delay), 2, 10)
  validate_between(to_integer($max_request_time), 5, 120)
  if to_integer($max_requests) <= 256 {
    fail('max_requests must be greater than 256')
  }
  #validate_bool($use_rsync_radiusd_conf)
  #validate_bool($default_acct_listener)
  #validate_bool($hostname_lookups)
  #validate_bool($regular_expressions)
  #validate_bool($extended_expressions)
  #validate_bool($proxy_requests)
  #validate_integer($max_requests)
  validate_net_list($trusted_nets)
  validate_port($radius_ports)

  include '::freeradius'
  include '::freeradius::conf::listen'
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

  if ! $use_rsync_radiusd_conf {
    file { '/etc/raddb/radiusd.conf':
      ensure  => 'file',
      owner   => 'root',
      group   => 'radiusd',
      mode    => '0640',
      content => template('freeradius/3/radiusd.conf.erb'),
      notify  => Service['radiusd'],
    }
  }
  else {
    include '::rsync'

    validate_net_list($rsync_server)
    #validate_integer($rsync_timeout)

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

  if $default_acct_listener {
    freeradius::conf::listen::add { 'default_acct':
      ipaddr      => '*',
      port        => '0',
      listen_type => 'acct'
    }
  }

  if $firewall {
    iptables::add_udp_listen { 'radius_iptables':
      trusted_nets => $trusted_nets,
      dports       => $radius_ports
    }
  }
}
