# apk

## container

``` bash
docker run --rm -it alpine:latest
apk update
```

## resources
- <https://wiki.alpinelinux.org/wiki/Package_management>
- <https://pkgs.alpinelinux.org/packages>
- <https://man.archlinux.org/man/apk.8>
- <https://man.archlinux.org/man/apk-del.8.en>
- <https://man.archlinux.org/man/apk-add.8.en>
- <https://man.archlinux.org/man/apk-upgrade.8.en>
- <https://man.archlinux.org/man/apk-info.8.en>
- <https://man.archlinux.org/man/apk-query.8.en>

## notes
- `apk` is strange, the documentation provides more options that are implemented in practice
- `man apk info` describes query options, and supports then only when provided a search argument
- `man apk list` describes query options. but does not actually support them <https://gitlab.alpinelinux.org/alpine/apk-tools/-/work_items/11207>
- `apk query` naturally supports query options, and as such, requires a search argument
- `apk info -e ...<search>` checks for installed packaged and returns exit status `1` if any are not installed,
- whereas `apk list|query --installed <search>` will list installed packages, ignore missing packages, and return exit status `0`
- `--fields name,version` only works with `--format <json|yaml>` and becomes incompatible with `-e`, as they are query options
- `apk list|info|query` all have an undocumented `--search` option that enables fuzzy searches <https://gitlab.alpinelinux.org/alpine/apk-tools/-/work_items/11210>
- `apk query --format json ...<search>` returns: name, version, description, arch, license, origin, url, file-size
- `apk info --format json ...<package>` returns: name, version, description, url, installed-size
- there is also `--fields all` which returns more

## `apk --help`

```
apk-tools 3.0.6-r0, compiled for aarch64.

Usage: apk [<GLOBAL OPTIONS>...] COMMAND [<OPTIONS>...] [<ARGUMENTS>...]

Package installation and removal:
  add        Add or modify constraints in WORLD and commit changes
  del        Remove constraints from WORLD and commit changes

System maintenance:
  fix        Fix, reinstall or upgrade packages without modifying WORLD
  update     Update repository indexes
  upgrade    Install upgrades available from repositories
  cache      Manage the local package cache

Querying package information:
  query      Query information about packages by various criteria
  list       List packages matching a pattern or other criteria
  dot        Render dependencies as graphviz graphs
  policy     Show repository policy for packages
  search     Search for packages by name or description
  info       Give detailed information about packages or repositories

Repository and package maintenance:
  mkndx      Create repository index (v3) file from packages
  mkpkg      Create package (v3)
  index      Create repository index (v2) file from packages
  fetch      Download packages from repositories to a local directory
  manifest   Show checksums of package contents
  extract    Extract package file contents
  verify     Verify package integrity and signature
  adbsign    Sign, resign or recompress v3 packages and indexes

Miscellaneous:
  audit      Audit system for changes
  stats      Show statistics about repositories and installations
  version    Compare package versions or perform tests on version strings
  adbdump    Dump v3 files in textual representation
  adbgen     Generate v3 files from text representation
  convdb     Convert v2 installed database to v3 format
  convndx    Convert v2 indexes to v3 format

This apk has coffee making abilities.
For more information: man 8 apk
```

## list

### `apk list --help`

