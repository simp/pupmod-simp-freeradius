# == Class: freeradius::conf
#
# Configure a freeradius server.
#
# This can only be defined *once* in a namespace.
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
#
class freeradius::conf {
  if $::operatingsystem in ['RedHat', 'CentOS'] {
    if $::radius_version != 'unknown' {
      if (versioncmp($::radius_version, '3') >= 0) {
        include '::freeradius::v3::conf'
      }
      else {
        include '::freeradius::v2::conf'
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
