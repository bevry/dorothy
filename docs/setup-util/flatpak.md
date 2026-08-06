# flatpak

## resources

- <https://manpages.org/flatpak-install>
- <https://wiki.debian.org/FlatPak>
- <https://docs.flatpak.org/en/latest/flatpak-command-reference.html>
- <https://docs.flatpak.org/en/latest/flatpak-command-reference.html#flatpak-install>
- <https://docs.flatpak.org/en/latest/flatpak-command-reference.html#flatpak-remote-add>
- <https://docs.flatpak.org/en/latest/flatpak-command-reference.html#flatpak-remote-delete>
- <https://docs.flatpak.org/en/latest/flatpak-command-reference.html#flatpak-uninstall>
- <https://docs.flatpak.org/en/latest/flatpak-command-reference.html#flatpak-update>

## notes

- sudo with `flatpak` avoids GUI sudo prompt
- flatpak is case sensitive

## bugs

flatpak has two major bugs that prevent us from doing proper analysis:

- <https://github.com/flatpak/flatpak/issues/6714>
- <https://github.com/flatpak/flatpak/issues/5974>

## `flatpak info`

Can only do one at a time. Returns `1` if not found.

```
flatpak info [OPTION…] NAME [BRANCH] - Get info about an installed app or runtime
--user                     Show user installations
--system                   Show system-wide installations
-r, --show-ref             Show ref
```

## `flatpak list`

<https://docs.flatpak.org/en/latest/flatpak-command-reference.html#flatpak-list>

```
flatpak list [OPTION…]  - List installed apps and/or runtimes
-u, --user                Work on the user installation
--system                  Work on the system-wide installation (default)
-d, --show-details        Show extra information
-a, --all                 List all refs (including locale/debug)
-j, --json                Show output in JSON format
--columns=FIELD,…         What information to show
name             Show the name
description      Show the description
application      Show the application ID
version          Show the version
branch           Show the branch
arch             Show the architecture
runtime          Show the used runtime
origin           Show the origin remote
installation     Show the installation
ref              Show the ref
active           Show the active commit
latest           Show the latest commit
size             Show the installed size
options          Show options
all              Show all columns
help             Show available columns
Append :s[tart], :m[iddle], :e[nd] or :f[ull] to change ellipsization
```

Output without details:
```
Name                       Application ID                                    Version              Branch          Origin               Installation
Discord                    com.discordapp.Discord                            1.0.143              stable          flathub              system
Foliate                    com.github.johnfactotum.Foliate                   3.3.0                stable          fedora               system
```

Output with details:
```
Name        Description                                            Application ID                 Version     Branch Arch   Origin       Installation Ref                                                    Active commit Latest commit Installed size Options
Discord     Talk, play, hang out                                   com.discordapp.Discord         1.0.143     stable x86_64 flathub      system       com.discordapp.Discord/x86_64/stable                   8cc804e5b07b  -             565.4 MB       system,current
Foliate     Read e-books in style                                  …m.github.johnfactotum.Foliate 3.3.0       stable x86_64 fedora       system       com.github.johnfactotum.Foliate/x86_64/stable          066fe980cbdf  -              38.6 MB       system,alt-id=f5f2e5bb3648,current
```

`flatpak list --columns=name,application,version`:
```
Name                                  Application ID                           Version
CoMaps                                app.comaps.comaps                        2026.05.04
```


When piping, it does not output the header:

`flatpak list --columns=name,application,version | cat`:
```
CoMaps	app.comaps.comaps	2026.05.04
Metronome	com.adrienplazas.Metronome	1.3.0
```

`flatpak list --columns=name,application | tr $'\t' ','`:
```
CoMaps,app.comaps.comaps
Metronome,com.adrienplazas.Metronome
```

No ability to filter by arguments.

## `flatpak search`

```
flatpak search [OPTION…] TEXT - Search remote apps/runtimes for text
-u, --user              Work on the user installation
--system                Work on the system-wide installation (default)
-j, --json              Show output in JSON format
--columns=FIELD,…       What information to show
name            Show the name
description     Show the description
application     Show the application ID
version         Show the version
branch          Show the application branch
remotes         Show the remotes
all             Show all columns
help            Show available columns
Append :s[tart], :m[iddle], :e[nd] or :f[ull] to change ellipsization
```

A flatpak search for `time` returns results related to time, but without explicit `time` term, so there is improvisation going on. They are also returned by relevancy. So perhaps only fetch the first 5 results or something. E.g. take this search for `thun`

`flatpak search thun`:
```
Name                              Description                                                                                       Application ID                                Version                        Branch               Remotes
Thunderbird ESR                   Thunderbird is a free and open source email, newsfeed, chat, and calendaring client               org.mozilla.thunderbird_esr                   140.12.0esr                    stable               flathub
Thunderbird                       Thunderbird is a free and open source email, newsfeed, chat, and calendaring client               org.mozilla.thunderbird                       152.0                          stable               flathub
Thunderbird                       Thunderbird is a free and open source email, newsfeed, chat, and calendaring client               net.thunderbird.Thunderbird                   151.0.1                        stable               fedora
Thunderbird                       Thunderbird is a free and open source email, newsfeed, chat, and calendaring client               org.mozilla.Thunderbird                                                      stable               fedora
Thunder                           Xunlei download. 迅雷下载。                                                                       com.xunlei.Thunder                            1.0.0.1                        stable               flathub
Betterbird                        A better version of Thunderbird                                                                   eu.betterbird.Betterbird                      140.12.0esr-bb24               stable               flathub
Birdtray                          System tray new mail notification for Thunderbird                                                 com.ulduzsoft.Birdtray                        1.11.4                         stable               flathub
hushboard                         Mute your mic while you’re typing                                                                 org.kryogenix.hushboard                       1.60.41                        stable               flathub
DavMail                           Office 365 and Exchange gateway                                                                   org.davmail.DavMail                           6.8.0                          stable               flathub
Usermode FTP Server               Access your files from another device                                                             eu.ithz.umftpd                                0.3.10                         stable               flathub
Proton Mail Bridge                Seamlessly encrypts and decrypts your mail as it enters and leaves your computer                  ch.protonmail.protonmail-bridge               3.25.0                         stable               flathub
```

## `flatpak uninstall`

```
flatpak uninstall [OPTION…] [REF…] - Uninstall applications or runtimes
-u, --user              Work on the user installation
--system                Work on the system-wide installation (default)
--app                   Look for app with the specified name
--all                   Uninstall all
--unused                Uninstall unused
--delete-data           Delete app data
-y, --assumeyes         Automatically answer yes for all questions
--noninteractive        Produce minimal output and don't ask questions
```

## `flatpak install`

```
flatpak install [OPTION…] [LOCATION/REMOTE] [REF…] - Install applications or runtimes
-u, --user              Work on the user installation
--system                Work on the system-wide installation (default)
--app                    Look for app with the specified name
-y, --assumeyes         Automatically answer yes for all questions
--noninteractive        Produce minimal output and don't ask questions
--or-update              Update install if already installed
```

## `flatpak update`

```
flatpak update [OPTION…] [REF…] - Update applications or runtimes
--app                    Look for app with the specified name
--appstream              Update appstream for remote [this only updates metadata about the available updates, it does not update the actual applications]
-y, --assumeyes         Automatically answer yes for all questions
--noninteractive        Produce minimal output and don't ask questions
```
