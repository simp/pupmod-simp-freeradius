# This define copies a module definition file to the modules-available directory
# and if it is enabled, links it to the mods-enabled directory.
#
# If neither content or source is defined and ft it enabled then it will
#  just create a link.
#
# @see mods-available for further documentation on modules.
#
# == Parameters
#
# @param enabled
#   If true a link will be created in mods-enabled to enable the site.
#
# @param content
#   The actual content of the module.  Only one of content or source can be
#   used.
#
# @param source
#   The source file of the module definition. Only one of content or source can be
#   used.
#
# @param confdir
#   The configuration directory
#
# @param group
#   The group radiusd will run under
#
define freeradius::v3::module (
  Optional[String]      $content = undef,
  Optional[String]      $source  = undef,
  Boolean               $enabled = false,
  Stdlib::Absolutepath  $confdir = simplib::lookup( 'freeradius::confdir', {'default_value' => '/etc/raddb'} ),
  String                $group   = simplib::lookup( 'freeradius::group', {'default_value' => 'radiusd'} )
) {

  if $content and $source {
    fail('Only one of $content and $source can be specified.')
  }

  if $content or  $source {
    file { "${confdir}/mods-available/${name}":
      ensure  => 'file',
      content => $content,
      source  => $source,
      require => Class['freeradius::config']
    }
  }

  if $enabled {
    file { "${confdir}/mods-enabled/${name}":
      ensure  => 'link',
      target  => "${confdir}/mods-available/${name}",
      require => Class['freeradius::config']
    }
  }

}
