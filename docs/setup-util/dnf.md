# dnf / rpm

## container

```
docker run --rm -it fedora:latest
docker run --rm -it almalinux:latest
docker run --rm -it openeuler/openeuler:latest
docker run --rm -it openmandriva/minimal:rock
docker run --rm -it openmandriva/minimal:rolling
```

## resources

- <https://github.com/rpm-software-management/dnf5>
- <https://dnf.readthedocs.io/en/latest/command_ref.html>
- <https://opensource.com/article/18/8/guide-yum-dnf>
- <https://docs.fedoraproject.org/en-US/quick-docs/dnf/>

## notes

- uses `rpm` behind the scenes, and `rpm` is always available on a `dnf` machine
- `dnf` can install `.rpm` local files and remote packages, `rpm` can install remote `.rpm` files
- `dnf` is the sucessor to `yum` (same api)

## `rpm`

### `rpm --help`

```
Usage: rpm [OPTION...]

Query/Verify package selection options:
  -a, --all                          query/verify all packages
  -f, --file                         query/verify package(s) owning installed file
      --path                         query/verify package(s) owning path, installed or not
  -g, --group                        query/verify package(s) in group
  -p, --package                      query/verify a package file
  -q, --query                        rpm query mode
      --triggeredby                  query the package(s) triggered by the package
      --whatconflicts                query/verify the package(s) which conflict with a dependency
      --whatrequires                 query/verify the package(s) which require a dependency
      --whatobsoletes                query/verify the package(s) which obsolete a dependency
      --whatprovides                 query/verify the package(s) which provide a dependency
      --whatrecommends               query/verify the package(s) which recommends a dependency
      --whatsuggests                 query/verify the package(s) which suggests a dependency
      --whatsupplements              query/verify the package(s) which supplements a dependency
      --whatenhances                 query/verify the package(s) which enhances a dependency
      --nomanifest                   do not process non-package files as manifests

Query/Verify file selection options:
  -c, --configfiles                  only include configuration files
  -d, --docfiles                     only include documentation files
  -L, --licensefiles                 only include license files
  -A, --artifactfiles                only include artifact files
      --noghost                      exclude %%ghost files
      --noconfig                     exclude %%config files
      --noartifact                   exclude %%artifact files

Query options (with -q or --query):
      --dump                         dump basic file information
  -l, --list                         list files in package
      --queryformat=QUERYFORMAT      use the following query format
  -s, --state                        display the states of the listed files

Verify options (with -V or --verify):
      --nofiledigest                 don't verify digest of files
      --nofiles                      don't verify files in package
      --nodeps                       don't verify package dependencies
      --noscript                     don't execute verify script(s)

Install/Upgrade/Erase options:
      --allfiles                     install all files, even configurations which might otherwise be skipped
      --allmatches                   remove all packages which match <package> (normally an error is generated if <package> specified multiple packages)
      --badreloc                     relocate files in non-relocatable package
  -e, --erase=<package>+             erase (uninstall) package
      --excludedocs                  do not install documentation
      --excludepath=<path>           skip files with leading component <path>
      --force                        short hand for --replacepkgs --replacefiles
  -F, --freshen=<packagefile>+       upgrade package(s) if already installed
  -h, --hash                         print hash marks as package installs (good with -v)
      --ignorearch                   don't verify package architecture
      --ignoreos                     don't verify package operating system
      --ignoresize                   don't check disk space before installing
      --noverify                     short hand for --ignorepayload --ignoresignature
  -i, --install                      install package(s)
      --justdb                       update the database, but do not modify the filesystem
      --nodb                         do not update the database, but modify the filesystem
      --nodeps                       do not verify package dependencies
      --nofiledigest                 don't verify digest of files
      --nocontexts                   don't install file security contexts
      --nocaps                       don't install file capabilities
      --noorder                      do not reorder package installation to satisfy dependencies
      --noscripts                    do not execute package scriptlet(s)
      --notriggers                   do not execute any scriptlet(s) triggered by this package
      --oldpackage                   upgrade to an old version of the package (--force on upgrades does this automatically)
      --percent                      print percentages as package installs
      --prefix=<dir>                 relocate the package to <dir>, if relocatable
      --relocate=<old>=<new>         relocate files from path <old> to <new>
      --replacefiles                 ignore file conflicts between packages
      --replacepkgs                  reinstall if the package is already present
      --test                         don't install, but tell if it would work or not
  -U, --upgrade=<packagefile>+       upgrade package(s)
      --reinstall=<packagefile>+     reinstall package(s)
      --restore=<packagefile>+       restore package(s)

Common options for all rpm modes and executables:
  -D, --define='MACRO EXPR'          define MACRO with value EXPR
      --undefine=MACRO               undefine MACRO
  -E, --eval='EXPR'                  print macro expansion of EXPR
      --target=CPU-VENDOR-OS         Specify target platform
      --macros=<FILE:...>            read <FILE:...> instead of default file(s)
      --load=<FILE>                  load a single macro file
      --noplugins                    don't enable any plugins
      --nodigest                     don't verify package digest(s)
      --nosignature                  don't verify package signature(s)
      --rcfile=<FILE:...>            read <FILE:...> instead of default file(s)
  -r, --root=ROOT                    use ROOT as top level directory (default: "/")
      --dbpath=DIRECTORY             use database in DIRECTORY
      --querytags                    display known query tags
      --showrc                       display final rpmrc and macro configuration
      --quiet                        provide less detailed output
  -v, --verbose                      provide more detailed output
      --version                      print the version of rpm being used

Options implemented via popt alias/exec:
      --scripts                      list install/erase scriptlets from package(s)
      --conflicts                    list capabilities this package conflicts with
      --obsoletes                    list other packages removed by installing this package
      --provides                     list capabilities that this package provides
      --requires                     list capabilities required by package(s)
      --recommends                   list capabilities recommended by package(s)
      --suggests                     list capabilities suggested by package(s)
      --supplements                  list capabilities supplemented by package(s)
      --enhances                     list capabilities enhanced by package(s)
      --info                         list descriptive information from package(s)
      --changelog                    list change logs for this package
      --changes                      list changes for this package with full time stamps
      --xml                          list metadata in xml
      --json                         list metadata in JSON
      --triggers                     list trigger scriptlets from package(s)
      --filetriggers                 list filetrigger scriptlets from package(s)
      --last                         list package(s) by install time, most recent first
      --dupes                        list duplicated packages
      --filesbypkg                   list all files from each package
      --fileclass                    list file names with their classes
      --filemime                     list file names with their mime types
      --filecolor                    list file names with their colors
      --fileprovide                  list file names with their provides
      --filerequire                  list file names with requires
      --filecaps                     list file names with their POSIX1.e capabilities

Help options:
  -?, --help                         Show this help message
      --usage                        Display brief usage message
```

