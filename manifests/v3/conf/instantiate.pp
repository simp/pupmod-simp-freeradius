# @summary Creates the 'instantiate' section of `radiusd.conf`
# in a file under `conf.d`.
#
# This section is included by the directive `$INCLUDE conf.d/` in the
# radiusd.conf file.
#
# @see For detailed information on the parameters, extract the original
#      /etc/raddb/radiusd.conf from the freeradius rpm using
#      rpm2cpio < free radius rpm> | cpio -idmv
#
# @param content
#   The literal content of the section that you would like to add. Leading
#   and trailing spaces will be removed.
#
class freeradius::v3::conf::instantiate (
  Optional[String]  $content = undef
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

  file { "${freeradius::confdir}/conf.d/instantiate.inc":
    ensure  => 'file',
    owner   => 'root',
    group   => $freeradius::group,
    mode    => '0640',
    require => File["${freeradius::confdir}/conf.d"],
    content => template('freeradius/3/conf.d/instantiate.erb'),
    notify  => Service['radiusd']
  }

}
