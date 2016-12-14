# == Class: freeradius::conf::instantiate
#
# Manage the 'instantiate' section of radiusd.conf.
#
# You can only call this *once* within a node scope. If you try to call it more
# than once, it will fail your manifest compilation due to conflicting
# resources.
#
# See /etc/raddb/radiusd.conf.sample for additional information.
#
# == Parameters
#
# [*content*]
#   The literal content of the section that you would like to add. Leading
#   and trailing spaces wil be removed.
#
# [*keep_defaults*]
#   If set to true, this will ensure that the standard entries are retained
#   and that your content is added below them. Set to false if you would like
#   to specify the content of the entire section.
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
#
class freeradius::conf::instantiate (
  $content       = '',
  $keep_defaults = true
) {

  file { '/etc/raddb/conf/instantiate.inc':
    ensure  => 'file',
    owner   => 'root',
    group   => 'radiusd',
    mode    => '0640',
    content => template('freeradius/conf/instantiate.erb'),
    notify  => Service['radiusd']
  }

  #validate_bool($keep_defaults)
}