## `rpm -qpi`

### `rpm -qpi  'https://mediaarea.net/repo/rpm/releases/repo-MediaArea-1.0-26.noarch.rpm'`

```
warning: https://mediaarea.net/repo/rpm/releases/repo-MediaArea-1.0-26.noarch.rpm: Header OpenPGP V4 RSA/SHA512 signature, key ID c10e11090ec0e438: NOKEY
Name        : repo-MediaArea
Version     : 1.0
Release     : 26
Architecture: noarch
Install Date: (not installed)
Group       : System Environment/Base
Size        : 0
License     : MIT
Signature   :
              RSA/SHA512, Wed 29 Oct 2025 01:38:16, Key ID c10e11090ec0e438
Source RPM  : repo-MediaArea-1.0-26.src.rpm
Build Date  : Wed 29 Oct 2025 01:38:16
Build Host  : a5683b3fead8
Packager    : MediaArea.net SARL <info@mediaarea.net>
URL         : mediaarea.net
Summary     : MediaArea packages repository
Description :
MediaArea.net SARL software repository for RPM based distributions
```

## `rpm -qp`

### `rpm -qp --queryformat '%{NAME} %{VERSION}-%{RELEASE}\n' 'https://mediaarea.net/repo/rpm/releases/repo-MediaArea-1.0-26.noarch.
rpm'`
```
warning: https://mediaarea.net/repo/rpm/releases/repo-MediaArea-1.0-26.noarch.rpm: Header OpenPGP V4 RSA/SHA512 signature, key ID c10e11090ec0e438: NOKEY
repo-MediaArea 1.0-26
```

## `dnf`

<https://dnf.readthedocs.io/en/latest/command_ref.html>

```
Return values:
0 : Operation was successful.
1 : An error occurred, which was handled by dnf.
3 : An unknown unhandled error occurred during operation.
100: See check-update
200: There was a problem with acquiring or releasing of locks.
```

### `dnf --help`

