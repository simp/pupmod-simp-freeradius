# == Define: freeradius::users::add
#
# This define sets up the files that dicatates how to authorize and authenticate
# each user request.
#
# All files will be placed in /etc/raddb/users.inc/ with the prefix of either
# 'user' or 'default' as appropriate.
#
# See users(5) for additional details.
#
# Examples
#
# Adding the normal defaults for PPP
#  freeradius::users::add { 'default_ppp':
#    is_default => true,
#    order => '500',
#    content => '
#     Framed-Protocol == PPP
#     Framed-Protocol = PPP,
#     Framed-Compression = Van-Jacobson-TCP-IP'
#  }
#
# Adding a disabled user
#  freeradius::users::add { 'lameuser':
#   order => '0',
#   content => '
#    Auth-Type := Reject
#    Reply-Message = 'Your account has been disabled.''
#  }
#
# == Parameters
#
# [*name*]
#   The name of the user.
#   If $is_default is set to true, this will be treated as a DEFAULT user
#   entry and the name will be used for uniqueness.
#   It is recommended to use something like 'default_ppp', 'default_slip',
#   etc... for these entries.
#
# [*content*]
#   The actual content of the entry per users(5). The $name will be used as
#   the left hand initial value unless $is_default = true. All other
#   portions must be properly included, starting with the initial comparison
#   or assignment.
#   Leading whitespace is ignored.
#
# [*is_default*]
#   Whether or not the entry is for a DEFAULT user entry.
#
# [*order*]
#   An ordering number for including the entries in the file. This does not
#   *have* to be numeric, but you may end up with strange results if it is
#   not. The default is alphabetic.
#
#   Generally, you will want default entries at the end of the file, but this
#   is not strictly enforced. You have been warned!
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
#
define freeradius::users::add (
  $content,
  $is_default = false,
  $order = '100'
) {

  file { "/etc/raddb/users.inc/${order}.${name}":
    owner   => 'root',
    group   => 'radiusd',
    mode    => '0640',
    content => template('freeradius/users.erb'),
    notify  => Exec['build_freeradius_users']
  }

  validate_bool($is_default)
  validate_integer($order)
}
