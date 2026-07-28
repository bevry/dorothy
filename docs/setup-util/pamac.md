# pamac

## container

```
docker run --rm -it manjarolinux/base:latest
pacman-key --init
pacman --noconfirm -S --refresh --needed pamac-gtk
```

## resources

- <https://itsfoss.com/best-aur-helpers/>
- <https://linuxcommandlibrary.com/man/pamac>

## notes

- sudo with `pamac` avoids GUI sudo prompt

## `pamac --help`

```
Available actions:
  pamac --version     
  pamac --help, -h     [action]
  pamac search         [options] <package(s)>
  pamac list           [options] <package(s)>
  pamac info           [options] <package(s)>
  pamac install        [options] <package(s)>
  pamac reinstall      [options] <package(s)>
  pamac remove         [options] [package(s)]
  pamac checkupdates   [options]
  pamac update,upgrade [options]
  pamac clone          [options] <package(s)>
  pamac build          [options] [package(s)]
  pamac clean          [options]
```

## `pamac search`

empty results still results in exit status `0`

### `pamac search --help`

```
Search for packages or files, multiple search terms can be specified

pamac search [options] <package(s)/file(s)>

options:
  --installed, -i : only search for installed packages
  --repos, -r     : only search for packages in repositories
  --aur, -a       : also search in AUR
  --no-aur        : do not search in AUR
  --files, -f     : search for packages which own the given filenames (filenames can be partial)
  --quiet, -q     : only print names
```

### `pamac search --quiet bash`

```
bash
bash-completion
bash-language-server
bash-preexec
bashbrew
bashburn
bashrun
bashtop
argbash
checkbashisms
morc_menu
nvm
powerline
python-click-completion
rofi-pass
texlive-latexextra
```

### `pamac search bash`

```
texlive-latexextra  2023.66594-20                                                                                                                                                     extra
    TeX Live - LaTeX additional packages
rofi-pass  2.0.2-2                                                                                                                                                                    extra
    bash script to handle pass storages in a convenient way
python-click-completion  0.5.2-7                                                                                                                                                      extra
    Add or enhance bash, fish, zsh and powershell completion in Click
powerline  2.8.3-3                                                                                                                                                                    extra
    Statusline plugin for vim, and provides statuslines and prompts for several other applications, including zsh, bash, tmux, IPython, Awesome, i3 and Qtile
nvm  0.39.7-1                                                                                                                                                                         extra
    Node Version Manager - Simple bash script to manage multiple active node.js versions
morc_menu  1.0-2                                                                                                                                                                      extra
    A categorized applications menu using dmenu and bash
checkbashisms  2.23.6-1                                                                                                                                                               extra
    Debian script that checks for bashisms
argbash  2.10.0-2                                                                                                                                                                     extra
    Bash argument parsing code generator
bashtop  0.9.25-1                                                                                                                                                                     extra
    Linux resource monitor
bashrun  0.16.1-5                                                                                                                                                                     extra
    An x11 application launcher based on bash
bashburn  3.1.0-5                                                                                                                                                                     extra
    CD burning shell script
bashbrew  0.1.1-2                                                                                                                                                                     extra
    Canonical build tool for Docker official images
bash-preexec  0.5.0-2                                                                                                                                                                 extra
    preexec and precmd functions for Bash just like Zsh
bash-language-server  5.0.0-1                                                                                                                                                         extra
    Bash language server implementation based on Tree Sitter and its grammar for Bash
bash-completion  2.11-3                                                                                                                                                               extra
    Programmable completion for the bash shell
bash  5.2.026-2 [Installed]                                                                                                                                                            core
    The GNU Bourne Again shell
```

## `pamac list`

### `pamac list --help`

```
List packages, groups, repositories or files

pamac list [options]

options:
  --installed, -i            : list installed packages
  --explicitly-installed, -e : list explicitly installed packages
  --orphans, -o              : list packages that were installed as dependencies but are no longer required by any installed package
  --foreign, -m              : list packages that were not found in the repositories
  --groups, -g [group(s)]    : list all packages that are members of the given groups, if no group is given list all groups
  --repos, -r [repo(s)]      : list all packages available in the given repos, if no repo is given list all repos
  --files, -f <package(s)>   : list files owned by the given packages
  --quiet, -q                : only print names
```

## `pamac install --help`