```
Usage:
  dnf5 [GLOBAL OPTIONS] <COMMAND> ...

Description:
  DNF5 is a program for maintaining packages.

Software Management Commands:
  do                                     Do transaction
  install                                Install software
  upgrade                                Upgrade software
  remove                                 Remove (uninstall) software
  distro-sync                            Upgrade or downgrade installed software to the latest available versions
  downgrade                              Downgrade software
  reinstall                              Reinstall software
  debuginfo-install                      Install debuginfo packages.
  swap                                   Remove software and install another in one transaction
  mark                                   Change the reason of an installed package
  autoremove                             Remove all unneeded packages originally installed as dependencies.
  provides                               Find what package provides the given value
  replay                                 Replay a transaction that was previously stored to a directory
  check-upgrade                          Check for available package upgrades
  check                                  Check for problems in the packagedb

Query Commands:
  leaves                                 List groups of installed packages not required by other installed packages
  repoquery                              Search for packages matching various criteria
  search                                 Search for software matching all specified strings
  list                                   Lists packages depending on the packages' relation to the system
  info                                   Lists packages depending on the packages' relation to the system with additional details

Subcommands:
  group                                  Manage comps groups
  environment                            Manage comps environments
  module                                 Manage modules
  history                                Manage transaction history
  repo                                   Manage repositories
  advisory                               Manage advisories
  versionlock                            Manage versionlock configuration
  system-upgrade                         Prepare system for upgrade to a new release
  offline-distrosync                     Store a distro-sync transaction to be performed offline
  offline-upgrade                        Store an upgrade transaction to be performed offline
  offline                                Manage offline transactions
  config-manager                         Manage configuration

Compatibility Aliases:
  check-update                           Alias for 'check-upgrade'
  dg                                     Alias for 'downgrade'
  dsync                                  Alias for 'distro-sync'
  grp                                    Alias for 'group'
  if                                     Alias for 'info'
  in                                     Alias for 'install'
  ls                                     Alias for 'list'
  mc                                     Alias for 'makecache'
  rei                                    Alias for 'reinstall'
  repoinfo                               Alias for 'repo info'
  repolist                               Alias for 'repo list'
  rm                                     Alias for 'remove'
  rq                                     Alias for 'repoquery'
  se                                     Alias for 'search'
  up                                     Alias for 'upgrade'
  update                                 Alias for 'upgrade'
  updateinfo                             Alias for 'advisory'
  upgrade-minimal                        Alias for 'upgrade --minimal'

Commands:
  clean                                  Remove or expire cached data
  download                               Download software to the current directory
  makecache                              Generate the metadata cache
  builddep                               Install build dependencies for package or spec file
  changelog                              Show package changelogs
  copr                                   Manage Copr repositories (add-ons provided by users/community/third-party)
  needs-restarting                       Determine whether system or systemd services need restarting
  repoclosure                            Print list of unresolved dependencies for repositories
  repomanage                             Manage a directory with repodata or with rpm packages
  reposync                               Synchronize a remote DNF repository to a local directory.
  build-dep                              Compatibility alias for 'builddep'

Global options:
  -h, --help                             Print help
  --config=CONFIG_FILE_PATH              Configuration file location
  -q, --quiet                            In combination with a non-interactive command, shows just the relevant content. Suppresses messages notifying about the current state or actions of dnf5.
  -C, --cacheonly                        Run entirely from system cache, don't update the cache and use it even in case it is expired.
  --color=COLOR                          Control whether color is used.
  --refresh                              Force refreshing metadata before running the command.
  --repofrompath=REPO_ID,REPO_PATH       create additional repository using id and path
  --setopt=[REPO_ID.]OPTION=VALUE        set arbitrary config and repo options
  --setvar=VAR_NAME=VALUE                set arbitrary variable
  -y, --assumeyes                        automatically answer yes for all questions
  --assumeno                             automatically answer no for all questions
  --best                                 try the best available package versions in transactions
  --no-best                              do not limit the transaction to the best candidate
  --no-docs                              Don't install files that are marked as documentation (which includes man pages and texinfo documents)
  -x package,..., --exclude=package,...  exclude packages by name or glob
  --enable-repo=REPO_ID,...              Enable additional repositories. List option. Supports globs, can be specified multiple times.
  --disable-repo=REPO_ID,...             Disable repositories. List option. Supports globs, can be specified multiple times.
  --repo=REPO_ID,...                     Enable just specific repositories. List option. Supports globs, can be specified multiple times.
  --no-gpgchecks                         disable OpenPGP signature checking (if RPM policy allows)
  --no-plugins                           Disable all libdnf5 plugins
  --enable-plugin=PLUGIN_NAME,...        Enable libdnf5 plugins by name. List option. Supports globs, can be specified multiple times.
  --disable-plugin=PLUGIN_NAME,...       Disable libdnf5 plugins by name. List option. Supports globs, can be specified multiple times.
  --comment=COMMENT                      add a comment to transaction
  --installroot=ABSOLUTE_PATH            set install root
  --use-host-config                      use configuration, reposdir, and vars from the host system rather than the installroot
  --releasever=RELEASEVER                override the value of $releasever in config and repo files
  --releasever-major=RELEASEVER_MAJOR    override the value of $releasever_major in config and repo files
  --releasever-minor=RELEASEVER_MINOR    override the value of $releasever_minor in config and repo files
  --show-new-leaves                      Show newly installed leaf packages and packages that became leaves after a transaction.
  --debugsolver                          Dump detailed solving results into files
  --dump-main-config                     Print main configuration values to stdout
  --dump-repo-config=REPO_ID,...         Print repository configuration values to stdout. List option. Supports globs
  --dump-variables                       Print variable values to stdout
  --version                              Show DNF5 version and exit
  --forcearch=FORCEARCH                  Force the use of a different architecture.
  --skip-file-locks                      Skip acquiring file locks, such as the lock on the system repository

Options Compatibility aliases:
  -c CONFIG_FILE_PATH                    Alias for '--config'
  --nobest                               Alias for '--no-best'
  --nodocs                               Alias for '--no-docs'
  --enablerepo=REPO_ID,...               Alias for '--enable-repo'
  --disablerepo=REPO_ID,...              Alias for '--disable-repo'
  --repoid=REPO_ID,...                   Alias for '--repo'
  --nogpgcheck                           Alias for '--no-gpgchecks'
  --noplugins                            Alias for '--no-plugins'
  --enableplugin=PLUGIN_NAME,...         Alias for '--enable-plugin'
  --disableplugin=PLUGIN_NAME,...        Alias for '--disable-plugin'
```

## `dnf install`

<https://dnf.readthedocs.io/en/latest/command_ref.html#install-command>

### `dnf install --help`

```
Usage:
  dnf5 [GLOBAL OPTIONS] install [OPTIONS] [ARGUMENTS]

Options:
  --allowerasing                               Allow removing of installed packages to resolve problems
  --skip-broken                                Allow resolving of depsolve problems by skipping packages
  --skip-unavailable                           Allow skipping unavailable packages
  --allow-downgrade                            Allow downgrade of dependencies for resolve of requested operation
  --no-allow-downgrade                         Disable downgrade of dependencies for resolve of requested operation
  --from-repo=REPO_ID,...                      The following items can be selected only from the specified repositories. All enabled repositories will still be used to satisfy dependencies.
  --from-vendor=VENDOR,...                     The following items can be selected only from the specified vendors. The vendor is ignored or vendor change policies (if allow_vendor_change=0) will still be used for items that satisfy dependencies.
  --downloadonly                               Only download packages for a transaction
  --offline                                    Store the transaction to be performed offline
  --advisories=ADVISORY_NAME,...               Include content contained in advisories with specified name. List option.
  --advisory-severities=ADVISORY_SEVERITY,...  Include content contained in advisories with specified severity. List option. Can be "critical", "important", "moderate", "low", "none".
  --bzs=BUGZILLA_ID,...                        Include content contained in advisories that fix a Bugzilla ID, Eg. 123123. List option.
  --cves=CVE_ID,...                            Include content contained in advisories that fix a CVE (Common Vulnerabilities and Exposures) ID, Eg. CVE-2201-0123. List option.
  --security                                   Include content contained in security advisories.
  --bugfix                                     Include content contained in bugfix advisories.
  --enhancement                                Include content contained in enhancement advisories.
  --newpackage                                 Include content contained in newpackage advisories.
  --store=STORED_TRANSACTION_PATH              Store the current transaction in a directory at the specified path instead of running it.
  --advisory=ADVISORY_NAME,...                 Alias for '--advisories'
  --bz=BUGZILLA_ID,...                         Alias for '--bzs'
  --cve=CVE_ID,...                             Alias for '--cves'

Arguments:
  specs                                        List of <package-spec-NPFB>|@<group-spec>|@<environment-spec> to install
```

