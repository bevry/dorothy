# pacman

## container

```
docker run --rm -it archlinux:latest # no arm
docker run --rm -it cachyos/cachyos:latest # no arm
docker run --rm -it manjarolinux/base:latest
pacman-key --init
pacman --noconfirm -S --refresh
```

## man

- <https://archlinux.org/pacman/pacman.8.html>

### global options

```
-b, --dbpath <path>: Specify an alternative database location (the default is /var/lib/pacman). This should not be used unless you know what you are doing. NOTE: If specified, this is an absolute path, and the root path is not automatically prepended.
-r, --root <path>: Specify an alternative installation root (default is /). This should not be used as a way to install software into /usr/local instead of /usr. NOTE: If database path or log file are not specified on either the command line or in pacman.conf(5), their default location will be inside this root path. NOTE: This option is not suitable for performing operations on a mounted guest system. See --sysroot instead.
-v, --verbose: Output paths such as the Root, Conf File, DB Path, Cache Dirs, etc.
--arch <arch>: Specify an alternate architecture.
--cachedir <dir>: Specify an alternative package cache location (the default is /var/cache/pacman/pkg). Multiple cache directories can be specified, and they are tried in the order they are passed to pacman. NOTE: This is an absolute path, and the root path is not automatically prepended. If DownloadUser is set in pacman.conf(5), then the specified user must have permission to access the cache directory.
--color <when>: Specify when to enable coloring. Valid options are always, never, or auto. always forces colors on; never forces colors off; and auto only automatically enables colors when outputting onto a tty.
--config <file>: Specify an alternate configuration file.
--debug: Display debug messages. When reporting bugs, this option is recommended to be used.
--gpgdir <dir>: Specify a directory of files used by GnuPG to verify package signatures (the default is /etc/pacman.d/gnupg). This directory should contain two files: pubring.gpg and trustdb.gpg. pubring.gpg holds the public keys of all packagers. trustdb.gpg contains a so-called trust database, which specifies that the keys are authentic and trusted. NOTE: This is an absolute path, and the root path is not automatically prepended.
--hookdir <dir>: Specify a alternative directory containing hook files (the default is /etc/pacman.d/hooks). Multiple hook directories can be specified with hooks in later directories taking precedence over hooks in earlier directories. NOTE: This is an absolute path, and the root path is not automatically prepended.
--logfile <file>: Specify an alternate log file. This is an absolute path, regardless of the installation root setting.
--noconfirm: Bypass any and all “Are you sure?” messages. It’s not a good idea to do this unless you want to run pacman from a script.
--confirm: Cancels the effects of a previous --noconfirm.
--disable-download-timeout: Disable defaults for low speed limit and timeout on downloads. Use this if you have issues downloading files with proxy and/or security gateway.
--sysroot <dir>: Specify an alternative system root. This path will be prepended to all other configuration directories and any repository servers beginning with file://. Any paths or URLs passed as targets will not be modified. This allows mounted guest systems to be properly operated on.
--disable-sandbox: Completely disables the sandbox applied to the process of downloading files on Linux systems. Equivalent to jointly specifying --disable-sandbox-filesystem and --disable-sandbox-syscalls.
--disable-sandbox-filesystem: Disable the filesystem restrictions part of the sandbox applied to the process downloading files on Linux systems. Useful if experiencing Landlock related failures while downloading files when running a Linux kernel that does not support this feature.
--disable-sandbox-syscalls: Disable the syscall filtering part of the sandbox applied to the process downloading files on Linux systems. Useful if experiencing seccomp related failures while downloading files when running a Linux kernel that does not support this feature.
```

### transaction options, applies to `--sync`, `--remove`, `--upgrade`

```
--noprogressbar: Do not show a progress bar when downloading files. This can be useful for scripts that call pacman and capture the output.
-p, --print: Only print the targets instead of performing the actual operation (sync, remove or upgrade). Use --print-format to specify how targets are displayed. The default format string is "%l", which displays URLs with -S, file names with -U, and pkgname-pkgver with -R.
--print-format <format>: Specify a printf-like format to control the output of the --print operation. The possible attributes are: "%a" for arch, "%b" for builddate, "%d" for description, "%e" for pkgbase, "%f" for filename, "%g" for base64 encoded PGP signature, "%h" for sha256sum, "%m" for md5sum, "%n" for pkgname, "%p" for packager, "%v" for pkgver, "%l" for location, "%r" for repository, "%s" for size, "%C" for checkdepends, "%D" for depends, "%G" for groups, "%H" for conflicts, "%L" for licenses, "%M" for makedepends, "%O" for optional depends, "%P" for provides and "%R" for replaces. Implies --print.
```

