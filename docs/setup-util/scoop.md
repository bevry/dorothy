# scoop

## resources

- <https://scoop.sh/>
- <https://github.com/ScoopInstaller/Scoop/wiki/Commands>
- <https://github.com/ScoopInstaller/Scoop/wiki/Example-Setup-Scripts>
- <https://github.com/ScoopInstaller/Scoop/wiki/Buckets>

## notes

- installs `.exe`s (via names) to a consistent path location

## `scoop export`

`scoop export` does exist matching

## `scoop list`

`scoop list ...<package>` does fuzzy matching, and always returns `0` exit status
as such scoop list requires this to detect if results were achieved `scoop list "$package" | grep --quiet --fixed-strings --regexp='----'`

`scoop list d`:
```
Installed apps matching 'd':

Name    Version     Source Updated             Info
----    -------     ------ -------             ----
delta   0.18.2      main   2025-12-31 12:50:25
deno    2.5.6       main   2025-11-21 12:43:43
nodejs  25.2.1      main   2026-01-02 08:23:59
vivaldi 7.7.3851.67 extras 2026-01-10 06:59:54
```

`scoop list $RANDOM`:
```
Installed apps matching '5307':
```

`scoop info vivaldi`:
```
Name        : vivaldi
Description : An innovatively designed web browser, based on Blink, for users in Vivaldi.net community that replaced
              departed My Opera.
Version     : 7.7.3851.67
Source      : extras
Website     : https://vivaldi.com
License     : BSD-3-Clause
Updated at  : 7/01/2026 4:30:39 PM
Updated by  : github-actions[bot]
Installed   : 7.7.3851.67
Binaries    : Application\vivaldi.exe
Shortcuts   : Vivaldi
```
`scoop info vivaldi | echo-regexp -msonf --regexp='Name[\s:]+([^\s]+).+Version[\s:]+([^\s]+)' --replace='$1 $2'`:
```
vivaldi 7.7.3851.67
```

## `scoop which`

`scoop which vivaldi`:
```
~\scoop\apps\vivaldi\current\Application\vivaldi.exe
```

`wslpath -au '~\scoop\apps\vivaldi\current\Application\vivaldi.exe':
```
/home/balupton/~/scoop/apps/vivaldi/current/Application/vivaldi.exe
```

^ hence need for `__windows_to_unix_path` for correct resolution and handling `~`

## `scoop status`

`scoop status`:
```
WARN  Scoop bucket(s) out of date. Run 'scoop update' to get the latest changes.

Name   Installed Version Latest Version Missing Dependencies Info
----   ----------------- -------------- -------------------- ----
bottom 0.11.4            0.12.3
deno   2.5.6             2.6.4
go     1.25.4            1.25.5
qemu   10.1.0            10.2.0
uv     0.9.11            0.9.23
```

## `scoop install`

- e.g. `scoop install git`
- e.g. `scoop install gh@2.7.0`

```
scoop install <app> [options]
-g, --global                    Install the app globally
-i, --independent               Don't install dependencies automatically
-k, --no-cache                  Don't use the download cache
-s, --skip-hash-check           Skip hash validation (use with caution!)
-u, --no-update-scoop           Don't update Scoop before installing if it's outdated
-a, --arch <32bit|64bit|arm64>  Use the specified architecture, if the app supports it
```

## `scoop uninstall`

```
scoop uninstall <app> [options]
-g, --global   Uninstall a globally installed app <-- global apps are complicated <https://github.com/ScoopInstaller/scoop/wiki/Global-Installs>
-p, --purge    Remove all persistent data
```

if not package not installed then exit status `0` is returned

`scoop uninstall $RANDOM`:
```
ERROR '20119' isn't installed.
```

## `scoop update`
`scoop update` updates scoop itself

```
scoop update <app> [options]
-f, --force            Force update even when there isn't a newer version
-g, --global           Update a globally installed app
-i, --independent      Don't install dependencies automatically
-k, --no-cache         Don't use the download cache
-s, --skip-hash-check  Skip hash validation (use with caution!)
-q, --quiet            Hide extraneous messages
-a, --all              Update all apps (alternative to '*')
```