## `dnf upgrade`

<https://dnf.readthedocs.io/en/latest/command_ref.html#upgrade-command>

### `dnf upgrade --help`

```
Usage:
  dnf5 [GLOBAL OPTIONS] upgrade [OPTIONS] [ARGUMENTS]

Options:
  --minimal                                    Upgrade packages only to the lowest versions that fix advisories of type bugfix, enhancement, security, or newpackage. In case that any option limiting advisories is used it upgrades packages only to the lowest versions that fix advisories that matchi
                                               ng selected advisory property
  --allowerasing                               Allow removing of installed packages to resolve problems
  --skip-unavailable                           Allow skipping unavailable packages
  --allow-downgrade                            Allow downgrade of dependencies for resolve of requested operation
  --no-allow-downgrade                         Disable downgrade of dependencies for resolve of requested operation
  --installed-from-repo=REPO_ID,...            Filters installed packages by the ID of the repository they were installed from.
  --from-repo=REPO_ID,...                      The following items can be selected only from the specified repositories. All enabled repositories will still be used to satisfy dependencies.
  --from-vendor=VENDOR,...                     The following items can be selected only from the specified vendors. The vendor is ignored or vendor change policies (if allow_vendor_change=0) will still be used for items that satisfy dependencies.
  --destdir=DESTDIR                            Set directory used for downloading packages to. Default location is to the current working directory. Automatically sets the --downloadonly option.
  --downloadonly                               Only download packages for a transaction
  --offline                                    Store the transaction to be performed offline
  --advisories=ADVISORY_NAME,...               Include content contained in advisories with specified name. List option.
  --advisory-severities=ADVISORY_SEVERITY,...  Include content contained in advisories with specified severity. List option. Can be "critical", "important", "moderate", "low", "none".
  --bzs=BUGZILLA_ID,...                        Include content contained in advisories that fix a Bugzilla ID, Eg. 123123. List option.
  --cves=CVE_ID,...                            Include content contained in advisories that fix a CVE (Common Vulnerabilities and Exposures) ID, Eg. CVE-2201-0123. List option.
  --security                                   Include content contained in security advisories.
  --bugfix                                     Include content contained in bugfix advisories.
  --enhancement                                Include content contained in enhancement advisories.
  --newpackage                                 Include content contained in newpackage advisories.
  --store=STORED_TRANSACTION_PATH              Store the current transaction in a directory at the specified path instead of running it.
  --advisory=ADVISORY_NAME,...                 Alias for '--advisories'
  --bz=BUGZILLA_ID,...                         Alias for '--bzs'
  --cve=CVE_ID,...                             Alias for '--cves'

Arguments:
  specs                                        List of [<package-spec-NPFB>|@<group-spec>|@<environment-spec>] to upgrade
```

## `dnf remove`

<https://dnf.readthedocs.io/en/latest/command_ref.html#remove-command>


### `dnf remove --help`

```
Usage:
  dnf5 [GLOBAL OPTIONS] remove [OPTIONS] [ARGUMENTS]

Options:
  --installed-from-repo=REPO_ID,...  Filters installed packages by the ID of the repository they were installed from.
  --no-autoremove                    Disable removal of dependencies that are no longer used
  --oldinstallonly                   Remove old installonly packages
  --limit=LIMIT                      Limit the number of installonly package versions to keep (must be >=1, used with --oldinstallonly)
  --offline                          Store the transaction to be performed offline
  --store=STORED_TRANSACTION_PATH    Store the current transaction in a directory at the specified path instead of running it.
  --noautoremove                     Alias for '--no-autoremove'

Arguments:
  specs                              List of <package-spec-NF>|@<group-spec>|@<environment-spec> to remove
```

## `dnf distro-sync`

<https://dnf.readthedocs.io/en/latest/command_ref.html#distro-sync-command>

### `dnf distro-sync --help`

```
Usage:
  dnf5 [GLOBAL OPTIONS] distro-sync [OPTIONS] [ARGUMENTS]

Options:
  --allowerasing                     Allow removing of installed packages to resolve problems
  --skip-broken                      Allow resolving of depsolve problems by skipping packages
  --skip-unavailable                 Allow skipping unavailable packages
  --installed-from-repo=REPO_ID,...  Filters installed packages by the ID of the repository they were installed from.
  --from-repo=REPO_ID,...            The following items can be selected only from the specified repositories. All enabled repositories will still be used to satisfy dependencies.
  --from-vendor=VENDOR,...           The following items can be selected only from the specified vendors. The vendor is ignored or vendor change policies (if allow_vendor_change=0) will still be used for items that satisfy dependencies.
  --downloadonly                     Only download packages for a transaction
  --offline                          Store the transaction to be performed offline
  --store=STORED_TRANSACTION_PATH    Store the current transaction in a directory at the specified path instead of running it.
Arguments:
  package-spec-NPFB                  List of package-spec-NPFB specifying which packages will be synced
```

## `dnf downgrade`

<https://dnf.readthedocs.io/en/latest/command_ref.html#downgrade-command>

### `dnf downgrade --help`

