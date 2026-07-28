# winget

## resources
- <https://docs.microsoft.com/en-us/windows/package-manager/winget/>
- <https://docs.microsoft.com/en-us/windows/package-manager/winget/install>

## notes
- installs applications (via ids) to various locations
- aria2c gets installed as aria2c.exe
- which is available via an inherited and complicated PATH modification
- as such isn't available to VSCode Terminal
- the .exe suffix also means it isn't easily discoverable either

## show

<https://aka.ms/winget-command-show>
```
usage: winget show [[-q] <query>] [<options>]
  --id                                 Filter results by id
  --name                               Filter results by name
  --moniker                            Filter results by moniker
  -v,--version                         Use the specified version; default is the latest version
  -e,--exact                           Find package using exact match
  --disable-interactivity     Disable interactive prompts
```

`winget.exe show --query Telegram`:
```
Multiple packages found matching input criteria. Please refine the input.
Name                           Id                       Source
---------------------------------------------------------------
Telegram for Windows (Unigram) 9N97ZCKPD60Q             msstore
Telegram Desktop               Telegram.TelegramDesktop winget
```

## list

<https://aka.ms/winget-command-list>

```
usage: winget list [[-q] <query>] [<options>]
  -q,--query                      The query used to search for a package
  --disable-interactivity         Disable interactive prompts
  --id                            Filter results by id
  --name                          Filter results by name
  --moniker                       Filter results by moniker
  --tag                           Filter results by tag
  --cmd,--command                 Filter results by command
  -n,--count                      Show no more than specified number of results (between 1 and 1000)
  -e,--exact                      Find package using exact match
  --details                       Show detailed information about packages
  --sort                          Sort results by a property (can be repeated)
  --asc,--ascending               Sort results in ascending order
  --desc,--descending             Sort results in descending order
  --accept-source-agreements      Accept all source agreements during source operations
  --upgrade-available             Lists only packages which have an upgrade available
```

`winget.exe list`:
```
Name                                                                                       Id                                                       Version                Available     Source
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Windows Driver Package - Broadcom (B57ports) Net  (10/15/2012 1.0.0.3)                     ARP\Machine\X64\01396BB9E2633BC0DF02F4456D00791CEC0386A6 10/15/2012 1.0.0.3
Windows Driver Package - Broadcom (BCM43XX) Net  (11/21/2016 7.35.118.68)                  ARP\Machine\X64\0E6EDF0776809A3E3271E36BBFC152665FC451FD 11/21/2016 7.35.118.68
```

`winget.exe list --disable-interactivity --query=Telegram`:
```
Name             Id                       Version Available Source
------------------------------------------------------------------
Telegram Desktop Telegram.TelegramDesktop 6.3.9   6.8.2     winget
Beeper 4.2.860   Beeper.Beeper            4.2.860 4.2.876   winget
```

 `winget.exe list --disable-interactivity --details --query=Telegram`:
```
(1/2) Telegram Desktop [Telegram.TelegramDesktop]
Version: 6.3.9
Publisher: Telegram FZ-LLC
Local Identifier: ARP\User\X64\{53F49750-6209-4FBF-9CA8-7A333C87D1ED}_is1
Product Code: {53f49750-6209-4fbf-9ca8-7a333c87d1ed}_is1
Installer Category: exe
Installed Scope: User
Installed Location: C:\Users\balup\AppData\Roaming\Telegram Desktop\
Available Upgrades:
  winget [6.8.2]
(2/2) Beeper 4.2.860 [Beeper.Beeper]
Version: 4.2.860
Publisher: Automattic, Inc.
Local Identifier: ARP\User\X64\4005ec12-b235-5981-b49e-4005d478a398
Product Code: 4005ec12-b235-5981-b49e-4005d478a398
Installer Category: exe
Installed Scope: User
Installed Architecture: X64
Origin Source: winget
Available Upgrades:
  winget [4.2.876]
```

## install

<https://aka.ms/winget-command-install>
```
usage: winget install [[-q] <query>...] [<options>]
  --id                                 Filter results by id
  --name                               Filter results by name
  --moniker                            Filter results by moniker
  -v,--version                         Use the specified version; default is the latest version
  -e,--exact                           Find package using exact match
  --no-upgrade                         Skips upgrade if an installed version already exists
  --accept-package-agreements          Accept all license agreements for packages
  --accept-source-agreements           Accept all source agreements during source operations
  --disable-interactivity              Disable interactive prompts
  -h,--silent                          Request silent installation
```

## upgrade

<https://aka.ms/winget-command-upgrade>
```
usage: winget upgrade [[-q] <query>...] [<options>]
  -m,--manifest                        The path to the manifest of the package
  --id                                 Filter results by id
  --name                               Filter results by name
  --moniker                            Filter results by moniker
  -v,--version                         Use the specified version; default is the latest version
  -e,--exact                           Find package using exact match
  -i,--interactive                     Request interactive installation; user input may be needed
  -h,--silent                          Request silent installation
  --purge                              Deletes all files and directories in the package directory (portable)
  --accept-package-agreements          Accept all license agreements for packages
  --accept-source-agreements           Accept all source agreements during source operations
  -r,--recurse,--all                   Upgrade all installed packages to latest if available
  -u,--unknown,--include-unknown       Upgrade packages even if their current version cannot be determined
  --disable-interactivity              Disable interactive prompts
```

## uninstall

<https://aka.ms/winget-command-uninstall>
```
usage: winget uninstall [[-q] <query>...] [<options>]
  --id                        Filter results by id
  --name                      Filter results by name
  --moniker                   Filter results by moniker
  --product-code              Filters using the product code
  -v,--version                The version to act upon
  --all,--all-versions        Uninstall all versions
  -s,--source                 Find package using the specified source
  -e,--exact                  Find package using exact match
  -h,--silent                 Request silent installation
  --purge                     Deletes all files and directories in the package directory (portable)
  --accept-source-agreements  Accept all source agreements during source operations
  --disable-interactivity     Disable interactive prompts
```