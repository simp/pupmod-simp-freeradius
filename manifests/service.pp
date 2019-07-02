# @summary Configure the radiusd service
#
class freeradius::service {
  service { 'radiusd':
    ensure    => 'running',
    enable    => true,
    hasstatus => true,
  }
}
