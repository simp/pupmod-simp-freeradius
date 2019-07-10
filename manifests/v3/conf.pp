#  @summary configure the `radiusd.conf` file
#
#  If `clients_conf_content` is set, it will add that content to the
#  `clients.conf` file and include it in the source. Otherwise it includes
#  `clients.d/*` and clients will have to be set up using the `v3/client`
#  class.
#
#  If `trigger_conf_content` is set it will add that content to `trigger.conf`
#  and include this file in the radius.conf.
#
# ## Freeradius Parameters
#
# The following parameters are settings in the radius.conf file.
#
#   @see radiusd.conf(5) for additional information.
#
#   @see Extract the original /etc/raddb/radiusd.conf from the freeradius rpm using
#        rpm2cpio < free radius rpm> | cpio -idmv for detailed information
#        on the parameters.
#
# @param cleanup_delay
# @param correct_escapes
# @param default_acct_listener
# @param hostname_lookups
# @param localstatedir
# @param max_request_time
# @param max_requests
# @param radius_ports
#   The ports where freeradius will listen
#
# SIMP-Related Parameters
#
# These parameters are effective in a larger SIMP installation
#
# @param trusted_nets
#   Networks and/or hosts that are allowed to access the RADIUS server
#
# @param protocol
#   What protocols will be used to make sure the firewall is opened correctly
#
# Custom Content Parameters
#
# These parameters add custom content to various parts of the configuration.
#
# @param clients_conf_content
#   Content for the `clients.conf` file if not creating clients individually
#
# @param proxy_conf_content
#   If `$proxy_request` is `true`, use this content for the `proxy.conf` file
#
# @param trigger_conf_content
#   This content for the `trigger.conf` file
#
# @param users_conf_content
#   The content for the `authorize` file
#
class freeradius::v3::conf (
  # Freeradius Parameters
  Integer[2,10]           $cleanup_delay          = 5,
  Boolean                 $correct_escapes        = true,
  Boolean                 $default_acct_listener  = true,
  Boolean                 $hostname_lookups       = false,
  Stdlib::AbsolutePath    $localstatedir          = '/var',
  Integer[2,120]          $max_request_time       = 30,
  Integer[256]            $max_requests           = 1024,
  Array[Simplib::Port]    $radius_ports           = [1812, 1813],

  # SIMP-Related Parameters
  Simplib::Netlist        $trusted_nets           = simplib::lookup('simp_options::trusted_nets', { 'default_value' => ['127.0.0.1', '::1']}),
  Enum['udp','tcp','ALL'] $protocol               = 'ALL',

  # Configuration Override Parameters
  Optional[String]        $clients_conf_content   = undef,
  Optional[String]        $proxy_conf_content     = undef,
  Optional[String]        $trigger_conf_content   = undef,
  Optional[String]        $users_conf_content     = undef,
) {

  assert_private()

  include 'freeradius::v3::conf::log'
  include 'freeradius::v3::conf::security'
  include 'freeradius::v3::conf::thread_pool'
  include 'freeradius::v3::conf::instantiate'

  Class[freeradius::config]
  -> Class[freeradius::v3::conf]
  -> [Class[freeradius::v3::conf::thread_pool],
      Class[freeradius::v3::conf::log],
      Class[freeradius::v3::conf::instantiate],
      Class[freeradius::v3::conf::security]]

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
  if $trigger_conf_content {
    file { "${freeradius::confdir}/trigger.conf":
      ensure => 'file',
      content=> $trigger_conf_content,
      *      => $file_settings,
    }
  }

  if $proxy_conf_content{
    file { "${freeradius::confdir}/proxy.conf":
      ensure  => 'file',
      content => $proxy_conf_content,
      *       => $file_settings,
    }
  }

  #
  ##########################

  #########################
  # Create clients.conf file
  #
  if $clients_conf_content {
    # If you have a specific client file to copy
    file { "${freeradius::confdir}/clients.conf":
      ensure  => file,
      content => $clients_conf_content,
      *       => $file_settings,
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
  if $users_conf_content {
    file { "${freeradius::confdir}/mods-config/files/authorize":
      ensure  => file,
      content => $users_conf_content,
      *       => $file_settings,
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