```
Usage:
  dnf5 [GLOBAL OPTIONS] downgrade [OPTIONS] [ARGUMENTS]

Options:
  --allowerasing                     Allow removing of installed packages to resolve problems
  --skip-broken                      Allow resolving of depsolve problems by skipping packages
  --skip-unavailable                 Allow skipping unavailable packages
  --allow-downgrade                  Allow downgrade of dependencies for resolve of requested operation
  --no-allow-downgrade               Disable downgrade of dependencies for resolve of requested operation
  --installed-from-repo=REPO_ID,...  Filters installed packages by the ID of the repository they were installed from.
  --from-repo=REPO_ID,...            The following items can be selected only from the specified repositories. All enabled repositories will still be used to satisfy dependencies.
  --from-vendor=VENDOR,...           The following items can be selected only from the specified vendors. The vendor is ignored or vendor change policies (if allow_vendor_change=0) will still be used for items that satisfy dependencies.
  --downloadonly                     Only download packages for a transaction
  --offline                          Store the transaction to be performed offline
  --store=STORED_TRANSACTION_PATH    Store the current transaction in a directory at the specified path instead of running it.
Arguments:
  package-spec-NPFB                  List of packages to downgrade
```

## `dnf reinstall`

<https://dnf.readthedocs.io/en/latest/command_ref.html#reinstall-command>

### `dnf reinstall --help`

```
Usage:
  dnf5 [GLOBAL OPTIONS] reinstall [OPTIONS] [ARGUMENTS]

Options:
  --allowerasing                     Allow removing of installed packages to resolve problems
  --skip-broken                      Allow resolving of depsolve problems by skipping packages
  --skip-unavailable                 Allow skipping unavailable packages
  --allow-downgrade                  Allow downgrade of dependencies for resolve of requested operation
  --no-allow-downgrade               Disable downgrade of dependencies for resolve of requested operation
  --installed-from-repo=REPO_ID,...  Filters installed packages by the ID of the repository they were installed from.
  --from-repo=REPO_ID,...            The following items can be selected only from the specified repositories. All enabled repositories will still be used to satisfy dependencies.
  --from-vendor=VENDOR,...           The following items can be selected only from the specified vendors. The vendor is ignored or vendor change policies (if allow_vendor_change=0) will still be used for items that satisfy dependencies.
  --downloadonly                     Only download packages for a transaction
  --offline                          Store the transaction to be performed offline
  --store=STORED_TRANSACTION_PATH    Store the current transaction in a directory at the specified path instead of running it.
Arguments:
  package-spec-NPFB                  List of packages to reinstall
```


## `dnf check-upgrade` / `dnf check-update`

- <https://github.com/rpm-software-management/dnf5/blob/main/doc/commands/check-upgrade.8.rst>
- <https://dnf.readthedocs.io/en/latest/command_ref.html#check-update-command>

Ignore exit status 100, as that just means there are updates available:

> DNF exit code will be 100 when there are updates available and a list of the updates will be printed, 0 if not and 1 if an error occurs. If `--changelogs` option is specified, also changelog delta of packages about to be updated is printed.

### `dnf check-upgrade --help`

```
Usage:
  dnf5 [GLOBAL OPTIONS] check-upgrade [OPTIONS] [ARGUMENTS]

Options:
  --minimal                                    Reports the lowest versions of packages that fix advisories of type bugfix, enhancement, security, or newpackage. In case that any option limiting advisories is used it reports the lowest versions of packages that fix advisories matching selected advisory properties
  --changelogs                                 Show changelogs before update.
  --advisories=ADVISORY_NAME,...               Include content contained in advisories with specified name. List option.
  --advisory-severities=ADVISORY_SEVERITY,...  Include content contained in advisories with specified severity. List option. Can be "critical", "important", "moderate", "low", "none".
  --bzs=BUGZILLA_ID,...                        Include content contained in advisories that fix a Bugzilla ID, Eg. 123123. List option.
  --cves=CVE_ID,...                            Include content contained in advisories that fix a CVE (Common Vulnerabilities and Exposures) ID, Eg. CVE-2201-0123. List option.
  --security                                   Include content contained in security advisories.
  --bugfix                                     Include content contained in bugfix advisories.
  --enhancement                                Include content contained in enhancement advisories.
  --newpackage                                 Include content contained in newpackage advisories.
  --json                                       Request json output format
Arguments:
  package-spec-N>                              List of package-spec-N to check for upgrades
```

### `dnf check-update`

```
Updating and loading repositories:
 Fedora 44 - x86_64 - Updates                                                                                                                                                                                                                                     100% |  12.0 KiB/s |  15.1 KiB |  00m01s
Repositories loaded.
Upgrades (available for reinstall, available for upgrade)
c-ares.x86_64                     1.34.8-1.fc44 updates
javascriptcoregtk4.1.x86_64       2.52.5-1.fc44 updates
javascriptcoregtk4.1-devel.x86_64 2.52.5-1.fc44 updates
javascriptcoregtk6.0.x86_64       2.52.5-1.fc44 updates
kf6-filesystem.x86_64             6.28.0-1.fc44 updates
kf6-karchive.x86_64               6.28.0-1.fc44 updates
kf6-kimageformats.x86_64          6.28.0-1.fc44 updates
p11-kit.x86_64                    0.26.4-1.fc44 updates
p11-kit-server.x86_64             0.26.4-1.fc44 updates
p11-kit-trust.x86_64              0.26.4-1.fc44 updates
python3-idna.noarch               3.18-1.fc44   updates
webkit2gtk4.1.x86_64              2.52.5-1.fc44 updates
webkit2gtk4.1-devel.x86_64        2.52.5-1.fc44 updates
webkitgtk6.0.x86_64               2.52.5-1.fc44 updates
```