```
apk-tools 3.0.6-r0, compiled for aarch64.

Usage: apk list [<OPTIONS>...] PATTERN...

Description:
  apk list searches package indices for packages matching the given patterns
  and prints any matching packages.

Global options:
  --allow-untrusted     Install packages with untrusted signature or no
                        signature
  --arch ARCH           Temporarily override architectures
  --cache[=BOOL]        When disabled, prevents using any local cache paths
  --cache-dir CACHEDIR  Temporarily override the cache directory
  --cache-max-age AGE   Maximum AGE (in minutes) for index in cache before
                        it's refreshed
  --cache-packages[=BOOL]
                        Store a copy of packages at installation time to
                        cache
  --cache-predownload[=BOOL]
                        Download needed packages to cache before starting to
                        commit a transaction
  --check-certificate[=BOOL]
                        When disabled, omits the validation of the HTTPS
                        server certificate
  --force, -f           Enable selected --force-* options (deprecated)
  --force-binary-stdout
                        Continue even if binary data will be printed to the
                        terminal
  --force-broken-world  DANGEROUS: Delete world constraints until a solution
                        without conflicts is found
  --force-missing-repositories
                        Continue even if some of the repository indexes are
                        not available
  --force-no-chroot     Disable chroot for scripts
  --force-non-repository
                        Continue even if packages may be lost on reboot
  --force-old-apk       Continue even if packages use unsupported features
  --force-overwrite     Overwrite files in other packages
  --force-refresh       Do not use cached files (local or from proxy)
  --help, -h            Print the list of all commands with descriptions
  --interactive[=AUTO]  Determine if questions can be asked before
                        performing certain operations
  --keys-dir KEYSDIR    Override the default system trusted keys directories
  --legacy-info[=BOOL]  Print output from "info" applet in legacy format or
                        new "query" format
  --logfile[=BOOL]      If turned off, disables the writing of the log file
  --network[=BOOL]      If turned off, does not use the network
  --preserve-env[=BOOL]
                        Allow passing the user environment down to scripts
                        (excluding variables starting APK_ which are
                        reserved)
  --pretty-print[=AUTO]
                        Determine if output should be stylized to be human
                        readable
  --preupgrade-depends DEPS
                        Add or modify preupgrade dependencies
  --print-arch          Print default arch and exit
  --progress[=AUTO]     Enable or disable progress bar
  --progress-fd FD      Write progress to the specified file descriptor
  --purge[=BOOL]        Purge modified configuration and cached packages
  --quiet, -q           Print less information
  --repositories-file REPOFILE
                        Override system repositories, see
                        apk-repositories(5)
  --repository, -X REPO
                        Specify additional package repository
  --repository-config REPOCONFIG
                        Specify additional package repository configuration
  --root, -p ROOT       Manage file system at ROOT
  --root-tmpfs[=AUTO]   Specify if the ROOT is a temporary filesystem
  --sync[=AUTO]         Determine if filesystem caches should be committed
                        to disk
  --timeout TIME        Timeout network connections if no progress is made
                        in TIME seconds
  --update-cache, -U    Alias for '--cache-max-age 0'
  --uvol-manager UVOL   Specify the OpenWRT UVOL volume manager executable
                        location
  --verbose, -v         Print more information (can be specified twice)
  --version, -V         Print program version and exit
  --wait TIME           Wait for TIME seconds to get an exclusive repository
                        lock before failing

Query options:
  --all-matches         Select all matched packages
  --available           Filter selection to available packages
  --fields FIELDS[:REVERSE_FIELD]
                        A comma separated list of fields to include in the
                        output
  --format FORMATSPEC   Specify output format from default, yaml or json
  --from FROMSPEC       Search packages from: system (all system sources),
                        repositories (exclude installed database), installed
                        (exclude normal repositories) or none (command-line
                        repositories only)
  --installed           Filter selection to installed packages
  --match FIELDS        A comma separated list of fields to match the query
                        against
  --recursive           Run solver algorithm with given CONSTRAINTS to
                        select packages
  --summarize FIELD[:REVERSE_FIELD]
                        Produce a summary of the specified field from all
                        matches
  --upgradable          Filter selection to upgradable packages
  --world               Include apk-world(5) dependencies in constraints
  --orphaned            Filter selection to orphaned packages

List options:
  --available, -a       Consider only available packages
  --depends, -d         List packages by dependency
  --installed, -I       Consider only installed packages
  --manifest            List installed packages in format `<name> <version>`
  --origin, -o          List packages by origin
  --orphaned, -O        Consider only orphaned packages
  --providers, -P       List packages by provider
  --upgradable, --upgradeable, -u
                        Consider only upgradable packages

For more information: man 8 apk-list
```

### `apk list --installed`

