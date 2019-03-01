[![License](https://img.shields.io/:license-apache-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0.html)
[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/73/badge)](https://bestpractices.coreinfrastructure.org/projects/73)
[![Puppet Forge](https://img.shields.io/puppetforge/v/simp/libreswan.svg)](https://forge.puppetlabs.com/simp/freeradius)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/simp/libreswan.svg)](https://forge.puppetlabs.com/simp/freeradius)
[![Build Status](https://travis-ci.org/simp/pupmod-simp-libreswan.svg)](https://travis-ci.org/simp/pupmod-simp-freeradius)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with ipsec](#setup)
    * [What ipsec affects](#what-ipsec-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with ipsec](#beginning-with-ipsec)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)
      * [Acceptance Tests - Beaker env variables](#acceptance-tests)

## Overview

This module installs freeradius. The v3 manifests can be used to configure version 3 of freeradius.
If an older version of freeradius is being used, rsync can be used to copy over configuration files
created outside of Puppet.  Rsync can also be used to copy over version 3 files.

This modules includes a radiusd site and module that can be used to configure freeradius to
work with an openldap server.

## This is a SIMP module

This module is a component of the [System Integrity Management Platform](https://simp-project.com),
a compliance-management framework built on Puppet.

If you find any issues, they can be submitted to our [JIRA](https://simp-project.atlassian.net/).

Please read our [Contribution Guide](http://simp.readthedocs.io/en/stable/contributors_guide/index.html).

This module is optimally designed for use within a larger SIMP ecosystem, but it can be used independently:

* When included within the SIMP ecosystem, security compliance settings will be managed from the Puppet server.

## Module Description

This module installs and configures freeradius. Its main purpose is to integrate freeradius
with an existing LDAP server. It includes manifests that configure the ldap module and create
a virtual server (site) that configures freeradius to listen on all available interfaces and
authenticate via LDAP.

## Beginning with freeradius

Before installing pupmod-simp-freeradius make sure to read the [freeradius documentation](http://freeradius.org/documentation)

## Setup

* Ensure the freeradius, freeradius-ldap and freeradius-utils packages are available.


### Defaults

* Configuration directory: /etc/raddb
* Log Directory: /var/log/freeradius
* Ldap Bind user: bind_dn
* Rsync: false

### Set up Radius Server to use LDAP

This basic setup will configure Radius to listen on all interfaces and authenticate
using LDAP.

#### Install freeradius and the LDAP module and site configuration.

Add the following to hiera for the Radius server:

```yaml
---

classes:
  - 'freeradius'
  - 'freeradius::v3::sites::ldap'
  - 'freeradius::v3::modules::ldap'
```

The default setting for radiusd.conf can be found in freeradius::v3::conf
and can be changed using hiera.

#### Add radius clients:

Client configurations will need to be created to allow clients to talk to the server.
See the default client.conf file installed by freeradius for information on how to
configure clients.

This module lets clients be created individually with freeradius::v3::conf::client.
Alternatively, a complete clients.conf file can be copied in by specifying the file
source in hiera with the variable freeradius::v3::conf::clients_conf_source.

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
# freeradius::v3::conf::clients_conf_source: <source for file>
# For example if using a puppet source:
freeradius::v3::conf::clients_conf_source: puppet:///modules/myconfigmod/freeradius/client.conf
```

### Other configuration

#### Add local radius users and trigger.

Note: You do not need to add any local users or set up SNMP triggers to get LDAP to work.

Users can be created by setting a source file containing the required users
as follows:

``` yaml
freeradius::v3::conf::users_conf_source: <file location>
```

If no source file is specified, a blank users file is created and users can be
added using freeradius::v3::users. Examples are given in the module.

The trigger.conf file can be added by specifying the following in hiera:

``` yaml
freeradius::v3::conf::trigger_conf_source: <file source>
```

#### Add sites and modules

Other sites and modules you write can be added individually using freeradius::v3::site
or freeradius::v3::module.  In both cases, you specify the source file to be copied.
For example, to specify a custom site:

``` ruby
freeradius::v3::site { 'mysite':
  source => puppet::///modules/mymodule/freeradius/mysite,
  enable => true
}
```
Existing sites that are in the sites-available directory can be added using
``` ruby
freeradius::v3::site { 'inner-triggers':
  enable =>
}
```

This will create the link and ensure if manage_sites_enabled is set to true it
will not be removed.

See the sites-available and mods-available directories for examples and information
on how to build the content of these files.

### Configure the Radius Server with Rsync

Free radius will use the /var/simp/environments/<os>/Global/freeradius share
on the rsync server by default.
Files in this directory will be rsynced to /etc/raddb. Make sure the permissions are correct,
including the SELinux context.

In hiera:

``` yaml
freeradius::use_rsync: true

classes:
  - 'freeradius'
```

Rsync will copy over all the files and overwrite anything that already exists.
It will not purge any files.

## Limitations

Currently this has only been tested with Centos 7 and freeradius v3.

## Development

Please read our [Contribution Guide](http://simp.readthedocs.io/en/stable/contributors_guide/index.html).

### Acceptance tests

This module includes [Beaker](https://github.com/puppetlabs/beaker) acceptance tests using the SIMP [Beaker Helpers](https://github.com/simp/rubygem-simp-beaker-helpers).  By default the tests use [Vagrant](https://www.vagrantup.com/) with [VirtualBox](https://www.virtualbox.org) as a back-end; Vagrant and VirtualBox must both be installed to run these tests without modification. To execute the tests run the following:

```shell
bundle install
bundle exec rake beaker:suites
```

Please refer to the [SIMP Beaker Helpers documentation](https://github.com/simp/rubygem-simp-beaker-helpers/blob/master/README.md) for more information.
