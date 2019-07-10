# @summary Copies a site definition file to the `sites-available` directory and
# if it is enabled, links it to the `sites-enabled` directory.
#
# Note: If `freeradius::manage_sites` is enabled any site not defined in puppet
# will be purged.
#
# If neither content or source is defined and it is enabled then it will just
# create a link.
#
# @see site definitions in sites-available for further documentation on sites.
#
# @param enabled
#   If true a link will be created in sites-enabled to enable the site.
#
# @param content
#   The actual content of the entry per.  Only one of content or source can be
#   used.
#
# @param source
#   The source file of the site definition. Only one of content or source can be
#   used.
#
# @param confdir
#   The configuration directory
#
# @param group
#   The group radiusd will run under
#
define freeradius::v3::site (
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
    file { "${confdir}/sites-available/${name}":
      ensure  => 'file',
      content => $content,
      source  => $source,
      require => Class['freeradius::config']
    }
  }

  if $enabled {
    file { "${confdir}/sites-enabled/${name}":
      ensure  => 'link',
      target  => "${confdir}/sites-available/${name}",
      require => Class['freeradius::config']
    }
  }

}
