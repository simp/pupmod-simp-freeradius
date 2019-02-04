# == Class: freeradius::v3::conf
#
#
#
# If you use this class and do not copy configurations files using
# rsync ('use_rsync_radiusd_conf = true') then
# you *must* also declare the follwing classes within the node scope:
# * freeradius::conf::client
# * freeradius::conf::instantiate
# * freeradius::conf::listener
#
# == Parameters
#
# @param default_acct_listener
#   Whether or not to set up the default acct listener.
#
# @param firewall
#   Whether or not to configure the firewall for radius ports
#
# @param use_rsync_radiusd_conf
#   If set to true, then the variables here will not be used, instead the
#   system will use configuration files pulled from  rsync. To make this
#   work, you will need to create your own radiusd.conf and other config
#   files in the freeradius rsync directory on the puppet server.
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
# @param radius_rsync_user
#   Since radius holds sensitive information, the rsync space should be accordingly protected.
#   This has been designed with the assuption that you will utilize
#   the internal passgen mechanism to set the password. You can optionally specify
#   $radius_rsync_password
#
# @param radius_rsync_password
#   If no password is specified, passgen will be used
#
# @param trusted_nets
#   An array of networks that are allowed to access the radius server.
#
# The following parameters are settings in the radius.conf file.
# @see radiusd.conf(5) and /etc/raddb/radiusd.conf.sample for additional information.
#
# @param localstatedir
# @param max_request_time
# @param cleanup_delay
# @param max_requests
# @param hostname_lookups
# @param allow_core_dumps
# @param regular_expressions
# @param extended_expressions
# @param proxy_requests
# @param radius_ports
#   Type: Array
#   Default: ['1812','1813']
#   The ports where radius will listen.
#
# The following are configuration directories and should be defined
# in freeradius::init.  They are included here to simplify templates
# and testing modules.
#  @param  $sysconfdir             = $::freeradius::sysconfdir,
#  @param  $confdir                = $::freeradius::confdir,
#  @param  $logdir                 = $::freeradius::logdir,
#
class freeradius::v3::conf (
  Boolean                 $use_rsync_radiusd_conf = false,
  Simplib::Netlist        $trusted_nets           = simplib::lookup('simp_options::trusted_nets', { 'default_value' => ['127.0.0.1', '::1']}),
  Integer[2,10]           $cleanup_delay          = 5,
  Boolean                 $correct_escapes        = true,
  Boolean                 $default_acct_listener  = true,
  Enum['yes','no']        $hostname_lookups       = 'no',
  Stdlib::AbsolutePath    $localstatedir          = '/var',
  Integer[2,120]          $max_request_time       = 30,
  Integer[256]            $max_requests           = 1024,
  Boolean                 $proxy_requests         = false,
  Array[Simplib::Port]    $radius_ports           = [1812, 1813],
  Boolean                 $include_trigger        = false,
  Boolean                 $include_eap            = true,
  Boolean                 $include_sql            = false,
  Boolean                 $include_mysql_counter  = false,
  Boolean                 $include_sqlippool      = false,
  String                  $rsync_source           = "freeradius_${::environment}_${facts['os']['name']}/",
  Simplib::Host           $rsync_server           = simplib::lookup('simp_options::rsync::server', { 'default_value' => '127.0.0.1'}),
  Integer                 $rsync_timeout          = simplib::lookup('simp_options::rsync::timeout', { 'default_value' => 2}),
  Optional[Integer]       $rsync_bwlimit          = undef,
  String                  $radius_rsync_user      = "freeradius_systems_${::environment}_${facts['os']['name'].downcase}",
  Optional[String]        $radius_rsync_password  = undef,
  Stdlib::Absolutepath    $sysconfdir             = $::freeradius::sysconfdir,
  Stdlib::Absolutepath    $confdir                = $::freeradius::confdir,
  Stdlib::Absolutepath    $logdir                 = $::freeradius::logdir,
  Boolean                 $firewall               = $::freeradius::firewall,
) {

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


  if $use_rsync_radiusd_conf {
    include '::rsync'

    file { "${confdir}/radiusd.conf":
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
      target   => $confdir,
      server   => $rsync_server,
      timeout  => $rsync_timeout,
      notify   => Service['radiusd'],
      bwlimit  => $rsync_bwlimit,
      user     => $radius_rsync_user,
      password => $_password
    }

  }
  else {

    # Rsync is not being used.  Create configuration files.

    include 'freeradius::v3::conf::sites'
    include 'freeradius::v3::modules'
    include 'freeradius::conf::log'
    include 'freeradius::conf::security'
    include 'freeradius::conf::thread_pool'

    file { "${confdir}/radiusd.conf":
      ensure  => 'file',
      owner   => 'root',
      group   => 'radiusd',
      mode    => '0640',
      content => template('freeradius/3/radiusd.conf.erb'),
      notify  => Service['radiusd'],
    }

    ensure_resource ('file',  "${confdir}/conf.d",
      {
        ensure => 'directory',
        owner  => 'root',
        group  => 'radiusd',
        mode   => '0640',
        purge  => true,
        before => Service['radiusd'],
      })

    if $include_trigger {
      file { "${confdir}/trigger.conf":
        ensure => 'file',
        owner  => 'root',
        group  => 'radiusd',
        mode   => '0640'
      }
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