```
alpine-baselayout-3.7.2-r1 aarch64 {alpine-baselayout} (GPL-2.0-only) [installed]
alpine-baselayout-data-3.7.2-r1 aarch64 {alpine-baselayout} (GPL-2.0-only) [installed]
alpine-keys-2.6-r0 aarch64 {alpine-keys} (MIT) [installed]
alpine-release-3.24.1-r0 aarch64 {alpine-base} (MIT) [installed]
apk-tools-3.0.6-r0 aarch64 {apk-tools} (GPL-2.0-only) [installed]
busybox-1.37.0-r31 aarch64 {busybox} (GPL-2.0-only) [installed]
busybox-binsh-1.37.0-r31 aarch64 {busybox} (GPL-2.0-only) [installed]
ca-certificates-bundle-20260611-r0 aarch64 {ca-certificates} (MPL-2.0 AND MIT) [installed]
libapk-3.0.6-r0 aarch64 {apk-tools} (GPL-2.0-only) [installed]
libcrypto3-3.5.7-r0 aarch64 {openssl} (Apache-2.0) [installed]
libssl3-3.5.7-r0 aarch64 {openssl} (Apache-2.0) [installed]
musl-1.2.6-r2 aarch64 {musl} (MIT) [installed]
musl-utils-1.2.6-r2 aarch64 {musl} (MIT AND BSD-2-Clause AND GPL-2.0-or-later) [installed]
scanelf-1.3.9-r1 aarch64 {pax-utils} (GPL-2.0-only) [installed]
ssl_client-1.37.0-r31 aarch64 {busybox} (GPL-2.0-only) [installed]
zlib-1.3.2-r0 aarch64 {zlib} (Zlib) [installed]
```

## query

### `apk query --help`

```
apk-tools 3.0.6-r0, compiled for aarch64.

Usage: apk query [<OPTIONS>...] QUERY...
   or: apk query [<OPTIONS>...] --recursive CONSTRAINTS...

Description:
  apk query searches for matching packages from selected sources.

Global options:
  --allow-untrusted     Install packages with untrusted signature or no
                        signature
  --arch ARCH           Temporarily override architectures
  --cache[=BOOL]        When disabled, prevents using any local cache paths
  --cache-dir CACHEDIR  Temporarily override the cache directory
  --cache-max-age AGE   Maximum AGE (in minutes) for index in cache before
                        it's refreshed
  --cache-packages[=BOOL]
                        Store a copy of packages at installation time to
                        cache
  --cache-predownload[=BOOL]
                        Download needed packages to cache before starting to
                        commit a transaction
  --check-certificate[=BOOL]
                        When disabled, omits the validation of the HTTPS
                        server certificate
  --force, -f           Enable selected --force-* options (deprecated)
  --force-binary-stdout
                        Continue even if binary data will be printed to the
                        terminal
  --force-broken-world  DANGEROUS: Delete world constraints until a solution
                        without conflicts is found
  --force-missing-repositories
                        Continue even if some of the repository indexes are
                        not available
  --force-no-chroot     Disable chroot for scripts
  --force-non-repository
                        Continue even if packages may be lost on reboot
  --force-old-apk       Continue even if packages use unsupported features
  --force-overwrite     Overwrite files in other packages
  --force-refresh       Do not use cached files (local or from proxy)
  --help, -h            Print the list of all commands with descriptions
  --interactive[=AUTO]  Determine if questions can be asked before
                        performing certain operations
  --keys-dir KEYSDIR    Override the default system trusted keys directories
  --legacy-info[=BOOL]  Print output from "info" applet in legacy format or
                        new "query" format
  --logfile[=BOOL]      If turned off, disables the writing of the log file
  --network[=BOOL]      If turned off, does not use the network
  --preserve-env[=BOOL]
                        Allow passing the user environment down to scripts
                        (excluding variables starting APK_ which are
                        reserved)
  --pretty-print[=AUTO]
                        Determine if output should be stylized to be human
                        readable
  --preupgrade-depends DEPS
                        Add or modify preupgrade dependencies
  --print-arch          Print default arch and exit
  --progress[=AUTO]     Enable or disable progress bar
  --progress-fd FD      Write progress to the specified file descriptor
  --purge[=BOOL]        Purge modified configuration and cached packages
  --quiet, -q           Print less information
  --repositories-file REPOFILE
                        Override system repositories, see
                        apk-repositories(5)
  --repository, -X REPO
                        Specify additional package repository
  --repository-config REPOCONFIG
                        Specify additional package repository configuration
  --root, -p ROOT       Manage file system at ROOT
  --root-tmpfs[=AUTO]   Specify if the ROOT is a temporary filesystem
  --sync[=AUTO]         Determine if filesystem caches should be committed
                        to disk
  --timeout TIME        Timeout network connections if no progress is made
                        in TIME seconds
  --update-cache, -U    Alias for '--cache-max-age 0'
  --uvol-manager UVOL   Specify the OpenWRT UVOL volume manager executable
                        location
  --verbose, -v         Print more information (can be specified twice)
  --version, -V         Print program version and exit
  --wait TIME           Wait for TIME seconds to get an exclusive repository
                        lock before failing

Query options:
  --all-matches         Select all matched packages
  --available           Filter selection to available packages
  --fields FIELDS[:REVERSE_FIELD]
                        A comma separated list of fields to include in the
                        output
  --format FORMATSPEC   Specify output format from default, yaml or json
  --from FROMSPEC       Search packages from: system (all system sources),
                        repositories (exclude installed database), installed
                        (exclude normal repositories) or none (command-line
                        repositories only)
  --installed           Filter selection to installed packages
  --match FIELDS        A comma separated list of fields to match the query
                        against
  --recursive           Run solver algorithm with given CONSTRAINTS to
                        select packages
  --summarize FIELD[:REVERSE_FIELD]
                        Produce a summary of the specified field from all
                        matches
  --upgradable          Filter selection to upgradable packages
  --world               Include apk-world(5) dependencies in constraints
  --orphaned            Filter selection to orphaned packages
```

