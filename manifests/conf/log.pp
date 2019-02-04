# == Class: freeradius::conf::log
#
# Add a 'log' section to freeradius.
#
# See /etc/raddb/radiusd.conf.sample for additional information.
#
# == Parameters
#
# [*destination*]
# [*log_file*]
# [*syslog_facility*]
# [*stripped_names*]
# [*auth*]
# [*auth_badpass*]
# [*auth_goodpass*]
# [*msg_goodpass*]
# [*msg_badpass*]
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
#
class freeradius::conf::log (
  Freeradius::Logdest        $destination     = 'syslog',
  Stdlib::AbsolutePath       $log_file        = "${::freeradius::logdir}/radius.log",
  Simplib::Syslog::Facility  $syslog_facility = 'local6',
  Enum['yes','no']           $stripped_names  = 'no',
  Enum['yes','no']           $auth            = 'yes',
  Enum['yes','no']           $auth_badpass    = 'no',
  Enum['yes','no']           $auth_goodpass   = 'no',
  Optional[String]           $msg_goodpass    = undef,
  Optional[String]           $msg_badpass     = undef,
  Optional[String]           $msg_denied      = undef
) {

  include 'freeradius'
  Class['freeradius::config'] -> Class['freeradius::conf::log']

  ensure_resource ('file',  "${freeradius::confdir}/conf.d",
    {
      ensure => 'directory',
      owner  => 'root',
      group  => 'radiusd',
      mode   => '0640',
      purge  => true,
      before => Service['radiusd'],
    })

  file { "${freeradius::confdir}/conf.d/log.inc":
    ensure  => 'file',
    owner   => 'root',
    group   => 'radiusd',
    mode    => '0640',
    require => File["${freeradius::confdir}/conf.d"],
    content => template('freeradius/conf.d/log.erb'),
    notify  => Service['radiusd']
  }
}