```
Install packages from repositories, path or url

pamac install [options] <package(s),group(s)>

options:
  --ignore <package(s)> : ignore a package upgrade, multiple packages can be specified by separating them with a comma
  --overwrite <glob>    : overwrite conflicting files, multiple patterns can be specified by separating them with a comma
  --download-only, -w   : download all packages but do not install/upgrade anything
  --dry-run, -d         : only print what would be done but do not run the transaction
  --as-deps             : mark all packages installed as a dependency
  --as-explicit         : mark all packages explicitly installed
  --upgrade             : check for updates
  --no-upgrade          : do not check for updates
  --no-confirm          : bypass any and all confirmation messages
```

## `pamac reinstall --help`

```
Reinstall packages

pamac reinstall <package(s),group(s)>

options:
  --overwrite <glob>  : overwrite conflicting files, multiple patterns can be specified by separating them with a comma
  --download-only, -w : download all packages but do not install/upgrade anything
  --as-deps           : mark all packages installed as a dependency
  --as-explicit       : mark all packages explicitly installed
  --no-confirm        : bypass any and all confirmation messages
```

## `pamac remove --help`

```
Remove packages

pamac remove [options] [package(s),group(s)]

options:
  --unneeded, -u : remove packages only if they are not required by any other packages
  --cascade, -c  : remove all target packages, as well as all packages that depend on one or more target packages
  --orphans, -o  : remove dependencies that are not required by other packages, if this option is used without package name remove all orphans
  --no-orphans   : do not remove dependencies that are not required by other packages
  --no-save, -n  : ignore files backup
  --dry-run, -d  : only print what would be done but do not run the transaction
  --no-confirm   : bypass any and all confirmation messages
```

## `pamac checkupdates --help`

```
Safely check for updates without modifiying the databases
(Exit code is 100 if updates are available)

pamac checkupdates [options]

options:
  --builddir <dir> : build directory (use with --devel), if no directory is given the one specified in pamac.conf file is used
  --aur, -a        : also check updates in AUR
  --no-aur         : do not check updates in AUR
  --quiet, -q      : only print one line per update
  --devel          : also check development packages updates (use with --aur)
  --no-devel       : do not check development packages updates
```

### `pamac checkupdates -q`

```
zlib  1:1.3.1-2 -> 1:1.3.2-3
```

## `pamac update --help`

```
Upgrade your system

pamac upgrade,update [options]

options:
  --force-refresh       : force the refresh of the databases
  --no-refresh          : do not refresh the databases
  --enable-downgrade    : enable package downgrades
  --disable-downgrade   : disable package downgrades
  --download-only, -w   : download all packages but do not install/upgrade anything
  --dry-run, -d         : only print what would be done but do not run the transaction
  --ignore <package(s)> : ignore a package upgrade, multiple packages can be specified by separating them with a comma
  --overwrite <glob>    : overwrite conflicting files, multiple patterns can be specified by separating them with a comma
  --no-confirm          : bypass any and all confirmation messages
  --aur, -a             : also upgrade packages installed from AUR
  --no-aur              : do not upgrade packages installed from AUR
  --devel               : also upgrade development packages (use with --aur)
  --no-devel            : do not upgrade development packages
  --builddir <dir>      : build directory (use with --aur), if no directory is given the one specified in pamac.conf file is used
```

## `pamac clone --help`

```
Clone or sync packages build files from AUR

pamac clone [options] <package(s)>

options:
  --builddir <dir> : build directory, if no directory is given the one specified in pamac.conf file is used
  --recurse, -r    : also clone needed dependencies
  --quiet, -q      : do not print any output
  --overwrite      : overwrite existing files
```

## `pamac build --help`

```
Build packages from AUR and install them with their dependencies

If no package name is given, use the PKGBUILD file in the current directory
The build directory will be the parent directory, --builddir option will be ignored
and --no-clone option will be enforced

pamac build [options] [package(s)]

options:
  --builddir <dir> : build directory, if no directory is given the one specified in pamac.conf file is used
  --keep, -k       : keep built packages in cache after installation
  --no-keep        : do not keep built packages in cache after installation
  --dry-run, -d    : only print what would be done but do not run the transaction
  --no-clone       : do not clone build files from AUR, only use local files
  --no-confirm     : bypass any and all confirmation messages
```

## `pamac clean --help`

```
Clean packages cache or build files

pamac clean [options]

options:
  --keep, -k <number> : specify how many versions of each package are kept in the cache directory
  --uninstalled, -u   : only target uninstalled packages
  --build-files, -b   : remove all build files, the build directory is the one specified in pamac.conf
  --dry-run, -d       : do not remove files, only find candidate packages
  --verbose, -v       : also display all files names
  --no-confirm        : bypass any and all confirmation messages
```