### `apk query --installed busybox`

```
Name: busybox
Version: 1.37.0-r31
Description: Size optimized toolbox of many common UNIX utilities
Arch: aarch64
License: GPL-2.0-only
Origin: busybox
URL: https://busybox.net/
File-Size: 521974
```

### `apk query --installed --format=yaml --fields=name,version  busybox`

```
# 1 items
- name: busybox
  version: 1.37.0-r31
```

## del

### `apk del --help`

```
apk-tools 3.0.6-r0, compiled for aarch64.

Usage: apk del [<OPTIONS>...] CONSTRAINTS...

Description:
  apk del removes constraints from WORLD (see apk-world(5)) and commits
  changes to disk. This usually involves removing unneeded packages, but may
  also cause other changes to the installed packages.

Global options:
  --allow-untrusted     Install packages with untrusted signature or no
                        signature
  --arch ARCH           Temporarily override architectures
  --cache[=BOOL]        When disabled, prevents using any local cache paths
  --cache-dir CACHEDIR  Temporarily override the cache directory
  --cache-max-age AGE   Maximum AGE (in minutes) for index in cache before
                        it's refreshed
  --cache-packages[=BOOL]
                        Store a copy of packages at installation time to
                        cache
  --cache-predownload[=BOOL]
                        Download needed packages to cache before starting to
                        commit a transaction
  --check-certificate[=BOOL]
                        When disabled, omits the validation of the HTTPS
                        server certificate
  --force, -f           Enable selected --force-* options (deprecated)
  --force-binary-stdout
                        Continue even if binary data will be printed to the
                        terminal
  --force-broken-world  DANGEROUS: Delete world constraints until a solution
                        without conflicts is found
  --force-missing-repositories
                        Continue even if some of the repository indexes are
                        not available
  --force-no-chroot     Disable chroot for scripts
  --force-non-repository
                        Continue even if packages may be lost on reboot
  --force-old-apk       Continue even if packages use unsupported features
  --force-overwrite     Overwrite files in other packages
  --force-refresh       Do not use cached files (local or from proxy)
  --help, -h            Print the list of all commands with descriptions
  --interactive[=AUTO]  Determine if questions can be asked before
                        performing certain operations
  --keys-dir KEYSDIR    Override the default system trusted keys directories
  --legacy-info[=BOOL]  Print output from "info" applet in legacy format or
                        new "query" format
  --logfile[=BOOL]      If turned off, disables the writing of the log file
  --network[=BOOL]      If turned off, does not use the network
  --preserve-env[=BOOL]
                        Allow passing the user environment down to scripts
                        (excluding variables starting APK_ which are
                        reserved)
  --pretty-print[=AUTO]
                        Determine if output should be stylized to be human
                        readable
  --preupgrade-depends DEPS
                        Add or modify preupgrade dependencies
  --print-arch          Print default arch and exit
  --progress[=AUTO]     Enable or disable progress bar
  --progress-fd FD      Write progress to the specified file descriptor
  --purge[=BOOL]        Purge modified configuration and cached packages
  --quiet, -q           Print less information
  --repositories-file REPOFILE
                        Override system repositories, see
                        apk-repositories(5)
  --repository, -X REPO
                        Specify additional package repository
  --repository-config REPOCONFIG
                        Specify additional package repository configuration
  --root, -p ROOT       Manage file system at ROOT
  --root-tmpfs[=AUTO]   Specify if the ROOT is a temporary filesystem
  --sync[=AUTO]         Determine if filesystem caches should be committed
                        to disk
  --timeout TIME        Timeout network connections if no progress is made
                        in TIME seconds
  --update-cache, -U    Alias for '--cache-max-age 0'
  --uvol-manager UVOL   Specify the OpenWRT UVOL volume manager executable
                        location
  --verbose, -v         Print more information (can be specified twice)
  --version, -V         Print program version and exit
  --wait TIME           Wait for TIME seconds to get an exclusive repository
                        lock before failing

Commit options:
  --clean-protected[=BOOL]
                        If disabled, prevents creation of .apk-new files in
                        configuration directories
  --commit-hooks[=BOOL]
                        If disabled, skips the pre/post hook scripts (but
                        not other scripts)
  --initramfs-diskless-boot
                        Used by initramfs when it's recreating root tmpfs
  --overlay-from-stdin  Read list of overlay files from stdin
  --scripts[=BOOL]      If disabled, prevents execution of all scripts
  --simulate[=BOOL], -s
                        Simulate the requested operation without making any
                        changes

Del options:
  --rdepends, -r        Recursively delete all top-level reverse
                        dependencies, too

For more information: man 8 apk-del
```

