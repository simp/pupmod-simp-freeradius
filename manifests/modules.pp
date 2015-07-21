# == Class: freeradius::modules
#
# The Freeradius modules space.
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
#
class freeradius::modules {
  if $::operatingsystem in ['RedHat', 'CentOS'] {
    if $::radius_version != 'unknown' {
      if (versioncmp($::radius_version, '3') >= 0) {
        include '::freeradius::v3::modules'
      }
      else {
        include '::freeradius::v2::modules'
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