## `dnf autoremove`

<https://dnf.readthedocs.io/en/latest/command_ref.html#autoremove-command>

### `dnf autoremove --help`

```
Usage:
  dnf5 [GLOBAL OPTIONS] autoremove [OPTIONS]

Options:
  --offline                        Store the transaction to be performed offline
  --store=STORED_TRANSACTION_PATH  Store the current transaction in a directory at the specified path instead of running it.
```

## `dnf repoquery`

<https://dnf.readthedocs.io/en/latest/command_ref.html#repoquery-command>

### `dnf repoquery --help`

```
Usage:
  dnf5 [GLOBAL OPTIONS] repoquery [OPTIONS] [ARGUMENTS]
Formatting:
  -i, --info                                   Show detailed information about the packages.
  --querytags                                  Display available tags for --queryformat.
  --queryformat=QUERYFORMAT                    Display format for packages. Default is "%{full_nevra}".
  --changelogs                                 Display package changelogs.
  --files                                      Like --queryformat="%{files}" but deduplicated and sorted.
  --sourcerpm                                  Like --queryformat="%{sourcerpm}" but deduplicated and sorted.
  --location                                   Like --queryformat="%{location}" but deduplicated and sorted.
  --conflicts                                  Like --queryformat="%{conflicts}" but deduplicated and sorted.
  --depends                                    Like --queryformat="%{depends}" but deduplicated and sorted.
  --enhances                                   Like --queryformat="%{enhances}" but deduplicated and sorted.
  --obsoletes                                  Like --queryformat="%{obsoletes}" but deduplicated and sorted.
  --provides                                   Like --queryformat="%{provides}" but deduplicated and sorted.
  --recommends                                 Like --queryformat="%{recommends}" but deduplicated and sorted.
  --requires                                   Like --queryformat="%{requires}" but deduplicated and sorted.
  --requires-pre                               Like --queryformat="%{requires_pre}" but deduplicated and sorted.
  --suggests                                   Like --queryformat="%{suggests}" but deduplicated and sorted.
  --supplements                                Like --queryformat="%{supplements}" but deduplicated and sorted.
  --qf=QUERYFORMAT                             Alias for '--queryformat'
  -l, --list                                   Alias for '--files'
Options:
  --available                                  Query available packages (default).
  --installed                                  Query installed packages.
  --installed-from-repo=REPO_ID,...            Filters installed packages by the ID of the repository they were installed from.
  --leaves                                     Limit to groups of installed packages not required by other installed packages.
  --userinstalled                              Limit to packages that are not installed as dependencies or weak dependencies.
  --duplicates                                 Limit to installed duplicate packages (i.e. more package versions for  the  same  name and architecture). Installonly packages are excluded from this set.
  --unneeded                                   Limit to unneeded installed packages (i.e. packages that were installed as dependencies but are no longer needed).
  --installonly                                Limit to installed installonly packages.
  --extras                                     Limit to installed packages that are not present in any available repository.
  --upgrades                                   Limit to available packages that provide an upgrade for some already installed package.
  --advisories=ADVISORY_NAME,...               Include content contained in advisories with specified name. List option.
  --advisory-severities=ADVISORY_SEVERITY,...  Include content contained in advisories with specified severity. List option. Can be "critical", "important", "moderate", "low", "none".
  --bzs=BUGZILLA_ID,...                        Include content contained in advisories that fix a Bugzilla ID, Eg. 123123. List option.
  --cves=CVE_ID,...                            Include content contained in advisories that fix a CVE (Common Vulnerabilities and Exposures) ID, Eg. CVE-2201-0123. List option.
  --security                                   Include content contained in security advisories.
  --bugfix                                     Include content contained in bugfix advisories.
  --enhancement                                Include content contained in enhancement advisories.
  --newpackage                                 Include content contained in newpackage advisories.
  --latest-limit=N                             Limit to N latest packages for a given name.arch (or all except N latest if N is negative).
  --whatdepends=CAPABILITY,...                 Limit to packages that require, enhance, recommend, suggest or supplement any of <capabilities>.
  --whatconflicts=CAPABILITY,...               Limit to packages that conflict with any of <capabilities>.
  --whatenhances=CAPABILITY,...                Limit to packages that enhance any of <capabilities>. Use --whatdepends if you want to list all depending packages.
  --whatobsoletes=CAPABILITY,...               Limit to packages that obsolete any of <capabilities>.
  --whatprovides=CAPABILITY,...                Limit to packages that provide any of <capabilities>.
  --whatrecommends=CAPABILITY,...              Limit to packages that recommend any of <capabilities>. Use --whatdepends if you want to list all depending packages.
  --whatrequires=CAPABILITY,...                Limit to packages that require any of <capabilities>. Use --whatdepends if you want to list all depending packages.
  --whatsupplements=CAPABILITY,...             Limit to packages that supplement any of <capabilities>. Use --whatdepends if you want to list all depending packages.
  --whatsuggests=CAPABILITY,...                Limit to packages that suggest any of <capabilities>. Use --whatdepends if you want to list all depending packages.
  --arch=ARCH,...                              Limit to packages of these architectures.
  -f FILE,..., --file=FILE,...                 Limit to packages that own these files.
  --exactdeps                                  Limit to packages that require <capability> specified by --whatrequires. This option is stackable with --whatrequires or --whatdepends only.
  --recent                                     Limit to only recently changed packages.
  --srpm                                       After filtering is finished use packages' corresponding source RPMs for output (enables source repositories).
  --disable-modular-filtering                  Include packages of inactive module streams.
  --providers-of=PACKAGE_ATTRIBUTE             After filtering is finished get selected attribute of packages and output packages that provide it. Supports: conflicts, depends, enhances, obsoletes, provides, recommends, requires, requires_pre, suggests, supplements.
  --recursive                                  Used with --whatrequires or --providers-of=requires options to query the packages recursively.
  --advisory=ADVISORY_NAME,...                 Alias for '--advisories'
  --bz=BUGZILLA_ID,...                         Alias for '--bzs'
  --cve=CVE_ID,...                             Alias for '--cves'

Arguments:
  package-spec-NIF                             List of package-spec-NIF to match
```

