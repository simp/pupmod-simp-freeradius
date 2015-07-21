# == Class: freeradius::conf::policy
#
# Manage the 'policy' section of radiusd.conf.
#
# You can only call this *once* within a node scope. If you try to call it more
# than once, it will fail your manifest compilation due to conflicting
# resources.
#
# See /etc/raddb/radiusd.conf.sample for additional information.
#
# == Parameters
#
# == Authors
#
# * Kendall Moore <kmoore@keywcorp.com>
#
class freeradius::v3::conf::policy {
  include '::freeradius'

  if $::operatingsystem in ['RedHat', 'CentOS'] {
    if $::radius_version != 'unknown' {
      if (versioncmp($::radius_version, '3') >= 0) {
        file { '/etc/raddb/conf/policy.inc':
          ensure  => 'file',
          owner   => 'root',
          group   => 'radiusd',
          mode    => '0640',
          content => template('freeradius/v3/conf/policy.erb'),
          notify  => Service['radiusd']
        }
      }
    }
    else {
      warning('FreeRADIUS does not yet appear to be installed. Please install FreeRADIUS and then continue.')
    }
  }
  else {
    warning("$::operatingsystem not yet supported. Current options are RedHat and CentOS")
  }
}