### upgrade options, applies to `--sync`, `--upgrade`

```
--needed: Do not reinstall the targets that are already up-to-date.
```


## `pacman --help`

```
usage:  pacman <operation> [...]
operations:
    pacman {-h --help}
    pacman {-V --version}
    pacman {-D --database} <options> <package(s)>
    pacman {-F --files}    [options] [file(s)]
    pacman {-Q --query}    [options] [package(s)]
    pacman {-R --remove}   [options] <package(s)>
    pacman {-S --sync}     [options] [package(s)]
    pacman {-T --deptest}  [options] [package(s)]
    pacman {-U --upgrade}  [options] <file(s)>

use 'pacman {-h --help}' with an operation for available options
```

## `pacman --database --help`

```
usage:  pacman {-D --database} <options> <package(s)>
options:
  -b, --dbpath <path>  set an alternate database location
  -k, --check          test local database for validity (-kk for sync databases)
  -q, --quiet          suppress output of success messages
  -r, --root <path>    set an alternate installation root
  -v, --verbose        be verbose
      --arch <arch>    set an alternate architecture
      --asdeps         mark packages as non-explicitly installed
      --asexplicit     mark packages as explicitly installed
      --cachedir <dir> set an alternate package cache location
      --color <when>   colorize the output
      --config <path>  set an alternate configuration file
      --confirm        always ask for confirmation
      --debug          display debug messages
      --disable-download-timeout
                       use relaxed timeouts for download
      --gpgdir <path>  set an alternate home directory for GnuPG
      --hookdir <dir>  set an alternate hook location
      --logfile <path> set an alternate log file
      --noconfirm      do not ask for any confirmation
      --sysroot        operate on a mounted guest system (root-only)
sh-5.2#
```

## `pacman --files --help`

```
usage:  pacman {-F --files} [options] [file(s)]
options:
  -b, --dbpath <path>  set an alternate database location
  -l, --list           list the files owned by the queried package
  -q, --quiet          show less information for query and search
  -r, --root <path>    set an alternate installation root
  -v, --verbose        be verbose
  -x, --regex          enable searching using regular expressions
  -y, --refresh        download fresh package databases from the server
                       (-yy to force a refresh even if up to date)
      --arch <arch>    set an alternate architecture
      --cachedir <dir> set an alternate package cache location
      --color <when>   colorize the output
      --config <path>  set an alternate configuration file
      --confirm        always ask for confirmation
      --debug          display debug messages
      --disable-download-timeout
                       use relaxed timeouts for download
      --gpgdir <path>  set an alternate home directory for GnuPG
      --hookdir <dir>  set an alternate hook location
      --logfile <path> set an alternate log file
      --machinereadable
                       produce machine-readable output
      --noconfirm      do not ask for any confirmation
      --sysroot        operate on a mounted guest system (root-only)
```

## `pacman --query --help`

```
usage:  pacman {-Q --query} [options] [package(s)]
options:
  -b, --dbpath <path>  set an alternate database location
  -c, --changelog      view the changelog of a package
  -d, --deps           list packages installed as dependencies [filter]
  -e, --explicit       list packages explicitly installed [filter]
  -g, --groups         view all members of a package group
  -i, --info           view package information (-ii for backup files)
  -k, --check          check that package files exist (-kk for file properties)
  -l, --list           list the files owned by the queried package
  -m, --foreign        list installed packages not found in sync db(s) [filter]
  -n, --native         list installed packages only found in sync db(s) [filter]
  -o, --owns <file>    query the package that owns <file>
  -p, --file <package> query a package file instead of the database
  -q, --quiet          show less information for query and search
  -r, --root <path>    set an alternate installation root
  -s, --search <regex> search locally-installed packages for matching strings
  -t, --unrequired     list packages not (optionally) required by any
                       package (-tt to ignore optdepends) [filter]
  -u, --upgrades       list outdated packages [filter]
  -v, --verbose        be verbose
      --arch <arch>    set an alternate architecture
      --cachedir <dir> set an alternate package cache location
      --color <when>   colorize the output
      --config <path>  set an alternate configuration file
      --confirm        always ask for confirmation
      --debug          display debug messages
      --disable-download-timeout
                       use relaxed timeouts for download
      --gpgdir <path>  set an alternate home directory for GnuPG
      --hookdir <dir>  set an alternate hook location
      --logfile <path> set an alternate log file
      --noconfirm      do not ask for any confirmation
      --sysroot        operate on a mounted guest system (root-only)
```

