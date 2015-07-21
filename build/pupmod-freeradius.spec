Summary: FreeRADIUS Puppet Module.
Name: pupmod-freeradius
Version: 4.2.0
Release: 5
License: Apache License, Version 2.0
Group: Applications/System
Source: %{name}-%{version}-%{release}.tar.gz
Buildroot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot
Requires: pupmod-iptables >= 4.1.0-3
Requires: pupmod-pki >= 4.1.0-0
Requires: pupmod-openldap >= 4.1.0-3
Requires: puppet >= 3.3.0
Requires: simp-rsync >= 4.0.1-14
Buildarch: noarch
Requires: simp-bootstrap >= 4.2.0
Obsoletes: pupmod-freeradius-test

Prefix: /etc/puppet/environments/simp/modules

%description
This Puppet module provides the capability to configure FreeRADIUS servers.

%prep
%setup -q

%build

%install
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}

mkdir -p %{buildroot}/%{prefix}/freeradius

dirs='files lib manifests templates 2 3'
for dir in $dirs; do
  test -d $dir && cp -r $dir %{buildroot}/%{prefix}/freeradius
done

mkdir -p %{buildroot}/usr/share/simp/tests/modules/freeradius

%clean
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}

mkdir -p %{buildroot}/%{prefix}/freeradius

%files
%defattr(0640,root,puppet,0750)
%{prefix}/freeradius

%post
#!/bin/sh

if [ -d %{prefix}/freeradius/plugins ]; then
  /bin/mv %{prefix}/freeradius/plugins %{prefix}/freeradius/plugins.bak
fi

%postun
# Post uninstall stuff

%changelog
* Tue Jul 21 2015 Nick Miller <nick.miller@onyxpoint.com> - 4.2.0-5
- Renamed the namespaces for v2/v3.

* Mon Jun 29 2015 Nick Miller <nick.miller@onyxpoint.com> - 4.2.0-4
- Moved validation from the templates and put them in their own
  functions

* Thu Feb 19 2015 Trevor Vaughan <tvaughan@onyxpoint.com> - 4.2.0-3
- Migrated to the new 'simp' environment.

* Fri Jan 16 2015 Trevor Vaughan <tvaughan@onyxpoint.com> - 4.2.0-2
- Changed puppet-server requirement to puppet

* Fri Dec 19 2014 Kendall Moore <kmoore@keywcorp.com> - 4.2.0-1
- Added default site and updated LDAP module.

* Fri Sep 19 2014 Kendall Moore <kmoore@keywcorp.com> - 4.2.0-0
- Added a fact 'radius_version' to fetch the installed version of
  freeradius from the system.
- Updated for RHEL 7/FreeRADIUS 3.X
- Moved FreeRADIUS 2.X/3.X into their own namespaces due to
  significant differences.

* Sun Jun 22 2014 Kendall Moore <kmoore@keywcorp.com> - 4.1.0-5
- Removed MD5 file checksums for FIPS compliance.

* Fri May 16 2014 Kendall Moore <kmoore@keywcorp.com> - 4.1.0-4
- Deleted stock classes and related spec tests so they can be ported to the simp module.

* Mon Apr 21 2014 Trevor Vaughan <tvaughan@onyxpoint.com> - 4.1.0-3
- Convert the ldap module over to using the new hiera variables.

* Fri Apr 04 2014 Trevor Vaughan <tvaughan@onyxpoint.com> - 4.1.0-2
- Removed all references to $pupbuildloc since it is no longer used.

* Mon Feb 24 2014 Kendall Moore <kmoore@keywcorp.com> - 4.1.0-1
- Fixed bug in conf/listen logic.

* Wed Feb 12 2014 Trevor Vaughan <tvaughan@onyxpoint.com> - 4.1.0-1
- Fixed booleans in ERB templates

* Fri Jan 10 2014 Kendall Moore <kmoore@keywcorp.com> - 4.1.0-0
- Updated for puppet 3 and hiera compatibility.
- Removed all singleton defines.
- Changed all boolean strings to native booleans.
- Updated all code documentation.

* Thu Oct 03 2013 Kendall Moore <kmoore@keywcorp.com> - 4.0-6
- Updated all erb templates to properly scope variables.

* Wed Oct 02 2013 Trevor Vaughan <tvaughan@onyxpoint.com> - 4.0.0-7
- Use 'versioncmp' for all version comparisons.

* Fri May 17 2013 Adam Yohrling adam.yohrling@onyxpoint.com 4.0-6
- Updated the LDAP configuration to support specifying the server port as well
  as using SSL instead of START_TLS.

* Mon Feb 25 2013 Maintenance
4.0-5
- Added a call to $::rsync_timeout to the rsync call since it is now required.

* Fri Nov 30 2012 Maintenance
4.0.0-4
- Created a Cucumber test to ensure that FreeRADIUS installs correctly when
  including freeradius in the puppet server manifest.

* Thu Jun 07 2012 Maintenance
4.0.0-3
- Ensure that Arrays in templates are flattened.
- Call facts as instance variables.
- Moved mit-tests to /usr/share/simp...
- Created separate definition for adding clients.
- Removed trailing whitespace in the t_allowed_nastype enumerator.
- Updated the groupname_attribute and groupmembership_filter values and
  templating.
- Updated pp files to better meet Puppet's recommended style guide.

* Fri Mar 02 2012 Maintenance
4.0.0-2
- Improved test stubs.

* Mon Dec 26 2011 Maintenance
4.0.0-1
- Updated the spec file to not require a separate file list.
- Scoped all of the top level variables.

* Mon Nov 07 2011 Maintenance
4.0.0-0
- Updated to handle RHEL6 properly.

* Mon Oct 10 2011 Maintenance
2.0.0-2
- Updated to put quotes around everything that need it in a comparison
  statement so that puppet > 2.5 doesn't explode with an undef error.
- Modified all multi-line exec statements to act as defined on a single line to
  address bugs in puppet 2.7.5

* Sat Mar 19 2011 Maintenance - 2.0.0-1
- Added comments to freeradius::modules::ldap to note that users will need to
  manage their own service restart if they user alternate certificates.
- Ensure that the freeradius daemon restarts when cacerts is updated.
- Updated to use rsync native type

* Tue Jan 11 2011 Maintenance
2.0.0-0
- Refactored for SIMP-2.0.0-alpha release

* Tue Oct 26 2010 Maintenance - 1-1
- Converting all spec files to check for directories prior to copy.

* Fri Jul 02 2010 Maintenance
1.0-0
- Initial offering, probably less than ideal.