## `dnf search`

<https://dnf.readthedocs.io/en/latest/command_ref.html#search-command>

### `dnf search --help`

```
Usage:
  dnf5 [GLOBAL OPTIONS] search [OPTIONS] [ARGUMENTS]

Options:
  --all                         Search also package description and URL.
  --showduplicates              Show all versions of the packages, not only the latest ones.
  --name                        Limit the search to the Name field.
  --summary                     Limit the search to the Summary field.
Arguments:
  patterns                      Patterns
```

## `dnf list`

### `dnf list --help`

```
Usage:
  dnf5 [GLOBAL OPTIONS] list [OPTIONS] [ARGUMENTS]

Options:
  --showduplicates                   Show all versions of the packages, not only the latest ones.
  --installed-from-repo=REPO_ID,...  Filters installed packages by the ID of the repository they were installed from.
  --installed                        List installed packages.
  --available                        List available packages.
  --extras                           List extras, that is packages installed on the system that are not available in any known repository.
  --obsoletes                        List packages installed on the system that are obsoleted by packages in any known repository.
  --recent                           List packages recently added into the repositories.
  --upgrades                         List upgrades available for the installed packages.
  --autoremove                       List packages which will be removed by the 'dnf autoremove' command.
  --json                             Request json output format
  --updates                          Alias for '--upgrades'

Arguments:
  package-spec-NI                    List of package-spec-NI to match (case insensitively)
```

## `dnf info`

<https://dnf.readthedocs.io/en/latest/command_ref.html#info-command>

### `dnf info --help`

```
Usage:
  dnf5 [GLOBAL OPTIONS] info [OPTIONS] [ARGUMENTS]

Options:
  --showduplicates                   Show all versions of the packages, not only the latest ones.
  --installed-from-repo=REPO_ID,...  Filters installed packages by the ID of the repository they were installed from.
  --installed                        List installed packages.
  --available                        List available packages.
  --extras                           List extras, that is packages installed on the system that are not available in any known repository.
  --obsoletes                        List packages installed on the system that are obsoleted by packages in any known repository.
  --recent                           List packages recently added into the repositories.
  --upgrades                         List upgrades available for the installed packages.
  --autoremove                       List packages which will be removed by the 'dnf autoremove' command.
  --json                             Request json output format
  --updates                          Alias for '--upgrades'

Arguments:
  package-spec-NI                    List of package-spec-NI to match (case insensitively)
```

## `dnf repo`

<https://dnf.readthedocs.io/en/latest/command_ref.html#repo-command>

### `dnf repo --help`

```
Usage:
  dnf5 [GLOBAL OPTIONS] repo <COMMAND> ...
Query Commands:
  list                          List repositories
  info                          Print details about repositories
```

### `dnf repo list --help`

```
Usage:
  dnf5 [GLOBAL OPTIONS] repo list [OPTIONS] [ARGUMENTS]

Options:
  --all                         Show all repositories.
  --enabled                     Show enabled repositories (default).
  --disabled                    Show disabled repositories.
  --json                        Request json output format
Arguments:
  repo-spec                     Pattern matching repo IDs.
```

### `dnf repo info --help`

```
Usage:
  dnf5 [GLOBAL OPTIONS] repo info [OPTIONS] [ARGUMENTS]

Options:
  --all                         Show all repositories.
  --enabled                     Show enabled repositories (default).
  --disabled                    Show disabled repositories.
  --json                        Request json output format
Arguments:
  repo-spec                     Pattern matching repo IDs.
```

## `dnf system-upgrade`

- <https://github.com/rpm-software-management/dnf5/blob/main/doc/commands/system-upgrade.8.rst>
- <https://linuxcommandlibrary.com/man/dnf-system-upgrade>

### `dnf system-upgrade --help`

```
Usage:
  dnf5 [GLOBAL OPTIONS] system-upgrade <COMMAND> ...
Commands:
  clean                         Remove any stored offline transaction and delete cached package files.
  log                           Show logs from past offline transactions
  reboot                        Prepare the system to perform the offline transaction and reboot to start the transaction.
  status                        Show status of the current offline transaction
  download                      Download everything needed to upgrade to a new release
```

### `dnf system-upgrade clean --help`

```
Usage:
  dnf5 [GLOBAL OPTIONS] system-upgrade clean
```

### `dnf system-upgrade log --help`

```
Usage:
  dnf5 [GLOBAL OPTIONS] system-upgrade log [OPTIONS]

Options:
  --number=VALUE                Which log to show. Run without any arguments to get a list of available logs.
```

### `dnf system-upgrade reboot --help`

```
Usage:
  dnf5 [GLOBAL OPTIONS] system-upgrade reboot [OPTIONS]

Options:
  --poweroff                    Power off the system after the operation is complete
```

### `dnf system-upgrade status --help`

```
Usage:
  dnf5 [GLOBAL OPTIONS] system-upgrade status
```

### `dnf system-upgrade download --help`

```
Usage:
  dnf5 [GLOBAL OPTIONS] system-upgrade download [OPTIONS]

Options:
  --no-downgrade                Do not install packages from the new release if they are older than what is currently installed
  --allowerasing                Allow removing of installed packages to resolve problems
```


