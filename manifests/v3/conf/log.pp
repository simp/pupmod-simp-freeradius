# @summary Add a 'log' section to freeradius
#
# @see For detailed information on the parameters, extract the original
#      /etc/raddb/radiusd.conf from the freeradius rpm using
#      rpm2cpio < free radius rpm> | cpio -idmv
#
# @param destination
# @param log_file
# @param syslog_facility
# @param stripped_names
# @param auth
# @param auth_badpass
# @param auth_goodpass
# @param msg_goodpass
# @param msg_badpass
# @param msg_denied
#
# @author https://github.com/simp/pupmod-simp-freeradius/graphs/contributors
#
class freeradius::v3::conf::log (
  Freeradius::Logdest        $destination     = 'syslog',
  Stdlib::AbsolutePath       $log_file        = "${::freeradius::logdir}/radius.log",
  Simplib::Syslog::Facility  $syslog_facility = 'local6',
  Boolean                    $stripped_names  = false,
  Boolean                    $auth            = true,
  Boolean                    $auth_badpass    = false,
  Boolean                    $auth_goodpass   = false,
  Optional[String]           $msg_goodpass    = undef,
  Optional[String]           $msg_badpass     = undef,
  Optional[String]           $msg_denied      = undef
) {

  include 'freeradius'

  ensure_resource ('file',  "${freeradius::confdir}/conf.d",
    {
      ensure  => 'directory',
      owner   => 'root',
      group   => $freeradius::group,
      mode    => '0640',
      recurse => true,
      purge   => true,
      before  => Service['radiusd'],
    })

  file { "${freeradius::confdir}/conf.d/log.inc":
    ensure  => 'file',
    owner   => 'root',
    group   => $freeradius::group,
    mode    => '0640',
    require => File["${freeradius::confdir}/conf.d"],
    content => template('freeradius/3/conf.d/log.erb'),
    notify  => Service['radiusd']
  }
}
