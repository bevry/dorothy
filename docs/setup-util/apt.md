# apt

## container

```
docker run --rm -it ubuntu:latest
docker run --rm -it debian:latest
docker run --rm -it devuan/devuan:latest
docker run --rm -it kalilinux/kali-rolling:latest
apt update
```

## resources

- <https://wiki.debian.org/Apt>
- <https://manpages.ubuntu.com/manpages/xenial/man8/apt.8.html>
- <https://linuxcommandlibrary.com/man/apt-list>

## notes

- supports installing/uninstalling remote `deb` packages
- supports installing/uninstalling downloaded `.deb` files
- successor to aptitude

## `apt-get` vs `apt`

Use `apt-get`, as `apt` produces this warning on `Ubuntu 20.04.3 LTS`:
```
WARNING: apt does not have a stable CLI interface. Use with caution in scripts.
```

And the manpage states:
```
APT explicitly warns that apt does not have a stable CLI; output formatting may change between releases. Use dpkg-query -l or apt-cache in scripts. Run apt update beforehand if recent repository changes should be visible. Pattern arguments are interpreted by the shell, so quote wildcards to prevent local file expansion.
```

## `apt`

### `apt list`

`apt list --installed sed zzuf` result:
```
root@f241ea67b453:/# PAGER= apt list --installed sed zzuf; echo "[$?]"
sed/resolute,now 4.9-2build3 amd64 [installed,upgradable to: 4.9-2ubuntu1]
[0]
```

### `apt show`

`apt show zlib1g` result:
```
Package: zlib1g
Version: 1:1.3.dfsg+really1.3.1-1ubuntu3
Priority: required
Section: libs
Source: zlib
Origin: Ubuntu
Maintainer: Ubuntu Developers <ubuntu-devel-discuss@lists.ubuntu.com>
Original-Maintainer: Mark Brown <broonie@debian.org>
Bugs: https://bugs.launchpad.net/ubuntu/+filebug
Installed-Size: 175 kB
Provides: libz1
Depends: libc6 (>= 2.14)
Conflicts: zlib1 (<= 1:1.0.4-7)
Breaks: libxml2 (<< 2.7.6.dfsg-2), texlive-binaries (<< 2023.20230311.66589-8)
Homepage: http://zlib.net/
Task: cloud-minimal, minimal, server-minimal
Download-Size: 63.9 kB
APT-Manual-Installed: yes
APT-Sources: http://archive.ubuntu.com/ubuntu resolute/main amd64 Packages
Description: compression library - runtime
```

## `apt-get`

<https://manpages.ubuntu.com/manpages/xenial/man8/apt-get.8.html>

`apt-get` options:
```
--install-suggests: Consider suggested packages as a dependency for installing. Configuration Item: APT::Install-Suggests.
-f, --fix-broken: Fix; attempt to correct a system with broken dependencies in place. This option, when used with install/remove, can omit any packages to permit APT to deduce a likely solution. If packages are specified, these have to completely correct the problem. The option is sometimes necessary when running APT for the first time; APT itself does not allow broken package dependencies to exist on a system. It is possible that a system's dependency structure can be so corrupt as to require manual intervention (which usually means using dpkg --remove to eliminate some of the offending packages). Use of this option together with -m may produce an error in some situations. Configuration Item: APT::Get::Fix-Broken.
-m, --ignore-missing, --fix-missing: Ignore missing packages; if packages cannot be retrieved or fail the integrity check after retrieval (corrupted package files), hold back those packages and handle the result. Use of this option together with -f may produce an error in some situations. If a package is selected for installation (particularly if it is mentioned on the command line) and it could not be downloaded then it will be silently held back. Configuration Item: APT::Get::Fix-Missing.
-q, --quiet: Quiet; produces output suitable for logging, omitting progress indicators. More q's will produce more quiet up to a maximum of 2. You can also use -q=# to set the quiet level, overriding the configuration file. Note that quiet level 2 implies -y; you should never use -qq without a no-action modifier such as -d, --print-uris or -s as APT may decide to do something you did not expect. Configuration Item: quiet.
-y, --yes, --assume-yes: Automatic yes to prompts; assume "yes" as answer to all prompts and run non-interactively. If an undesirable situation, such as changing a held package, trying to install a unauthenticated package or removing an essential package occurs then apt-get will abort. Configuration Item: APT::Get::Assume-Yes.
-u, --show-upgraded: Show upgraded packages; print out a list of all packages that are to be upgraded. Configuration Item: APT::Get::Show-Upgraded.
--no-upgrade: Do not upgrade packages; when used in conjunction with install, no-upgrade will prevent packages on the command line from being upgraded if they are already installed. Configuration Item: APT::Get::Upgrade.
--only-upgrade: Do not install new packages; when used in conjunction with install, only-upgrade will install upgrades for already installed packages only and ignore requests to install new packages. Configuration Item: APT::Get::Only-Upgrade.
--allow-downgrades: This is a dangerous option that will cause apt to continue without prompting if it is doing downgrades. It should not be used except in very special situations. Using it can potentially destroy your system! Configuration Item: APT::Get::allow-downgrades. Introduced in APT 1.1.
--purge: Use purge instead of remove for anything that would be removed. An asterisk ("*") will be displayed next to packages which are scheduled to be purged. remove --purge is equivalent to the purge command. Configuration Item: APT::Get::Purge.
--reinstall: Re-install packages that are already installed and at the newest version. Configuration Item: APT::Get::ReInstall.
--trivial-only: Only perform operations that are 'trivial'. Logically this can be considered related to --assume-yes; where --assume-yes will answer yes to any prompt, --trivial-only will answer no. Configuration Item: APT::Get::Trivial-Only.
--auto-remove, --autoremove: If the command is either install or remove, then this option acts like running the autoremove command, removing unused dependency packages. Configuration Item: APT::Get::AutomaticRemove.
--show-progress: Show user friendly progress information in the terminal window when packages are installed, upgraded or removed. For a machine parsable version of this data see README.progress-reporting in the apt doc directory. Configuration Item: Dpkg::Progress and Dpkg::Progress-Fancy.
```