## `dnf config-manager`

- <https://man.archlinux.org/man/extra/dnf5/dnf5-config-manager.8.en>
- <https://github.com/rpm-software-management/dnf5/blob/main/doc/dnf5_plugins/config-manager.8.rst>

### `dnf config-manager --help`

```
Usage:
  dnf5 [GLOBAL OPTIONS] config-manager <COMMAND> ...

Description:
  Manage main and repositories configuration, variables and add new repositories.

Commands:
  addrepo                       Add repositories from the specified configuration file or define a new repository using user options
  setopt                        Set configuration and repositories options
  unsetopt                      Unset/remove configuration and repositories options
  setvar                        Set variables
  unsetvar                      Unset/remove variables
  enable                        Enables repositories
  disable                       Disables repositories
```

### `dnf config-manager addrepo --help`

```
Usage:
  dnf5 [GLOBAL OPTIONS] config-manager addrepo [OPTIONS]

Description:
  Add repositories from the specified configuration file or define a new repository using user options.

Options:
  --from-repofile=REPO_CONFIGURATION_FILE_URL  Download repository configuration file, test it and put it in reposdir
  --id=REPO_ID                                 Set id for newly created repository
  --set=REPO_OPTION=VALUE                      Set option in newly created repository
  --add-or-replace                             Allow adding or replacing a repository in the existing configuration file
  --create-missing-dir                         Allow creation of missing directories
  --overwrite                                  Allow overwriting of existing repository configuration file
  --save-filename=FILENAME                     Set the name of the configuration file of the added repository. The ".repo" extension is added if it is missing.
```

## `dnf clean`

<https://dnf.readthedocs.io/en/latest/command_ref.html#clean-command>

### `dnf clean --help`

```
Usage:
  dnf5 [GLOBAL OPTIONS] clean [ARGUMENTS]
Arguments:
  cache_types                   List of cache types to clean up. Supported types: all, packages, metadata, dbcache, expire-cache
```

## `dnf download`

<https://dnf.readthedocs.io/en/latest/command_ref.html#download-command>

### `dnf download --help`

```
Usage:
  dnf5 [GLOBAL OPTIONS] download [OPTIONS] [ARGUMENTS]

Options:
  --arch=ARCH,...                          Limit to packages of given architectures.
  --resolve                                Resolve and download needed dependencies
  --alldeps                                When running with --resolve, download all dependencies (do not exclude already installed ones)
  --from-repo=REPO_ID,...                  The following items can be selected only from the specified repositories. All enabled repositories will still be used to satisfy dependencies.
  --from-vendor=VENDOR,...                 The following items can be selected only from the specified vendors. The vendor is ignored or vendor change policies (if allow_vendor_change=0) will still be used for items that satisfy dependencies.
  --destdir=DESTDIR                        Set directory used for downloading packages to. Default location is to the current working directory.
  --skip-unavailable                       Allow skipping unavailable packages
  --srpm                                   Download the src.rpm instead
  --debuginfo                              Download the -debuginfo package instead
  --debugsource                            Download the -debugsource package instead
  --url                                    Print a URL where the rpms can be downloaded instead of downloading
  --urlprotocol={http|https|ftp|file},...  When running with --url, limit to specific protocols
  --allmirrors                             When running with --url, prints URLs from all available mirrors
  --source                                 Alias for '--srpm'

Arguments:
  package-spec-NPFB                        List of package-spec-NPFB to download
```

## `dnf changelog`

<https://dnf.readthedocs.io/en/latest/command_ref.html#changelog-command>

### `dnf changelog --help`

```
Usage:
  dnf5 [GLOBAL OPTIONS] changelog [OPTIONS] [ARGUMENTS]

Options:
  --since=VALUE                 Show changelog entries since date in the YYYY-MM-DD format
  --count=VALUE                 Limit the number of changelog entries shown per package
  --upgrades                    Show new changelog entries for packages that provide an upgrade for an already installed package
Arguments:
  package-spec-NI               List of package-spec-NI to show changelogs for
```

## `dnf copr`

<https://github.com/rpm-software-management/dnf5/blob/main/doc/dnf5_plugins/copr.8.rst>

### `dnf copr --help`

```
Usage:
  dnf5 [GLOBAL OPTIONS] copr [OPTIONS] <COMMAND> ...
Description:
  Manage Copr repositories (add-ons provided by users/community/third-party)
Commands:
  list                          list Copr repositories
  enable                        download the repository info from a Copr server and install it as a /etc/yum.repos.d/*.repo file
  disable                       disable specified Copr repository (if exists), keep /etc/yum.repos.d/*.repo file - just mark enabled=0
  remove                        remove specified Copr repository from the system (removes the /etc/yum.repos.d/*.repo file)
  debug                         print useful info about the system, useful for debugging
Options:
  --hub=HOSTNAME                Copr hub (the web-UI/API server) hostname
```

## `dnf needs-restarting`

<https://github.com/rpm-software-management/dnf5/blob/main/doc/dnf5_plugins/needs_restarting.8.rst>

### `dnf needs-restarting --help`

```
Usage:
  dnf5 [GLOBAL OPTIONS] needs-restarting [OPTIONS]

Options:
  -s, --services                List systemd services started before their dependencies were updated
  -p, --processes               List processes started before their dependencies were updated
  -e, --exclude-services        Exclude processes managed by systemd services (use with --processes)
  -r, --reboothint              Has no effect, kept for compatibility with DNF 4. "dnf4 needs-restarting -r" provides the same functionality as "dnf5 needs-restarting".
  --json                        Request json output format
```
