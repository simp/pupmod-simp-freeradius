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
  Enum['yes','no']                    $stripped_names  = 'no',
  Enum['yes','no']                    $auth            = 'yes',
  Enum['yes','no']                    $auth_badpass    = 'no',
  Enum['yes','no']                    $auth_goodpass   = 'no',
  Enum['yes','no']           $msg_goodpass    = 'no',
  Enum['yes','no']           $msg_badpass     = 'no',
  Optional[String]           $deny_message    = undef
) {

  Class['freeradius::config'] -> Class['freeradius::conf::log']

  file { '/etc/raddb/conf/log.inc':
    ensure  => 'file',
    owner   => 'root',
    group   => 'radiusd',
    mode    => '0640',
    content => template('freeradius/conf/log.erb'),
    notify  => Service['radiusd']
  }
}
