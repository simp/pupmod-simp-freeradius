# == Define: freeradius::user
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
#  freeradius::v3::user { 'default_ppp':
#    is_default => true,
#    order => '500',
#    content => '
#     Framed-Protocol == PPP
#     Framed-Protocol = PPP,
#     Framed-Compression = Van-Jacobson-TCP-IP'
#  }
#
# Adding a disabled user
#  freeradius::v3::user { 'lameuser':
#   order => '0',
#   content => '
#    Auth-Type := Reject
#    Reply-Message = 'Your account has been disabled.''
#  }
#
# == Parameters
#
# @param name
#   The name of the user.
#   If $is_default is set to true, this will be treated as a DEFAULT user
#   entry and the name will be used for uniqueness.
#   It is recommended to use something like 'default_ppp', 'default_slip',
#   etc... for these entries.
#
# @param content
#   The actual content of the entry per users(5). The $name will be used as
#   the left hand initial value unless $is_default = true. All other
#   portions must be properly included, starting with the initial comparison
#   or assignment.
#   Leading whitespace is ignored.
#
# @param is_default
#   Whether or not the entry is for a DEFAULT user entry.
#
# @param order
#   An ordering number for including the entries in the file. This does not
#   *have* to be numeric, but you may end up with strange results if it is
#   not. The default is alphabetic.
#
# @param confdir
#  The configuration directory for  radiusd.
#
#   Generally, you will want default entries at the end of the file, but this
#   is not strictly enforced. You have been warned!
#
#
# @author https://github.com/simp/pupmod-simp-freeradius/graphs/contributors
#
define freeradius::v3::user (
  String                $content,
  Boolean               $is_default = false,
  Integer[1]            $order      = 100,
  Stdlib::Absolutepath  $confdir    = simplib::lookup( 'freeradius::confdir', {'default_value' => '/etc/raddb'} )
) {

  include 'freeradius::v3::conf::users'

  concat::fragment { "radius_user_${order}.${name}":
    target  => "${confdir}/mods-config/files/authorize",
    content => template('freeradius/users.erb'),
    order   =>  $order
  }

}
