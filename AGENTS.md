# AGENTS.md

This file provides guidance to AI agents when working with code in this repository.

## What this module does

`simp-freeradius` is a SIMP Puppet module that installs and configures a
**FreeRADIUS 3.x authentication server** on Enterprise Linux. The public `freeradius`
class installs the packages, creates the `radiusd` service account, lays out
`/etc/raddb`, manages the `radiusd` service, and (on FreeRADIUS 3.x) generates the
`radiusd.conf` and its `conf.d` include sections from templates. It also exposes a
family of `freeradius::v3::*` defined types and classes for declaring clients,
listeners, sites, modules, and users, plus an opinionated LDAP module/site pair
driven by SIMP's `simp_options::ldap::*` seam.

The module is **FIPS-incompatible by design**: RADIUS requires MD5, so when FIPS is
active the module refuses to configure anything and only emits a warning
(`manifests/init.pp`). Two configuration paths exist: the default
manifest-driven path (FreeRADIUS 3.x only, driven by the `radius_version` fact) and
an `rsync`-based path for copying a pre-built config tree (needed for pre-3.x
installs, `manifests/config.pp`).

### Business logic

Public API surface: the entry class `freeradius`, plus the `freeradius::v3::*`
defined types (`client`, `listen`, `listener`, `module`, `site`,
`conf::user`) and configurable classes (`v3::modules::ldap`, `v3::sites::ldap`) that
consumers declare directly. The `install`/`config`/`service`/`config::rsync` classes
and the `v3::conf*` internals are `assert_private()`'d.

- **`freeradius` (`manifests/init.pp`)** — Public entry class; `include`d by
  consumers. Key parameters (`init.pp`):
  - `$pki` (`Variant[Boolean,Enum['simp']]`) — from `simp_options::pki`
    (`init.pp`); controls whether `pki::copy` manages app certs.
  - `$firewall` (`Boolean`) — from `simp_options::firewall` (`init.pp`); gates
    the iptables port opening in `v3::conf`.
  - `$fips` (`Boolean`) — from `simp_options::fips` (`init.pp`).
  - `$freeradius_name` (`'freeradius'`), `$user`/`$group` (`'radiusd'`),
    `$uid`/`$gid` (`95`), `$confdir` (`${sysconfdir}/raddb`), `$logdir`
    (`/var/log/freeradius`), `$manage_sites_enabled` (`false`),
    `$package_ensure` (from `simp_options::package_ensure`, `init.pp`).
  - Control flow (`init.pp`): **if `$fips` OR the `fips_enabled` fact is
    true, do nothing but `warning()`** (RADIUS needs MD5, unsupported in FIPS).
    Otherwise `include` `install` → `config` ~> `service` in an ordered chain
    (`init.pp`).

- **`freeradius::install` (`manifests/install.pp`, `assert_private`)** —
  creates the `radiusd` group/user and installs `$freeradius_name`, `-ldap`, and
  `-utils` packages at `$package_ensure` (requires the user).

- **`freeradius::config` (`manifests/config.pp`, `assert_private`)** —
  optionally calls `pki::copy` when `$freeradius::pki` (`config.pp`); creates
  `$confdir` and the `mods-config`/`mods-available`/`mods-enabled`/`sites-available`/
  `sites-enabled` dirs (`sites-enabled` is `purge`d only when `$manage_sites_enabled`,
  `config.pp`); optional testcert bootstrap (`config.pp`). **Version
  dispatch (`config.pp`):** if `$use_rsync` include `config::rsync`; else if
  the `radius_version` fact is < 3 emit a warning (module only supports 3.x), if it
  is unknown warn, otherwise `include 'freeradius::v3::conf'`.

