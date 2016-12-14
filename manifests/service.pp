# Class freeradius::service
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
# * Nick Markowski <nmarkowski@keywcorp.com>
#
class freeradius::service {
  service { 'radiusd':
    ensure    => 'running',
    enable    => true,
    hasstatus => true,
  }
}
