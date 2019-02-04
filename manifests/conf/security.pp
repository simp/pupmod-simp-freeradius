# == Class: freeradius::conf::security
#
# Add a 'security' section to freeradius.
#
# @see /etc/raddb/radiusd.conf.sample for additional information.
#
# == Parameters
#
# @param max_attributes
# @param reject_delay
# @param status_server
# @param allow_core_dumps
# @param chroot
#   whether or not to run radiusd in a chroot
# @param chroot_path
#    directory where the server does "chroot"
# @param  chroot_user
#    User to run daemon as,must be defined if using a chroot
# @param chroot_group
#    Group to run daemon as.
#
class freeradius::conf::security (
  Integer                        $max_attributes    = 200,
  Integer[1,5]                   $reject_delay      = 1,
  Enum['yes','no']               $status_server     = 'no',
  Enum['yes','no']               $allow_core_dumps  = 'no',
  Boolean                        $chroot            = false,
  Optional[Stdlib::Absolutepath] $chroot_path       = undef,
  Optional[String]               $chroot_user       = undef,
  Optional[String]               $chroot_group      = undef
) {

  include 'freeradius'

  ensure_resource ('file',  "${freeradius::confdir}/conf.d",
    {
      ensure => 'directory',
      owner  => 'root',
      group  => 'radiusd',
      mode   => '0640',
      purge  => true,
      before => Service['radiusd'],
    })

  file { "${freeradius::confdir}/conf.d/security.inc":
    ensure  => 'file',
    owner   => 'root',
    group   => 'radiusd',
    mode    => '0640',
    content => template('freeradius/conf.d/security.erb'),
    notify  => Service['radiusd']
  }

}
