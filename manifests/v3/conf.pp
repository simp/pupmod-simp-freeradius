# == Class: freeradius::v3::conf
#
#  This class will configure the radiusd.conf file.
#
#  If clients_conf_source is set, it will copy the file
#  from the source to the clients.conf file and include it
#  in the source. Otherwise it includes clients.d/* and clients
#  will have to be set up using the v3/client manifest.
#
#  If trigger_conf_source is set it will copy the file indicated in
#  source to trigger.conf and include this file in the radius.conf.
#
# == Parameters
#
# @param protocol
#   What protocols will be used to make sure the firewall is opened correctly
#
# @param trusted_nets
#   An array of networks that are allowed to access the radius server.
#
# @param clients_conf_source
#   Source for the clients.conf file if not creating clients individualy
#
# @param proxy_conf_source
#   If proxy_request is true it will use this source for the proxy.conf file
#
# @param trigger_conf_source
#   This source for the trigger.conf file, when set
#
# The following parameters are settings in the radius.conf file.
# @see radiusd.conf(5) and /etc/raddb/radiusd.conf.sample for additional information.
#
# @param localstatedir
# @param max_request_time
# @param cleanup_delay
# @param correct_escapes
# @param max_requests
# @param hostname_lookups
# @param radius_ports
#   Type: Array
#   Default: ['1812','1813']
#   The ports where radius will listen.
#
class freeradius::v3::conf (
  Simplib::Netlist        $trusted_nets           = simplib::lookup('simp_options::trusted_nets', { 'default_value' => ['127.0.0.1', '::1']}),
  Integer[2,10]           $cleanup_delay          = 5,
  Boolean                 $correct_escapes        = true,
  Boolean                 $default_acct_listener  = true,
  Boolean                 $hostname_lookups       = false,
  Stdlib::AbsolutePath    $localstatedir          = '/var',
  Integer[2,120]          $max_request_time       = 30,
  Integer[256]            $max_requests           = 1024,
  Array[Simplib::Port]    $radius_ports           = [1812, 1813],
  Enum['udp','tcp','ALL'] $protocol               = 'ALL',
  Optional[String]        $clients_conf_source    = undef,
  Optional[String]        $proxy_conf_source      = undef,
  Optional[String]        $trigger_conf_source    = undef,
  Optional[String]        $users_conf_source      = undef,
) {

  assert_private()

  include 'freeradius::v3::radiusd_conf::log'
  include 'freeradius::v3::radiusd_conf::security'
  include 'freeradius::v3::radiusd_conf::thread_pool'
  include 'freeradius::v3::radiusd_conf::instantiate'

  Class[freeradius::config]
  -> Class[freeradius::v3::conf]
  -> [Class[freeradius::v3::radiusd_conf::thread_pool],
      Class[freeradius::v3::radiusd_conf::log],
      Class[freeradius::v3::radiusd_conf::instantiate],
      Class[freeradius::v3::radiusd_conf::security]]

  ############################
  #  Manage permissions on log files

  $log_file_settings = {
    owner => $freeradius::user,
    group => $freeradius::group,
    mode  => '0640',
  }
  file { $freeradius::logdir:
    ensure => 'directory',
    *      => $log_file_settings,
  }

  file { "${freeradius::logdir}/radacct":
    ensure => 'directory',
    *      => $log_file_settings,
  }

  file { [
    "${freeradius::logdir}/linelog",
    "${freeradius::logdir}/radutmp",
    "${freeradius::logdir}/radwtmp",
    "${freeradius::logdir}/sradutmp"
  ]:
    ensure  => 'file',
    *       => $log_file_settings,
    require => File[$freeradius::logdir],
    before  => Service['radiusd'],
  }
  #
  ############################

  ############################
  #  Create radiusd.conf
  #  and  its included sections
  #  in conf.d
  #
  $file_settings = {
    owner => 'root',
    group => $freeradius::group,
    mode  => '0640',
  }

  file { "${freeradius::confdir}/radiusd.conf":
    ensure  => 'file',
    content => epp('freeradius/3/radiusd.conf.epp'),
    notify  => Service['radiusd'],
    *       => $file_settings,
  }

  ensure_resource ('file',  "${freeradius::confdir}/conf.d",
    {
      ensure   => 'directory',
      before   => Service['radiusd'],
      owner    => 'root',
      group    => $freeradius::group,
      recurse  => true,
      purge    => true,
      mode     => '0640',
    })

  file { "${freeradius::confdir}/policy.d":
    ensure => 'directory',
    *      => $file_settings,
  }

  #  This does not create the trigger file
  #  it just sets the permissions and the
  #  if include trigger is true it will ensure
  #  the radiusd.conf file includes the file.
  if $trigger_conf_source {
    file { "${freeradius::confdir}/trigger.conf":
      ensure => 'file',
      source => $trigger_conf_source,
      *      => $file_settings,
    }
  }

  if $proxy_conf_source {
    file { "${freeradius::confdir}/proxy.conf":
      ensure => 'file',
      source => $proxy_conf_source,
      *      => $file_settings,
    }
  }

  #
  ##########################

  #########################
  # Create clients.conf file
  #
  if $clients_conf_source {
    # If you have a specific client file to copy
    file { "${freeradius::confdir}/clients.conf":
      ensure => file,
      source => $clients_conf_source,
      *      => $file_settings,
    }
  } else {
    # create individual files in the clients directory
    ensure_resource('file', "${freeradius::confdir}/clients.d",
    {
      ensure => 'directory',
      owner  => 'root',
      group  => $freeradius::group,
      mode   => '0640',
    })
    file { "${freeradius::confdir}/clients.conf":
      ensure  => file,
      content => epp("${module_name}/3/clients.conf.epp"),
      *       => $file_settings,
    }
  }

  #
  #  If managing users create the users file.
  if $users_conf_source {
    file { "${freeradius::confdir}/mods-config/files/authorize":
      ensure => file,
      source => $users_conf_source,
      *      => $file_settings,
    }
  } else {
    Class[freeradius::v3::conf] -> Class[freeradius::v3::conf::users]
    include 'freeradius::v3::conf::users'
  }
  #
  #  If using firewall open the radius ports to listen on.
  if $freeradius::firewall {
    if $protocol == 'udp' or $protocol == 'ALL' {
      iptables::listen::udp { 'radius_iptables_udp':
        trusted_nets => $trusted_nets,
        dports       => $radius_ports
      }
    }
    if $protocol == 'tcp' or $protocol == 'ALL' {
      iptables::listen::tcp_stateful  {'radius_iptables_tcp':
        trusted_nets => $trusted_nets,
        dports       => $radius_ports
      }
    }
  }

}
