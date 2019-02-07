# == Class: freeradius::v3::conf
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
# The following are configuration directories and should be set
# in freeradius::init.  They are included here to simplify templates
# and testing modules.
#  @param  $sys::freeradius::confdir             = $::freeradius::sys::freeradius::confdir,
#  @param  $::freeradius::confdir                = $::freeradius::::freeradius::confdir,
#  @param  $::freeradius::logdir                 = $::freeradius::::freeradius::logdir,
#
class freeradius::v3::conf (
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
  Optional[String]        $client_source          = undef,
) {

  include 'freeradius::v3::conf::sites'
  include 'freeradius::v3::modules'

  Class[freeradius::config]
  -> Class[freeradius::v3::conf]
  -> [Class[freeradius::v3::conf::sites],
      Class[freeradius::conf::log],
      Class[freeradius::conf::security],
      Class[freeradius::v3::modules]]

  ############################
  #  Create log directories
  #
  file { $freeradius::logdir:
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
  #
  ###########################

  ############################
  #  Create radiusd.conf
  #  and  its included sections
  #  in conf.d
  #
  file { "${freeradius::confdir}/radiusd.conf":
    ensure  => 'file',
    owner   => 'root',
    group   => 'radiusd',
    mode    => '0640',
    content => epp('freeradius/3/radiusd.conf.epp'),
    notify  => Service['radiusd'],
  }

  ensure_resource ('file',  "${freeradius::confdir}/conf.d",
    {
      ensure => 'directory',
      owner  => 'root',
      group  => 'radiusd',
      mode   => '0640',
      purge  => true,
      before => Service['radiusd'],
    })

  #  This does not create the trigger file
  #  it just sets the permissions and the
  #  if include trigger is true it will ensure
  #  the radiusd.conf file includes the file.
  if $include_trigger {
    file { "${freeradius::confdir}/trigger.conf":
      ensure => 'file',
      owner  => 'root',
      group  => $freeradius::group,
      mode   => '0640'
    }
  }
  include 'freeradius::conf::log'
  include 'freeradius::conf::security'
  #
  ##########################

  #########################
  # create clients
  #
  # If you have a specific client file to copy
  if $client_source {
    file { "${freeradius::confdir}/clients.conf":
      ensure => file,
      owner  => 'root',
      group  => $freeradius::group,
      mode   => '0640',
      source => $client_source
    }
  } else {
    # create individual files in the clients directory
    ensure_resource('file', "${freeradius::confdir}/clients.d",
    {
      ensure  => 'directory',
      owner   => 'root',
      group   => $freeradius::group,
      mode    => '0640',
    })
    file { "${freeradius::confdir}/clients.conf":
      ensure  => file,
      owner   => 'root',
      group   => $freeradius::group,
      mode    => '0640',
      content => epp("${module_name}/3/client.conf.epp")
    }
  }
  #
  ##########################

  #
  # Create a default account listener.
  # Note this is already included in the default site.
  if $default_acct_listener {
    freeradius::v3::conf::listener { 'default_acct':
      ipaddr      => 'ALL',
      port        => 0,
      listen_type => 'acct'
    }
  }

  #
  #  If using firewall open the radius ports to listen on.
  if $freeradius::firewall {
    iptables::listen::udp { 'radius_iptables':
      trusted_nets => $trusted_nets,
      dports       => $radius_ports
    }
  }

}
