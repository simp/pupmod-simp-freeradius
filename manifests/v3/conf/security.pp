# == Class: freeradius::conf::security
#
# Add a 'security' section to freeradius.
#
# @see For detailed information on the parameters, extract the original
#      /etc/raddb/radiusd.conf from the freeradius rpm using
#      rpm2cpio < free radius rpm> | cpio -idmv
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
class freeradius::v3::conf::security (
  Integer                        $max_attributes    = 200,
  Integer[1,5]                   $reject_delay      = 1,
  Boolean                        $status_server     = true,
  Boolean                        $allow_core_dumps  = false,
  Boolean                        $chroot            = false,
  Optional[Stdlib::Absolutepath] $chroot_path       = undef,
  Optional[String]               $chroot_user       = undef,
  Optional[String]               $chroot_group      = undef
) {

  include 'freeradius'

  if $chroot {
    if ! $chroot_user {
      fail('Radiusd requires the chroot_user be set if you are using a chroot. See
      radiusd.conf help.')
    }
  }

  ensure_resource ('file',  "${freeradius::confdir}/conf.d",
    {
      ensure => 'directory',
      owner  => 'root',
      group  => $freeradius::group,
      mode   => '0640',
      purge  => true,
      before => Service['radiusd'],
    })

  file { "${freeradius::confdir}/conf.d/security.inc":
    ensure  => 'file',
    owner   => 'root',
    group   => $freeradius::group,
    mode    => '0640',
    content => template('freeradius/3/conf.d/security.erb'),
    notify  => Service['radiusd']
  }

}