## add

### `apk add --help`

```
apk-tools 3.0.6-r0, compiled for aarch64.

Usage: apk add [<OPTIONS>...] [CONSTRAINTS|_file_]...

Description:
  apk add adds or updates given constraints to WORLD (see apk-world(5)) and
  commit changes to disk. This usually involves installing new packages, but
  may also cause other changes to the installed packages.

Global options:
  --allow-untrusted     Install packages with untrusted signature or no
                        signature
  --arch ARCH           Temporarily override architectures
  --cache[=BOOL]        When disabled, prevents using any local cache paths
  --cache-dir CACHEDIR  Temporarily override the cache directory
  --cache-max-age AGE   Maximum AGE (in minutes) for index in cache before
                        it's refreshed
  --cache-packages[=BOOL]
                        Store a copy of packages at installation time to
                        cache
  --cache-predownload[=BOOL]
                        Download needed packages to cache before starting to
                        commit a transaction
  --check-certificate[=BOOL]
                        When disabled, omits the validation of the HTTPS
                        server certificate
  --force, -f           Enable selected --force-* options (deprecated)
  --force-binary-stdout
                        Continue even if binary data will be printed to the
                        terminal
  --force-broken-world  DANGEROUS: Delete world constraints until a solution
                        without conflicts is found
  --force-missing-repositories
                        Continue even if some of the repository indexes are
                        not available
  --force-no-chroot     Disable chroot for scripts
  --force-non-repository
                        Continue even if packages may be lost on reboot
  --force-old-apk       Continue even if packages use unsupported features
  --force-overwrite     Overwrite files in other packages
  --force-refresh       Do not use cached files (local or from proxy)
  --help, -h            Print the list of all commands with descriptions
  --interactive[=AUTO]  Determine if questions can be asked before
                        performing certain operations
  --keys-dir KEYSDIR    Override the default system trusted keys directories
  --legacy-info[=BOOL]  Print output from "info" applet in legacy format or
                        new "query" format
  --logfile[=BOOL]      If turned off, disables the writing of the log file
  --network[=BOOL]      If turned off, does not use the network
  --preserve-env[=BOOL]
                        Allow passing the user environment down to scripts
                        (excluding variables starting APK_ which are
                        reserved)
  --pretty-print[=AUTO]
                        Determine if output should be stylized to be human
                        readable
  --preupgrade-depends DEPS
                        Add or modify preupgrade dependencies
  --print-arch          Print default arch and exit
  --progress[=AUTO]     Enable or disable progress bar
  --progress-fd FD      Write progress to the specified file descriptor
  --purge[=BOOL]        Purge modified configuration and cached packages
  --quiet, -q           Print less information
  --repositories-file REPOFILE
                        Override system repositories, see
                        apk-repositories(5)
  --repository, -X REPO
                        Specify additional package repository
  --repository-config REPOCONFIG
                        Specify additional package repository configuration
  --root, -p ROOT       Manage file system at ROOT
  --root-tmpfs[=AUTO]   Specify if the ROOT is a temporary filesystem
  --sync[=AUTO]         Determine if filesystem caches should be committed
                        to disk
  --timeout TIME        Timeout network connections if no progress is made
                        in TIME seconds
  --update-cache, -U    Alias for '--cache-max-age 0'
  --uvol-manager UVOL   Specify the OpenWRT UVOL volume manager executable
                        location
  --verbose, -v         Print more information (can be specified twice)
  --version, -V         Print program version and exit
  --wait TIME           Wait for TIME seconds to get an exclusive repository
                        lock before failing

Commit options:
  --clean-protected[=BOOL]
                        If disabled, prevents creation of .apk-new files in
                        configuration directories
  --commit-hooks[=BOOL]
                        If disabled, skips the pre/post hook scripts (but
                        not other scripts)
  --initramfs-diskless-boot
                        Used by initramfs when it's recreating root tmpfs
  --overlay-from-stdin  Read list of overlay files from stdin
  --scripts[=BOOL]      If disabled, prevents execution of all scripts
  --simulate[=BOOL], -s
                        Simulate the requested operation without making any
                        changes

Add options:
  --initdb              Initialize a new package database
  --latest, -l          Always choose the latest package by version
  --no-chown            Deprecated alias for --usermode
  --upgrade, -u         Upgrade PACKAGES and their dependencies
  --usermode            Create usermode database with --initdb
  --virtual, -t NAME    Create virtual package NAME with given dependencies

For more information: man 8 apk-add
```