from man:

```
-c, --changelog: View the ChangeLog of a package if it exists.
-d, --deps: list packages installed as dependencies [filter]
-e, --explicit: list packages explicitly installed [filter]
-i, --info: Display information on a given package. The -p option can be used if querying a package file instead of the local database. Passing two --info or -i flags will also display the list of backup files and their modification states.
-k, --check: Check that all files owned by the given package(s) are present on the system. If packages are not specified or filter flags are not provided, check all installed packages. Specifying this option twice will perform more detailed file checking (including permissions, file sizes, and modification times) for packages that contain the needed mtree file.
-q, --quiet: Show less information for certain query operations. This is useful when pacman’s output is processed in a script. Search will only show package names and not version, group, and description information; owns will only show package names instead of "file is owned by pkg" messages; group will only show package names and omit group names; list will only show files and omit package names; check will only show pairs of package names and missing files; a bare query will only show package names rather than names and versions.
-s, --search <regexp>: Search each locally-installed package for names or descriptions that match regexp. When including multiple search terms, only packages with descriptions matching ALL of those terms are returned.
-u, --upgrades: Restrict or filter output to packages that are out-of-date on the local system. Only package versions are used to find outdated packages; replacements are not checked here. This option works best if the sync database is refreshed using -Sy.
```


## `pacman --remove --help`

```
usage:  pacman {-R --remove} [options] <package(s)>
options:
  -b, --dbpath <path>  set an alternate database location
  -c, --cascade        remove packages and all packages that depend on them
  -d, --nodeps         skip dependency version checks (-dd to skip all checks)
  -n, --nosave         remove configuration files
  -p, --print          print the targets instead of performing the operation
  -r, --root <path>    set an alternate installation root
  -s, --recursive      remove unnecessary dependencies
                       (-ss includes explicitly installed dependencies)
  -u, --unneeded       remove unneeded packages
  -v, --verbose        be verbose
      --arch <arch>    set an alternate architecture
      --assume-installed <package=version>
                       add a virtual package to satisfy dependencies
      --cachedir <dir> set an alternate package cache location
      --color <when>   colorize the output
      --config <path>  set an alternate configuration file
      --confirm        always ask for confirmation
      --dbonly         only modify database entries, not package files
      --debug          display debug messages
      --disable-download-timeout
                       use relaxed timeouts for download
      --gpgdir <path>  set an alternate home directory for GnuPG
      --hookdir <dir>  set an alternate hook location
      --logfile <path> set an alternate log file
      --noconfirm      do not ask for any confirmation
      --noprogressbar  do not show a progress bar when downloading files
      --noscriptlet    do not execute the install scriptlet if one exists
      --print-format <string>
                       specify how the targets should be printed
      --sysroot        operate on a mounted guest system (root-only)
```

from man:

```
-s, --recursive: Remove each target specified including all of their dependencies, provided that (A) they are not required by other packages; and (B) they were not explicitly installed by the user. This operation is recursive and analogous to a backwards --sync operation, and it helps keep a clean system without orphans. If you want to omit condition (B), pass this option twice.
```

## `pacman --sync --help`

```
usage:  pacman {-S --sync} [options] [package(s)]
options:
  -b, --dbpath <path>  set an alternate database location
  -c, --clean          remove old packages from cache directory (-cc for all)
  -d, --nodeps         skip dependency version checks (-dd to skip all checks)
  -g, --groups         view all members of a package group
                       (-gg to view all groups and members)
  -i, --info           view package information (-ii for extended information)
  -l, --list <repo>    view a list of packages in a repo
  -p, --print          print the targets instead of performing the operation
  -q, --quiet          show less information for query and search
  -r, --root <path>    set an alternate installation root
  -s, --search <regex> search remote repositories for matching strings
  -u, --sysupgrade     upgrade installed packages (-uu enables downgrades)
  -v, --verbose        be verbose
  -w, --downloadonly   download packages but do not install/upgrade anything
  -y, --refresh        download fresh package databases from the server
                       (-yy to force a refresh even if up to date)
      --arch <arch>    set an alternate architecture
      --asdeps         install packages as non-explicitly installed
      --asexplicit     install packages as explicitly installed
      --assume-installed <package=version>
                       add a virtual package to satisfy dependencies
      --cachedir <dir> set an alternate package cache location
      --color <when>   colorize the output
      --config <path>  set an alternate configuration file
      --confirm        always ask for confirmation
      --dbonly         only modify database entries, not package files
      --debug          display debug messages
      --disable-download-timeout
                       use relaxed timeouts for download
      --gpgdir <path>  set an alternate home directory for GnuPG
      --hookdir <dir>  set an alternate hook location
      --ignore <pkg>   ignore a package upgrade (can be used more than once)
      --ignoregroup <grp>
                       ignore a group upgrade (can be used more than once)
      --logfile <path> set an alternate log file
      --needed         do not reinstall up to date packages
      --noconfirm      do not ask for any confirmation
      --noprogressbar  do not show a progress bar when downloading files
      --noscriptlet    do not execute the install scriptlet if one exists
      --overwrite <glob>
                       overwrite conflicting files (can be used more than once)
      --print-format <string>
                       specify how the targets should be printed
      --sysroot        operate on a mounted guest system (root-only)
```

