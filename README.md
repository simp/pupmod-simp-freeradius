[![License](https://img.shields.io/:license-apache-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0.html)
[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/73/badge)](https://bestpractices.coreinfrastructure.org/projects/73)
[![Puppet Forge](https://img.shields.io/puppetforge/v/simp/freeradius.svg)](https://forge.puppetlabs.com/simp/freeradius)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/simp/freeradius.svg)](https://forge.puppetlabs.com/simp/freeradius)
[![Build Status](https://travis-ci.org/simp/pupmod-simp-freeradius.svg)](https://travis-ci.org/simp/pupmod-simp-freeradius)

#### Table of Contents

<!-- vim-markdown-toc GFM -->

* [Overview](#overview)
* [This is a SIMP module](#this-is-a-simp-module)
* [Module Description](#module-description)
* [Beginning with freeradius](#beginning-with-freeradius)
* [Setup](#setup)
  * [Defaults](#defaults)
  * [Set up Radius Server to use LDAP](#set-up-radius-server-to-use-ldap)
    * [Install freeradius and the LDAP module and site configuration.](#install-freeradius-and-the-ldap-module-and-site-configuration)
    * [Add radius clients:](#add-radius-clients)
  * [Other configuration](#other-configuration)
    * [Add sites and modules](#add-sites-and-modules)
  * [Configure the Radius Server with Rsync](#configure-the-radius-server-with-rsync)
* [Development](#development)
  * [Acceptance tests](#acceptance-tests)

<!-- vim-markdown-toc -->

## Overview

This module installs freeradius. The v3 manifests can be used to configure
version 3 of freeradius.  If an older version of freeradius is being used,
rsync can be used to copy over configuration files created outside of Puppet.
Rsync can also be used to copy over version 3 files.

This module includes a radiusd site and module that can be used to configure
freeradius to work with a LDAP server.

## This is a SIMP module

This module is a component of the [System Integrity Management Platform](https://simp-project.com),
a compliance-management framework built on Puppet.

If you find any issues, they can be submitted to our
[JIRA](https://simp-project.atlassian.net/).

Please read our [Contribution Guide](https://simp.readthedocs.io/en/stable/contributors_guide/index.html).

This module is optimally designed for use within a larger SIMP ecosystem, but
it can be used independently:

* When included within the SIMP ecosystem, security compliance settings will be
  managed from the Puppet server.

## Module Description

This module installs and configures freeradius. Its main purpose is to
integrate freeradius with an existing LDAP server. It includes manifests that
creates a virtual server (site) that configures freeradius to listen on all
available interfaces and authenticate via LDAP.

See [REFERENCE.md](REFERENCE.md) for more details.

## Beginning with freeradius

Before using pupmod-simp-freeradius make sure to read the
[freeradius documentation](http://freeradius.org/documentation)

Much of the freeradius documentation is in the default configuration files,
some of which get overwritten by this module.  It could be helpful to extract
and store these files in a separate location using the command:

```shell
rpm2cpio <free radius rpm> | cpio -idmv
```

## Setup

* Ensure the freeradius, freeradius-ldap and freeradius-utils packages are
  available to your package manager.


### Defaults

* Configuration directory: `/etc/raddb`
* Log Directory: `/var/log/freeradius`
* Ldap Bind user: `bind_dn`
* Rsync: `false`

### Set up Radius Server to use LDAP

This basic setup will configure RADIUS to listen on all interfaces and
authenticate using LDAP.

#### Install freeradius and the LDAP module and site configuration.

Include the following in your Puppet code:

```puppet
include 'freeradius'
include 'freeradius::v3::sites::ldap'
include 'freeradius::v3::modules::ldap'
```

If you are using a SIMP system, you can alternatively include the classes via
Hiera:

```yaml
---
simp::classes:
  - 'freeradius'
  - 'freeradius::v3::sites::ldap'
  - 'freeradius::v3::modules::ldap'
```

The default settings for `radiusd.conf` can be found in
  - `freeradius::v3::conf`
  - `freeradius::v3::conf::log`
  - `freeradius::v3::conf::security`
  - `freeradius::v3::conf::thread_pool`
and can be changed using Hiera. See [REFERENCE.md](REFERENCE.md) for more
details.

The listener is setup in the `freeradius::v3::sites::ldap` class.  Review that
module if there is a need to change the listener or to use a global listener
instead of one linked to a site.

#### Add radius clients:

Client configurations will need to be created to allow clients to talk to the
server.  See the default `client.conf` file installed by freeradius for
information on how to configure clients.

The `freeradius::v3::client` defined type lets clients be created individually.
Alternatively, a complete `clients.conf` file can be copied in by specifying
the file source in Hiera with the variable
`freeradius::v3::conf::clients_conf_content`.

Example clients:

``` ruby
  freeradius::v3::client { 'localhost':
    ipaddr => '127.0.0.1',
    secret => 'testing123',
    require_message_authenticator => false,
    nas_type => 'other',
    }

  freeradius::v3::client { 'mynetwork':
    ipaddr => '10.0.71.0/24',
    secret => 'testing123'
  }
```

or to copy over a file with clients defined, set the hiera variable:

``` yaml
---
# The setting is
# freeradius::v3::conf::clients_conf_content: <exact content to add to file>
freeradius::v3::conf::clients_conf_content: >
  Your entire
  configuration
  goes here
```


### Other configuration

The following configurations are not needed for connection to LDAP.  These are
a few examples of alternate application configurations.

#### Add sites and modules

Other sites and modules you write can be added individually using
`freeradius::v3::site` or `freeradius::v3::module`.  In both cases, you specify
the source file to be copied.  For example, to specify a custom site:

``` ruby
freeradius::v3::site { 'mysite':
  source => puppet::///modules/mymodule/freeradius/mysite,
  enable => true
}
```

Existing sites that are in the sites-available directory can be added using

``` ruby
freeradius::v3::site { 'inner-triggers':
  enable => true
}
```

This will create the link and, if `manage_sites_enabled` is set to `true`, it
will not be removed.

See the `sites-available` and `mods-available` directories on your system for
examples and information on how to build the content of these files.

### Configure the Radius Server with Rsync

If enabled, Freeradius will use the
`/var/simp/environments/<os>/Global/freeradius` share on the SIMP `rsync`
server. This allows for large or complex configurations that may not be
appropriate for inclusion directly into puppet `File` resources.

Files in this directory will be copied via `rsync` to `/etc/raddb`. Make sure
all permissions are correct, including the SELinux context.

In Hiera:

``` yaml
freeradius::use_rsync: true
```

Rsync will copy over all the files and overwrite anything that already exists.
It will not purge any files.

## Development

Please read our [Contribution Guide](https://simp.readthedocs.io/en/stable/contributors_guide/index.html).

### Acceptance tests

This module includes [Beaker](https://github.com/puppetlabs/beaker) acceptance
tests using the SIMP [Beaker Helpers](https://github.com/simp/rubygem-simp-beaker-helpers).
By default the tests use [Vagrant](https://www.vagrantup.com/) with
[VirtualBox](https://www.virtualbox.org) as a back-end; Vagrant and VirtualBox
must both be installed to run these tests without modification. To execute the
tests run the following:

```shell
bundle install
bundle exec rake beaker:suites
```

Please refer to the [SIMP Beaker Helpers documentation](https://github.com/simp/rubygem-simp-beaker-helpers/blob/master/README.md)
for more information.