## update

### `apk update --help`

```
apk-tools 3.0.6-r0, compiled for aarch64.

Usage: apk upgrade [<OPTIONS>...] [<PACKAGES>...]

Description:
  apk upgrade upgrades installed packages to the latest version available
  from configured package repositories (see apk-repositories(5)). When no
  packages are specified, all packages are upgraded if possible. If list of
  packages is provided, only those packages are upgraded along with needed
  dependencies.

Global options:
  --allow-untrusted     Install packages with untrusted signature or no
                        signature
  --arch ARCH           Temporarily override architectures
  --cache[=BOOL]        When disabled, prevents using any local cache paths
  --cache-dir CACHEDIR  Temporarily override the cache directory
  --cache-max-age AGE   Maximum AGE (in minutes) for index in cache before
                        it's refreshed
  --cache-packages[=BOOL]
                        Store a copy of packages at installation time to
                        cache
  --cache-predownload[=BOOL]
                        Download needed packages to cache before starting to
                        commit a transaction
  --check-certificate[=BOOL]
                        When disabled, omits the validation of the HTTPS
                        server certificate
  --force, -f           Enable selected --force-* options (deprecated)
  --force-binary-stdout
                        Continue even if binary data will be printed to the
                        terminal
  --force-broken-world  DANGEROUS: Delete world constraints until a solution
                        without conflicts is found
  --force-missing-repositories
                        Continue even if some of the repository indexes are
                        not available
  --force-no-chroot     Disable chroot for scripts
  --force-non-repository
                        Continue even if packages may be lost on reboot
  --force-old-apk       Continue even if packages use unsupported features
  --force-overwrite     Overwrite files in other packages
  --force-refresh       Do not use cached files (local or from proxy)
  --help, -h            Print the list of all commands with descriptions
  --interactive[=AUTO]  Determine if questions can be asked before
                        performing certain operations
  --keys-dir KEYSDIR    Override the default system trusted keys directories
  --legacy-info[=BOOL]  Print output from "info" applet in legacy format or
                        new "query" format
  --logfile[=BOOL]      If turned off, disables the writing of the log file
  --network[=BOOL]      If turned off, does not use the network
  --preserve-env[=BOOL]
                        Allow passing the user environment down to scripts
                        (excluding variables starting APK_ which are
                        reserved)
  --pretty-print[=AUTO]
                        Determine if output should be stylized to be human
                        readable
  --preupgrade-depends DEPS
                        Add or modify preupgrade dependencies
  --print-arch          Print default arch and exit
  --progress[=AUTO]     Enable or disable progress bar
  --progress-fd FD      Write progress to the specified file descriptor
  --purge[=BOOL]        Purge modified configuration and cached packages
  --quiet, -q           Print less information
  --repositories-file REPOFILE
                        Override system repositories, see
                        apk-repositories(5)
  --repository, -X REPO
                        Specify additional package repository
  --repository-config REPOCONFIG
                        Specify additional package repository configuration
  --root, -p ROOT       Manage file system at ROOT
  --root-tmpfs[=AUTO]   Specify if the ROOT is a temporary filesystem
  --sync[=AUTO]         Determine if filesystem caches should be committed
                        to disk
  --timeout TIME        Timeout network connections if no progress is made
                        in TIME seconds
  --update-cache, -U    Alias for '--cache-max-age 0'
  --uvol-manager UVOL   Specify the OpenWRT UVOL volume manager executable
                        location
  --verbose, -v         Print more information (can be specified twice)
  --version, -V         Print program version and exit
  --wait TIME           Wait for TIME seconds to get an exclusive repository
                        lock before failing

Commit options:
  --clean-protected[=BOOL]
                        If disabled, prevents creation of .apk-new files in
                        configuration directories
  --commit-hooks[=BOOL]
                        If disabled, skips the pre/post hook scripts (but
                        not other scripts)
  --initramfs-diskless-boot
                        Used by initramfs when it's recreating root tmpfs
  --overlay-from-stdin  Read list of overlay files from stdin
  --scripts[=BOOL]      If disabled, prevents execution of all scripts
  --simulate[=BOOL], -s
                        Simulate the requested operation without making any
                        changes

Upgrade options:
  --available, -a       Reset all packages to versions available from
                        current repositories
  --ignore              Upgrade all other packages than the ones listed
  --latest, -l          Always choose the latest package by version
  --preupgrade[=BOOL]   If turned off, disables the preupgrade step
  --preupgrade-only     Perform only the preupgrade
  --prune               Prune the WORLD by removing packages which are no
                        longer available from any configured repository

For more information: man 8 apk-upgrade
```