from man:

```
-c, --clean: Remove packages that are no longer installed from the cache as well as currently unused sync databases to free up disk space.
-q, --quiet: Show less information for certain sync operations.
-s, --search <regexp>: This will search each package in the sync databases for names or descriptions that match regexp. When you include multiple search terms, only packages with descriptions matching ALL of those terms will be returned.
-u, --sysupgrade: Upgrades all packages that are out-of-date. Each currently-installed package will be examined and upgraded if a newer package exists. A report of all packages to upgrade will be presented, and the operation will not proceed without user confirmation. Dependencies are automatically resolved at this level and will be installed/upgraded if necessary. Pass this option twice to enable package downgrades; in this case, pacman will select sync packages whose versions do not match with the local versions. This can be useful when the user switches from a testing repository to a stable one. Additional targets can also be specified manually, so that -Su foo will do a system upgrade and install/upgrade the "foo" package in the same operation.
-y, --refresh: Download a fresh copy of the master package databases (repo.db) from the server(s) defined in pacman.conf(5). This should typically be used each time you use --sysupgrade or -u. Passing two --refresh or -y flags will force a refresh of all package databases, even if they appear to be up-to-date.
```


## `pacman --deptest --help`

```
usage:  pacman {-T --deptest} [options] [package(s)]
options:
  -b, --dbpath <path>  set an alternate database location
  -r, --root <path>    set an alternate installation root
  -v, --verbose        be verbose
      --arch <arch>    set an alternate architecture
      --cachedir <dir> set an alternate package cache location
      --color <when>   colorize the output
      --config <path>  set an alternate configuration file
      --confirm        always ask for confirmation
      --debug          display debug messages
      --disable-download-timeout
                       use relaxed timeouts for download
      --gpgdir <path>  set an alternate home directory for GnuPG
      --hookdir <dir>  set an alternate hook location
      --logfile <path> set an alternate log file
      --noconfirm      do not ask for any confirmation
      --sysroot        operate on a mounted guest system (root-only)
```

## `pacman --upgrade --help`

```
usage:  pacman {-U --upgrade} [options] <file(s)>
options:
  -b, --dbpath <path>  set an alternate database location
  -d, --nodeps         skip dependency version checks (-dd to skip all checks)
  -p, --print          print the targets instead of performing the operation
  -r, --root <path>    set an alternate installation root
  -v, --verbose        be verbose
  -w, --downloadonly   download packages but do not install/upgrade anything
      --arch <arch>    set an alternate architecture
      --asdeps         install packages as non-explicitly installed
      --asexplicit     install packages as explicitly installed
      --assume-installed <package=version>
                       add a virtual package to satisfy dependencies
      --cachedir <dir> set an alternate package cache location
      --color <when>   colorize the output
      --config <path>  set an alternate configuration file
      --confirm        always ask for confirmation
      --dbonly         only modify database entries, not package files
      --debug          display debug messages
      --disable-download-timeout
                       use relaxed timeouts for download
      --gpgdir <path>  set an alternate home directory for GnuPG
      --hookdir <dir>  set an alternate hook location
      --ignore <pkg>   ignore a package upgrade (can be used more than once)
      --ignoregroup <grp>
                       ignore a group upgrade (can be used more than once)
      --logfile <path> set an alternate log file
      --needed         do not reinstall up to date packages
      --noconfirm      do not ask for any confirmation
      --noprogressbar  do not show a progress bar when downloading files
      --noscriptlet    do not execute the install scriptlet if one exists
      --overwrite <glob>
                       overwrite conflicting files (can be used more than once)
      --print-format <string>
                       specify how the targets should be printed
      --sysroot        operate on a mounted guest system (root-only)
```
