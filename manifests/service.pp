# Class freeradius::service
#
# configure the radiusd service
#
class freeradius::service {
  service { 'radiusd':
    ensure    => 'running',
    enable    => true,
    hasstatus => true,
  }
}
