# Creates the 'instantiate' section of radiusd.conf
# in file under conf.d.  This section is included by the directive
# $INCLUDE conf.d/
# in the radiusd.conf file.
#
# See /etc/raddb/radiusd.conf for additional information.
#
# == Parameters
#
# @param content
#   The literal content of the section that you would like to add. Leading
#   and trailing spaces will be removed.
#
# @param keep_defaults
#   If set to true, this will ensure that the standard entries are retained
#   and that your content is added below them. Set to false if you would like
#   to specify the content of the entire section.
#
# @param group
#   The group radiusd is run under
#
# @param confdir
#   The configuration directory for radiusd
#
class freeradius::v3::radiusd_conf::instantiate (
  Optional[String]  $content       = undef,
) {

  include 'freeradius'

  ensure_resource ('file',  "${freeradius::confdir}/conf.d",
    {
      ensure => 'directory',
      owner  => 'root',
      group  => $freeradius::group,
      mode   => '0640',
      purge  => true,
      before => Service['radiusd'],
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