- **`freeradius::service` (`manifests/service.pp`)** — `service { 'radiusd' }`
  running + enabled. (Note: not `assert_private`'d, but no docstring params.)

- **`freeradius::config::rsync` (`manifests/config/rsync.pp`, `assert_private`)** — `include 'rsync'` and pull the config tree via the `rsync` define
  (server from `simp_options::rsync::server`, timeout from
  `simp_options::rsync::timeout`; password via `simplib::passgen`, `rsync.pp`).

- **`freeradius::v3::conf` (`manifests/v3/conf.pp`, `assert_private`)** — the core 3.x config class. `include`s the four `conf::*` section classes
  (`conf.pp`), renders `radiusd.conf` from `epp('freeradius/3/radiusd.conf.epp')`
  (`conf.pp`), manages log-file perms and `conf.d`/`policy.d`/`clients.d`, honors
  optional `*_conf_content` overrides, renders `clients.conf` from
  `epp('freeradius/3/clients.conf.epp')` when no explicit clients content
  (`conf.pp`), conditionally includes `conf::users` (`conf.pp`), and opens
  the radius ports via `iptables::listen::{udp,tcp_stateful}` when `$freeradius::firewall`
  (`conf.pp`). `$trusted_nets` defaults from `simp_options::trusted_nets`
  (`conf.pp`).

- **`freeradius::v3::conf::{log,security,thread_pool,instantiate}`** — private-in-
  practice section classes, each `include 'freeradius'` and render one `conf.d/*.inc`
  section from an ERB template (`log.pp`, `security.pp`, `thread_pool.pp`,
  `instantiate.pp`). `security.pp` `fail()`s if `$chroot` is set without
  `$chroot_user`. None call `assert_private()` (they are ordered under `v3::conf`).

- **`freeradius::v3::conf::users` (`manifests/v3/conf/users.pp`,
  `assert_private`)** — sets up the `concat` container + header for the
  `mods-config/files/authorize` users file.

- **`freeradius::v3::conf::user` (`define`, `manifests/v3/conf/user.pp`)** — adds
  a `concat::fragment` to the authorize file from `template('freeradius/user.erb')`
  (`user.pp`). `$confdir` from `simplib::lookup('freeradius::confdir', ...)`.

- **`freeradius::v3::client` (`define`, `manifests/v3/client.pp`)** — writes
  `clients.d/${name}.conf` from `template('freeradius/3/clients.d/client.erb')`
  (`client.pp`); `include 'freeradius'` (`client.pp`); secret defaults via
  `simplib::passgen("freeradius_${name}")` (`client.pp`).

- **`freeradius::v3::listen` / `freeradius::v3::listener` (`define`s,
  `listen.pp` / `listener.pp`)** — `listen` adds a `listen{}` concat fragment
  (`template('freeradius/3/conf.d/listen.erb')`, `listen.pp`) to a target file;
  `listener` creates a standalone listener file in `conf.d` and delegates a `listen`
  fragment. `$confdir`/`$group` from `freeradius::*` lookups (`listener.pp`).

- **`freeradius::v3::module` / `freeradius::v3::site` (`define`s, `module.pp` /
  `site.pp`)** — copy a module/site definition into `mods-available`/
  `sites-available` and optionally symlink into the `-enabled` dir. Both `fail()` if
  both `content` and `source` are supplied (`module.pp`, `site.pp`).
  `$confdir`/`$group` from `freeradius::*` lookups (`module.pp`, `site.pp`).

- **`freeradius::v3::modules::ldap` (`class`, `manifests/v3/modules/ldap.pp`,
  `inherits freeradius`)** — renders the LDAP module config to
  `mods-enabled/ldap` from `template('freeradius/3/modules/ldap.erb')` (`ldap.pp`)
  unless `$content` is set. Its first four params are `simp_options::ldap::*` lookups
  (see seam table).

- **`freeradius::v3::sites::ldap` (`class`, `manifests/v3/sites/ldap.pp`,
  `inherits freeradius`)** — builds a `concat` site file
  `sites-available/simp-ldap-default` from `epp` header/footer templates
  (`sites/ldap.pp`), optionally adds auth/acct `v3::listen` fragments
  (`sites/ldap.pp`), and symlinks into `sites-enabled` when `$enable`.

### Gotchas / non-obvious details

- **FIPS makes the module a no-op.** If `$fips` (`simp_options::fips`) or the
  `fips_enabled` fact is true, `freeradius` installs and configures **nothing** and
  only warns (`init.pp`). RADIUS requires MD5, which FIPS forbids.
- **Only FreeRADIUS 3.x is managed by the manifests.** The manifest path keys off
  the custom `radius_version` fact (`lib/facter/radius_version.rb`): < 3 → warning
  only, `unknown` → warning only, ≥ 3 → `v3::conf` (`config.pp`). For older
  installs you must set `$use_rsync => true` and ship a pre-built config tree; rsync
  never removes files, so rsync + manifests can be combined (`config.pp` docstring).
- **`v3::modules::ldap` has three *required* lookups with no default:**
  `simp_options::ldap::base_dn`, `simp_options::ldap::bind_pw`,
  `simp_options::ldap::uri` (`ldap.pp`). Compilation fails if these are not
  in Hiera. This class and `v3::sites::ldap` both `inherits freeradius`.
- **There is no `data/` directory** even though `hiera.yaml` (v5) points `datadir`
  at `data`. All parameter defaults live in the manifests (via `simplib::lookup`
  defaults or literals), not in module data — `hiera.yaml` resolves to nothing.
- **`sites-enabled` is only purged when `$manage_sites_enabled` is true**
  (`config.pp`); rsync'd files are not "managed" by Puppet and would be purged
  if you enable this, so the docstring warns against mixing them.
- **`freeradius::service` is not `assert_private()`'d**, unlike the other internal
  classes — declaring it directly is technically possible but not intended; it is
  ordered after `config` by the entry class (`init.pp`).
- **`simp/simplib` is a declared dependency and provides the `simplib::lookup` /
  `simplib::passgen` functions and the `Simplib::*` data types**, but
  `simp/simp_options` itself is **NOT** a declared dependency — the `simp_options::*`
  keys are consumed purely through `simplib::lookup` with defaults, and
  `simp_options` appears only as a `.fixtures.yml` fixture.
- **`simp/ds389` / `simp_ds389` / `firewalld` / `systemd` / `logrotate` / `concat`
  are fixture-only** (used by acceptance/compilation) and are **not** declared
  runtime dependencies in `metadata.json`, even though `concat` resources are used
  (`v3::conf::users`, `v3::sites::ldap`) — `concat` reaches the runtime graph
  transitively via the declared deps / environment, not via a direct `metadata.json`
  entry.

## The `simp_options` / `simplib::lookup` seam

The module routes SIMP-wide feature toggles through
`simplib::lookup('simp_options::*', { 'default_value' => ... })`. All
`simp_options::` calls:

| File:line | Key | `default_value` |
|-----------|-----|-----------------|
| `manifests/init.pp` | `simp_options::pki` | `false` |
| `manifests/init.pp` | `simp_options::firewall` | `false` |
| `manifests/init.pp` | `simp_options::fips` | `false` |
| `manifests/init.pp` | `simp_options::pki::source` | `'/etc/pki/simp/x509'` |
| `manifests/init.pp` | `simp_options::package_ensure` | `'installed'` |
| `manifests/config/rsync.pp` | `simp_options::rsync::server` | `'127.0.0.1'` |
| `manifests/config/rsync.pp` | `simp_options::rsync::timeout` | `2` |
| `manifests/v3/conf.pp` | `simp_options::trusted_nets` | `['127.0.0.1', '::1']` |
| `manifests/v3/modules/ldap.pp` | `simp_options::ldap::base_dn` | **none (required)** |
| `manifests/v3/modules/ldap.pp` | `simp_options::ldap::bind_pw` | **none (required)** |
| `manifests/v3/modules/ldap.pp` | `simp_options::ldap::bind_dn` | `"cn=hostAuth,ou=Hosts,%{lookup('simp_options::ldap::base_dn')}"` (`value_type => String`) |
| `manifests/v3/modules/ldap.pp` | `simp_options::ldap::uri` | **none (required)** |

There is a **second, module-local `simplib::lookup` seam** for the defined types'
`$confdir`/`$group` — these use plain (non-`simp_options`) keys so that a define
declared outside the `freeradius` class still resolves sane paths:

| File:line | Key | `default_value` |
|-----------|-----|-----------------|
| `manifests/v3/module.pp` | `freeradius::confdir` | `'/etc/raddb'` |
| `manifests/v3/module.pp` | `freeradius::group` | `'radiusd'` |
| `manifests/v3/listener.pp` | `freeradius::confdir` | `'/etc/raddb'` |
| `manifests/v3/listener.pp` | `freeradius::group` | `'radiusd'` |
| `manifests/v3/site.pp` | `freeradius::confdir` | `'/etc/raddb'` |
| `manifests/v3/site.pp` | `freeradius::group` | `'radiusd'` |
| `manifests/v3/conf/user.pp` | `freeradius::confdir` | `'/etc/raddb'` |

Keep routing SIMP feature toggles through `simplib::lookup('simp_options::*', {
'default_value' => ... })` with an explicit default rather than assuming
`simp_options` is included.

## Dependencies

Module dependencies (from `metadata.json`):

- `simp/iptables` `>= 6.5.3 < 8.0.0` — provides `iptables::listen::udp` /
  `iptables::listen::tcp_stateful` used when `$firewall` (`v3/conf.pp`).
- `simp/pki` `>= 6.2.0 < 7.0.0` — provides `pki::copy` for app cert management
  (`config.pp`).
- `simp/rsync` `>= 6.1.1 < 7.0.0` — provides the `rsync` define and `rsync` class
  (`config/rsync.pp`).
- `simp/simplib` `>= 4.9.0 < 5.0.0` — provides `simplib::lookup`,
  `simplib::passgen`, and the `Simplib::*` data types (`Simplib::Host`,
  `Simplib::Netlist`, `Simplib::Port`, `Simplib::Uri`).
- `puppetlabs/stdlib` `>= 8.0.0 < 10.0.0` — provides `Stdlib::*` types,
  `versioncmp()`, etc.

No `simp.optional_dependencies` block is present in `metadata.json`.

Fixture-only dependencies (from `.fixtures.yml`, present for test compilation, not
declared runtime deps): `augeas_core`, `concat`, `ds389`, `firewalld`, `logrotate`,
`selinux_core`, `simp_firewalld`, `simp_ds389`, `simp_options`, `systemd` (the five
declared runtime deps above are also checked out as fixtures).

Runtime requirement (from `metadata.json` `requirements`): `puppet >= 7.0.0 <
9.0.0`. (SIMP is migrating Puppet → OpenVox; when `metadata.json` switches this to
`openvox`, update this line to match.)

Supported OS matrix (from `metadata.json`): CentOS 7/8/9; RedHat 7/8/9;
OracleLinux 7/8/9; Rocky 8/9; AlmaLinux 8/9.

## Repository layout

- `manifests/init.pp` — public `freeradius` entry class (FIPS gate + install/config/
  service orchestration).
- `manifests/install.pp`, `config.pp`, `service.pp`, `config/rsync.pp` — private
  install/config/service/rsync classes.
- `manifests/v3/` — FreeRADIUS 3.x support: `conf.pp` (core config class) and
  `conf/{instantiate,log,security,thread_pool,user,users}.pp` section
  classes/defines; the `client`, `listen`, `listener`, `module`, `site` defined
  types; `modules/ldap.pp` and `sites/ldap.pp` LDAP config classes.
- `types/` — five Puppet data types: `Freeradius::Deref`, `Freeradius::Listen`,
  `Freeradius::Logdest`, `Freeradius::Nas`, `Freeradius::Scope` (all `Enum`s).
- `lib/facter/radius_version.rb` — custom fact returning the installed FreeRADIUS
  version (or `'unknown'`); drives the version dispatch in `config.pp`.
- `templates/` — 12 templates: `user.erb`; ERB sections under `3/conf.d/` and
  `3/clients.d/client.erb` and `3/modules/ldap.erb`; EPP templates
  `3/radiusd.conf.epp`, `3/clients.conf.epp`, `3/sites/ldap_{header,footer}.epp`.
- **No `data/` directory** — `hiera.yaml` (v5) declares `datadir: data`, but the dir
  does not exist; all defaults live in manifests.
- `metadata.json` — deps, OS matrix, Puppet requirement.
- `spec/classes/`, `spec/defines/`, `spec/unit/` — rspec-puppet unit tests
  (`init_spec.rb`, `v3/**`, and `unit/facter/radius_version_spec.rb`).
- `spec/acceptance/suites/default/` — beaker acceptance suite (LDAP + 389DS radius
  tests: `00_setup_389ds_spec.rb`, `00_setup_ldap_spec.rb`,
  `10_radius_plainldap_spec.rb`, `11_radius_389ldap_spec.rb`) with `files/`
  hieradata/ldif fixtures; nodesets `spec/acceptance/nodesets/{default,oel}.yml`.
- `REFERENCE.md` — generated Puppet Strings reference; `README.md`, `CHANGELOG`.
- **Acceptance does NOT run in CI.** `.github/workflows/pr_tests.yml` runs only
  `puppet-syntax`, `puppet-style`, `ruby-style`, `file-checks`, `releng-checks`, and
  `spec-tests` (unit only, Puppet 7.x + 8.x). No workflow invokes
  `rake beaker:suites`, so the acceptance suite and nodesets are run manually only.

## Common commands

```sh
# Install dependencies
bundle install

# Run all unit tests
bundle exec rake spec

# Run the single class spec
bundle exec rspec spec/classes/init_spec.rb

# Puppet lint
bundle exec rake lint

# Ruby lint
bundle exec rake rubocop

# Regenerate REFERENCE.md from puppet-strings docstrings
puppet strings generate --format markdown --out REFERENCE.md

# Run the default beaker acceptance suite
bundle exec rake beaker:suites[default]
```

Relevant gem pins (from `Gemfile`): `puppetlabs_spec_helper ~> 8.0.0`,
`simp-rake-helpers ~> 5.24.0`, `simp-rspec-puppet-facts ~> 4.0.0`,
`simp-beaker-helpers ~> 2.0.0`. Rubocop is pinned to `~> 1.88.0`. The tested Puppet
range is `>= 7 < 9`.

## Conventions

- Preserve the `@summary` / `@param` puppet-strings docstrings on classes and
  defines — they drive `REFERENCE.md`. Regenerate `REFERENCE.md` after changing docs
  or parameters.
- Continue routing SIMP feature toggles through
  `simplib::lookup('simp_options::*', { 'default_value' => ... })` rather than
  assuming `simp_options` is included; use plain `simplib::lookup('freeradius::*',
  ...)` for the defined types' `$confdir`/`$group` so they resolve standalone.
- Keep `assert_private()` on the internal install/config/rsync and `v3::conf`/
  `v3::conf::users` classes; the `v3::*` defined types and the two LDAP classes are
  the intended public API.
- This module targets **FreeRADIUS 3.x** in the manifest path; gate any new
  version-specific logic on the `radius_version` fact as `config.pp` does.
- `Gemfile`, `spec/spec_helper.rb`, and `.github/workflows/pr_tests.yml` carry a
  **puppetsync** notice — they are baseline-managed and the next sync overwrites
  local edits. Push changes to those files upstream to the baseline, not here.
- Match the existing 2-space Puppet indentation and aligned-arrow parameter style
  used in the manifests.
