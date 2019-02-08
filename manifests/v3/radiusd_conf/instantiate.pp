# Manage the 'instantiate' section of radiusd.conf.
# This will create a file in the conf.d directory.
# The directove $INCLUDE conf.d must be included in
# the radiusd.conf file to pick up this configuration.
#
# See /etc/raddb/radiusd.conf.sample for additional information.
#
# == Parameters
#
# @param content
#   The literal content of the section that you would like to add. Leading
#   and trailing spaces wil be removed.
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
  Optional[String]     $content       = undef,
  Boolean              $keep_defaults = true,
  Stdlib::Absolutepath $confdir       = simp_options::lookup('freeradius::config'),
  String               $group         = simp_options::lookup('freeradius::group'),
) {

  include 'freeradius'

  ensure_resource ('file',  "${confdir}/conf.d",
    {
      ensure => 'directory',
      owner  => 'root',
      group  => $group,
      mode   => '0640',
      purge  => true,
      before => Service['radiusd'],
    })

  file { "${confdir}/conf.d/instantiate.inc":
    ensure  => 'file',
    owner   => 'root',
    group   => $group,
    mode    => '0640',
    require => File["${confdir}/conf.d"],
    content => template('freeradius/3/conf.d/instantiate.erb'),
    notify  => Service['radiusd']
  }

}