### `apk update`

```
v3.24.1-176-gabde3c23ae7 [https://dl-cdn.alpinelinux.org/alpine/v3.24/main]
v3.24.1-181-gb931c38a84a [https://dl-cdn.alpinelinux.org/alpine/v3.24/community]
OK: 28539 distinct packages available
```

## upgrade

### `apk upgrade --help`

```
apk-tools 3.0.6-r0, compiled for aarch64.

Usage: apk upgrade [<OPTIONS>...] [<PACKAGES>...]

Description:
  apk upgrade upgrades installed packages to the latest version available
  from configured package repositories (see apk-repositories(5)). When no
  packages are specified, all packages are upgraded if possible. If list of
  packages is provided, only those packages are upgraded along with needed
  dependencies.

Global options:
  --allow-untrusted     Install packages with untrusted signature or no
                        signature
  --arch ARCH           Temporarily override architectures
  --cache[=BOOL]        When disabled, prevents using any local cache paths
  --cache-dir CACHEDIR  Temporarily override the cache directory
  --cache-max-age AGE   Maximum AGE (in minutes) for index in cache before
                        it's refreshed
  --cache-packages[=BOOL]
                        Store a copy of packages at installation time to
                        cache
  --cache-predownload[=BOOL]
                        Download needed packages to cache before starting to
                        commit a transaction
  --check-certificate[=BOOL]
                        When disabled, omits the validation of the HTTPS
                        server certificate
  --force, -f           Enable selected --force-* options (deprecated)
  --force-binary-stdout
                        Continue even if binary data will be printed to the
                        terminal
  --force-broken-world  DANGEROUS: Delete world constraints until a solution
                        without conflicts is found
  --force-missing-repositories
                        Continue even if some of the repository indexes are
                        not available
  --force-no-chroot     Disable chroot for scripts
  --force-non-repository
                        Continue even if packages may be lost on reboot
  --force-old-apk       Continue even if packages use unsupported features
  --force-overwrite     Overwrite files in other packages
  --force-refresh       Do not use cached files (local or from proxy)
  --help, -h            Print the list of all commands with descriptions
  --interactive[=AUTO]  Determine if questions can be asked before
                        performing certain operations
  --keys-dir KEYSDIR    Override the default system trusted keys directories
  --legacy-info[=BOOL]  Print output from "info" applet in legacy format or
                        new "query" format
  --logfile[=BOOL]      If turned off, disables the writing of the log file
  --network[=BOOL]      If turned off, does not use the network
  --preserve-env[=BOOL]
                        Allow passing the user environment down to scripts
                        (excluding variables starting APK_ which are
                        reserved)
  --pretty-print[=AUTO]
                        Determine if output should be stylized to be human
                        readable
  --preupgrade-depends DEPS
                        Add or modify preupgrade dependencies
  --print-arch          Print default arch and exit
  --progress[=AUTO]     Enable or disable progress bar
  --progress-fd FD      Write progress to the specified file descriptor
  --purge[=BOOL]        Purge modified configuration and cached packages
  --quiet, -q           Print less information
  --repositories-file REPOFILE
                        Override system repositories, see
                        apk-repositories(5)
  --repository, -X REPO
                        Specify additional package repository
  --repository-config REPOCONFIG
                        Specify additional package repository configuration
  --root, -p ROOT       Manage file system at ROOT
  --root-tmpfs[=AUTO]   Specify if the ROOT is a temporary filesystem
  --sync[=AUTO]         Determine if filesystem caches should be committed
                        to disk
  --timeout TIME        Timeout network connections if no progress is made
                        in TIME seconds
  --update-cache, -U    Alias for '--cache-max-age 0'
  --uvol-manager UVOL   Specify the OpenWRT UVOL volume manager executable
                        location
  --verbose, -v         Print more information (can be specified twice)
  --version, -V         Print program version and exit
  --wait TIME           Wait for TIME seconds to get an exclusive repository
                        lock before failing

Commit options:
  --clean-protected[=BOOL]
                        If disabled, prevents creation of .apk-new files in
                        configuration directories
  --commit-hooks[=BOOL]
                        If disabled, skips the pre/post hook scripts (but
                        not other scripts)
  --initramfs-diskless-boot
                        Used by initramfs when it's recreating root tmpfs
  --overlay-from-stdin  Read list of overlay files from stdin
  --scripts[=BOOL]      If disabled, prevents execution of all scripts
  --simulate[=BOOL], -s
                        Simulate the requested operation without making any
                        changes

Upgrade options:
  --available, -a       Reset all packages to versions available from
                        current repositories
  --ignore              Upgrade all other packages than the ones listed
  --latest, -l          Always choose the latest package by version
  --preupgrade[=BOOL]   If turned off, disables the preupgrade step
  --preupgrade-only     Perform only the preupgrade
  --prune               Prune the WORLD by removing packages which are no
                        longer available from any configured repository

For more information: man 8 apk-upgrade
```

### `apk --update-cache upgrade`

```
OK: 8433 KiB in 16 packages
```
