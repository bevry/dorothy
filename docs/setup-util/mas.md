# mas

## resources

- <https://github.com/mas-cli/mas/issues>

## bugs

- <https://github.com/mas-cli/mas/issues/321> is unaware of ipados/ios apps available on apple-silicon machines
- <https://github.com/mas-cli/mas/issues/844> is unaware of testflight apps

## notes

Unless `MAS_NO_AUTO_INDEX=1 mas "$@"` is used, then you get these annoying warnings when trying to avoid certain apps being indexed by spotlight:

```
Warning: Found a likely App Store app that is not indexed in Spotlight in /Applications/Exclude/1Password for Safari.app

         Indexing now; will likely complete sometime after mas exits

         Disable auto-indexing via: export MAS_NO_AUTO_INDEX=1
```

- app store ids which are numbers, and are shown as right-aligned, and in JSON are called adamID are immutable
- bundle ids which are strings, are also immutable
- both app store ids and bundle ids both work, and both are immutable
- v7 which came out in `2026 May` and has `--json` flag

## `mas`

### `mas --help`

```
mas --help
OVERVIEW: Mac App Store command-line interface

USAGE: mas <subcommand>

OPTIONS:
  --version               Show the version.
  -h, --help              Show help information.

SUBCOMMANDS:
  config                  Output mas config & related system info
  get, purchase           Get & install free apps from the App Store
  home                    Open App Store app pages in the default web browser
  install                 Install previously gotten apps from the App Store
  list                    List apps installed from the App Store
  lookup, info            Output app info from the App Store
  lucky                   Install the first app returned from searching the App Store
  open                    Open app page in 'App Store.app'
  outdated                List pending app updates from the App Store
  reset                   Reset App Store processes & clear cached App Store downloads
  search                  Search for apps in the App Store
  seller, vendor          Open apps' seller pages in the default web browser
  signout                 Sign out of the App Store
  uninstall               Uninstall apps installed from the App Store
  update, upgrade         Update outdated apps installed from the App Store
  version                 Output version number

  See 'mas help <subcommand>' for detailed help.
```

## `mas config`
### `mas config --help`

```
OVERVIEW: Output mas config & related system info

USAGE: mas config [--json]

OPTIONS:
  --json                  Output JSON
  --version               Show the version.
  -h, --help              Show help information.
```

## `mas get`
### `mas get --help`

```
OVERVIEW: Get & install free apps from the App Store

Requires root privileges to get apps

USAGE: mas get [--force] [--bundle] <app-id> ...

ARGUMENTS:
  <app-id>                App ID

OPTIONS:
  --force                 Force reinstall
  --bundle                Process all app IDs as bundle IDs
  --version               Show the version.
  -h, --help              Show help information.
```

## `mas home`
### `mas home --help`

```
OVERVIEW: Open App Store app pages in the default web browser

USAGE: mas home [--bundle] <app-id> ...

ARGUMENTS:
  <app-id>                App ID

OPTIONS:
  --bundle                Process all app IDs as bundle IDs
  --version               Show the version.
  -h, --help              Show help information.
```

## `mas install`

only installs, doesn't upstall/update

### `mas install --help`

```
OVERVIEW: Install previously gotten apps from the App Store

Requires root privileges to install apps

USAGE: mas install [--force] [--bundle] <app-id> ...

ARGUMENTS:
  <app-id>                App ID

OPTIONS:
  --force                 Force reinstall
  --bundle                Process all app IDs as bundle IDs
  --version               Show the version.
  -h, --help              Show help information.
```

### `mas install 497799835`

only STDERR output:

```
Warning: Already installed Xcode (497799835)
```

### `mas install com.apple.dt.Xcode`

only STDERR output:

```
Warning: Already installed Xcode (497799835)
```

### `mas install 1358823008`

only STDERR output, note that Flighty is current oudated when this command ran:

```
Warning: Already installed Flighty (1358823008)
```

## `mas list`

### `mas list --help`

```
OVERVIEW: List apps installed from the App Store

USAGE: mas list [--json] [--bundle] [<app-id> ...]

ARGUMENTS:
  <app-id>                App ID

OPTIONS:
  --json                  Output JSON
  --bundle                Process all app IDs as bundle IDs
  --version               Show the version.
  -h, --help              Show help information.
```

### `mas list com.super-productivity.app`

fails with only STDERR and exit status `1` on apps that are not installed:

```
Error: No installed apps with bundle ID com.super-productivity.app
Warning: No installed apps found

         If this is unexpected, index apps in Spotlight (which might take some time):

         # Individual app (if the omitted apps are known). e.g., for Xcode:
         mdimport /Applications/Xcode.app

         # All apps:
         vol="$(/usr/libexec/PlistBuddy -c "Print :PreferredVolume:name" ~/Library/Preferences/com.apple.appstored.plist 2>/dev/null)"
         mdimport /Applications ${vol:+"/Volumes/${vol}/Applications"}

         # All volumes:
         sudo mdutil -Eai on
```

### `mas list`

note the right-aligned ids:

```
1586435171  Actions                          (4.2.1)
 420212497  Byword                           (2.9.6)
6746516157  Compressor                       (5.3)
 424390742  Compressor                       (5.3)
1320450034  DaftCloud                        (4.2)
1453273600  Data Jar                         (1.1.4)
 571213070  DaVinci Resolve                  (21.0.2)
6451469297  DeArrow                          (2.3.9)
1032755628  Duplicate File Finder            (9.2.1)
1346247457  Endel                            (4.48.349)
 424389933  Final Cut Pro                    (12.3)
1631624924  Final Cut Pro                    (12.3)
1358823008  Flighty                          (4.10.0)
1460836908  GoPro Player                     (3.3.4)
1622835804  Kagi Search                      (2.2.3)
 361285480  Keynote                          (15.3)
 409183694  Keynote                          (14.5)
 302584613  Kindle                           (7.62)
1142051783  LG Screen Manager                (3.05)
1615087040  Logic Pro                        (12.3)
6746637089  MainStage                        (4.3)
6749351423  Menu Bar Controller for Sonos 2  (7.1.0)
6746637149  Motion                           (6.3)
1006739057  NepTunes                         (3.2.8)
 361304891  Numbers                          (15.3)
 409203825  Numbers                          (14.5)
 409201541  Pages                            (14.5)
 361309726  Pages                            (15.3)
6746662575  Pixelmator Pro                   (4.3)
 897118787  Shazam                           (2.11.0)
1511009307  Shortcut Remote                  (1.0.1)
 803453959  Slack                            (4.50.143)
1306893526  Sorted³                          (3.10)
1573461917  SponsorBlock                     (6.1.6)
 899247664  TestFlight                       (4.2.2)
1585702412  Vidimote                         (1.9)
6449224218  Web Scrobbler                    (3.9.0)
 497799835  Xcode                            (26.6)
```

### ` mas list | echo-regexp -gonm --regexp='^\s*(\d+).+?\(([^\)]+)' --replace='$1 $2'`

ids fixed, but still machine ids:

```
1586435171 4.2.1
420212497 2.9.6
6746516157 5.3
424390742 5.3
1320450034 4.2
1453273600 1.1.4
571213070 21.0.2
6451469297 2.3.9
1032755628 9.2.1
1346247457 4.48.349
424389933 12.3
1631624924 12.3
1358823008 4.10.0
1460836908 3.3.4
1622835804 2.2.3
361285480 15.3
409183694 14.5
302584613 7.62
1142051783 3.05
1615087040 12.3
6746637089 4.3
6749351423 7.1.0
6746637149 6.3
1006739057 3.2.8
361304891 15.3
409203825 14.5
409201541 14.5
361309726 15.3
6746662575 4.3
897118787 2.11.0
1511009307 1.0.1
803453959 4.50.143
1306893526 3.10
1573461917 6.1.6
899247664 4.2.2
1585702412 1.9
6449224218 3.9.0
497799835 26.6
```

### `mas list --json`

ndjson:

``` json
{"adamID":1586435171,"alternateNames":["Actions.app"],"bundleID":"com.sindresorhus.Actions","category":"Utilities","categoryType":"public.app-category.utilities","contentCreationDate":"2026-06-13T16:32:37Z","contentCreationDate_Ranking":"2026-06-13T00:00:00Z","contentModificationDate":"2026-06-20T09:02:14Z","contentModificationDate_Ranking":"2026-06-20T00:00:00Z","contentType":"com.apple.application-bundle","contentTypeTree":["com.apple.application-bundle","com.apple.application","public.executable","com.apple.localizable-name-bundle","com.apple.bundle","public.directory","public.item","com.apple.package"],"copyright":"Copyright © Sindre Sorhus","dateAdded":"2026-07-01T23:38:12Z","dateAdded_Ranking":"2026-07-01T00:00:00Z","description":"","displayName":"Actions.app","displayNameWithExtensions":"Actions.app","documentIdentifier":0,"executableArchitectures":["arm64","x86_64"],"fileSystemContentChangeDate":"2026-06-20T09:02:14Z","fileSystemCreationDate":"2026-06-13T16:32:37Z","fileSystemCreatorCode":0,"fileSystemFinderFlags":0,"fileSystemInvisible":false,"fileSystemIsExtensionHidden":true,"fileSystemLabel":0,"fileSystemName":"Actions.app","fileSystemNodeCount":1,"fileSystemOwnerGroupID":0,"fileSystemOwnerUserID":0,"fileSystemSize":45530980,"fileSystemTypeCode":0,"hasReceipt":true,"installerVersionID":"886906272","interestingDate_Ranking":"2026-06-20T00:00:00Z","isAppleSigned":true,"keywords":"workflow,shortcut,actions,shortcuts,action","kind":"Application","logicalSize":45530980,"name":"Actions","parentalControls":"4+","path":"/System/Volumes/Data/Applications/Actions.app","physicalSize":45641728,"purchaseDate":"2026-06-20T09:02:10Z","receiptIsMachineLicensed":false,"receiptIsRevoked":false,"receiptIsVPPLicensed":false,"receiptType":"Production","version":"4.2.1"}
{"adamID":420212497,"alternateNames":["Byword.app"],"bundleID":"com.metaclassy.byword","category":"Productivity","categoryType":"public.app-category.productivity","contentCreationDate":"2023-10-14T16:34:27Z","contentCreationDate_Ranking":"2023-10-14T00:00:00Z","contentModificationDate":"2023-10-17T16:18:52Z","contentModificationDate_Ranking":"2023-10-17T00:00:00Z","contentType":"com.apple.application-bundle","contentTypeTree":["com.apple.application-bundle","com.apple.application","public.executable","com.apple.localizable-name-bundle","com.apple.bundle","public.directory","public.item","com.apple.package"],"copyright":"© Metaclassy, Lda.","dateAdded":"2026-07-01T23:38:07Z","dateAdded_Ranking":"2026-07-01T00:00:00Z","description":"","displayName":"Byword.app","displayNameWithExtensions":"Byword.app","documentIdentifier":0,"executableArchitectures":["arm64","x86_64"],"fileSystemContentChangeDate":"2023-10-17T16:18:52Z","fileSystemCreationDate":"2023-10-14T16:34:27Z","fileSystemCreatorCode":0,"fileSystemFinderFlags":0,"fileSystemInvisible":false,"fileSystemIsExtensionHidden":true,"fileSystemLabel":0,"fileSystemName":"Byword.app","fileSystemNodeCount":1,"fileSystemOwnerGroupID":0,"fileSystemOwnerUserID":0,"fileSystemSize":6514147,"fileSystemTypeCode":0,"hasReceipt":true,"installerVersionID":"859631768","interestingDate_Ranking":"2023-10-17T00:00:00Z","isAppleSigned":true,"keywords":"","kind":"Application","logicalSize":6514147,"name":"Byword","parentalControls":"4+","path":"/System/Volumes/Data/Applications/Byword.app","physicalSize":4292608,"purchaseDate":"2023-10-17T16:17:43Z","receiptIsMachineLicensed":false,"receiptIsRevoked":false,"receiptIsVPPLicensed":false,"receiptType":"Production","version":"2.9.6"}
// ...
```

### `mas list --json | echo-json stream --stdin | echo-json pretty --stdin`

same as above but pretty, and a proper array:

``` json
[
  {
    adamID: 1586435171,
    alternateNames: [ "Actions.app" ],
    bundleID: "com.sindresorhus.Actions",
    category: "Utilities",
    categoryType: "public.app-category.utilities",
    contentCreationDate: "2026-06-13T16:32:37Z",
    contentCreationDate_Ranking: "2026-06-13T00:00:00Z",
    contentModificationDate: "2026-06-20T09:02:14Z",
    contentModificationDate_Ranking: "2026-06-20T00:00:00Z",
    contentType: "com.apple.application-bundle",
    contentTypeTree: [
      "com.apple.application-bundle",
      "com.apple.application",
      "public.executable",
      "com.apple.localizable-name-bundle",
      "com.apple.bundle",
      "public.directory",
      "public.item",
      "com.apple.package"
    ],
    copyright: "Copyright © Sindre Sorhus",
    dateAdded: "2026-07-01T23:38:12Z",
    dateAdded_Ranking: "2026-07-01T00:00:00Z",
    description: "",
    displayName: "Actions.app",
    displayNameWithExtensions: "Actions.app",
    documentIdentifier: 0,
    executableArchitectures: [ "arm64", "x86_64" ],
    fileSystemContentChangeDate: "2026-06-20T09:02:14Z",
    fileSystemCreationDate: "2026-06-13T16:32:37Z",
    fileSystemCreatorCode: 0,
    fileSystemFinderFlags: 0,
    fileSystemInvisible: false,
    fileSystemIsExtensionHidden: true,
    fileSystemLabel: 0,
    fileSystemName: "Actions.app",
    fileSystemNodeCount: 1,
    fileSystemOwnerGroupID: 0,
    fileSystemOwnerUserID: 0,
    fileSystemSize: 45530980,
    fileSystemTypeCode: 0,
    hasReceipt: true,
    installerVersionID: "886906272",
    interestingDate_Ranking: "2026-06-20T00:00:00Z",
    isAppleSigned: true,
    keywords: "workflow,shortcut,actions,shortcuts,action",
    kind: "Application",
    logicalSize: 45530980,
    name: "Actions",
    parentalControls: "4+",
    path: "/System/Volumes/Data/Applications/Actions.app",
    physicalSize: 45641728,
    purchaseDate: "2026-06-20T09:02:10Z",
    receiptIsMachineLicensed: false,
    receiptIsRevoked: false,
    receiptIsVPPLicensed: false,
    receiptType: "Production",
    version: "4.2.1"
  },
```

### `mas list --json | jq -r '[.bundleID, .version] | join(" ")'`

```
com.sindresorhus.Actions 4.2.1
com.metaclassy.byword 2.9.6
com.apple.CompressorApp 5.3
com.apple.Compressor 5.3
com.obrhoff.daftcloud 4.2
dk.simonbs.DataJar 1.1.4
com.blackmagic-design.DaVinciResolveLite 21.0.2
app.ajay.dearrow 2.3.9
com.nektony.Duplicates-Finder 9.2.1
com.endel.endel 4.48.349
com.apple.FinalCut 12.3
com.apple.FinalCutApp 12.3
com.flightyapp.flighty 4.10.0
com.gopro.GoPro-Player 3.3.4
com.kagimacOS.Kagi-Search 2.2.3
com.apple.Keynote 15.3
com.apple.iWork.Keynote 14.5
com.amazon.Lassen 7.62
com.LGSI.-.LG-Screen-Manager 3.05
com.apple.mobilelogic 12.3
com.apple.MainStageApp 4.3
com.app-lane.mbc 7.1.0
com.apple.motionappApp 6.3
pl.micropixels.NepTunes 3.2.8
com.apple.Numbers 15.3
com.apple.iWork.Numbers 14.5
com.apple.iWork.Pages 14.5
com.apple.Pages 15.3
com.apple.pixelmator 4.3
com.shazam.mac.Shazam 2.11.0
io.frogg.Shortcut-Remote 1.0.1
com.tinyspeck.slackmacgap 4.50.143
com.staysorted.Sorted 3.10
app.ajay.sponsor.macos 6.1.6
com.apple.TestFlight 4.2.2
com.iospirit.Vidimote 1.9
com.webScrobbler.Web-Scrobbler 3.9.0
com.apple.dt.Xcode 26.6
```

### `mas list --json | echo-json pluck --stdin --property=bundleID,version --deliminator=' '`

```
com.sindresorhus.Actions 4.2.1
com.metaclassy.byword 2.9.6
com.apple.CompressorApp 5.3
com.apple.Compressor 5.3
com.obrhoff.daftcloud 4.2
dk.simonbs.DataJar 1.1.4
com.blackmagic-design.DaVinciResolveLite 21.0.2
app.ajay.dearrow 2.3.9
com.nektony.Duplicates-Finder 9.2.1
com.endel.endel 4.48.349
com.apple.FinalCut 12.3
com.apple.FinalCutApp 12.3
com.flightyapp.flighty 4.10.0
com.gopro.GoPro-Player 3.3.4
com.kagimacOS.Kagi-Search 2.2.3
com.apple.Keynote 15.3
com.apple.iWork.Keynote 14.5
com.amazon.Lassen 7.62
com.LGSI.-.LG-Screen-Manager 3.05
com.apple.mobilelogic 12.3
com.apple.MainStageApp 4.3
com.app-lane.mbc 7.1.0
com.apple.motionappApp 6.3
pl.micropixels.NepTunes 3.2.8
com.apple.Numbers 15.3
com.apple.iWork.Numbers 14.5
com.apple.iWork.Pages 14.5
com.apple.Pages 15.3
com.apple.pixelmator 4.3
com.shazam.mac.Shazam 2.11.0
io.frogg.Shortcut-Remote 1.0.1
com.tinyspeck.slackmacgap 4.50.143
com.staysorted.Sorted 3.10
app.ajay.sponsor.macos 6.1.6
com.apple.TestFlight 4.2.2
com.iospirit.Vidimote 1.9
com.webScrobbler.Web-Scrobbler 3.9.0
com.apple.dt.Xcode 26.6
```


## `mas lookup`

installed and uninstalled results are the same:

### `mas lookup --help`

```
OVERVIEW: Output app info from the App Store

USAGE: mas lookup [--json] [--bundle] <app-id> ...

ARGUMENTS:
  <app-id>                App ID

OPTIONS:
  --json                  Output JSON
  --bundle                Process all app IDs as bundle IDs
  --version               Show the version.
  -h, --help              Show help information.
```

### `mas lookup com.apple.dt.Xcode`

currently installed:

```
App ▁▁▁▁▁▁▁▁ Xcode
Version ▁▁▁▁ 26.6
Price ▁▁▁▁▁▁ Free
By ▁▁▁▁▁▁▁▁▁ Apple Pty Limited
Released ▁▁▁ 2026-06-26
Minimum OS ▁ 26.2
Size ▁▁▁▁▁▁▁ 2,351 MB
From ▁▁▁▁▁▁▁ https://apps.apple.com/au/app/xcode/id497799835?mt=12&uo=4
```

### `mas lookup --json com.apple.dt.Xcode`

currently installed:

``` json
{"adamID":497799835,"appStorePageURL":"https://apps.apple.com/au/app/xcode/id497799835?mt=12&uo=4","averageUserRating":3.201140000000000096491703516221605241298675537109375,"averageUserRatingForCurrentVersion":3.201140000000000096491703516221605241298675537109375,"bundleID":"com.apple.dt.Xcode","categories":["Developer Tools"],"categoryIDs":["6026"],"censoredName":"Xcode","contentAdvisoryRating":"4+","contentRating":"4+","currency":"AUD","currentVersionReleaseDate":"2026-06-25T21:59:17Z","description":"Xcode offers the tools you need to develop, test, and distribute apps for Apple platforms, including predictive code completion, generative intelligence powered by the best coding models, advanced profiling and debugging tools, and simulators for Apple devices. It enables a unified workflow that spans from the earliest stages of app development to testing, debugging, optimization, and app distribution to testers and users. And with the Swift programming language, Xcode makes developing apps easy and fun.\n\nSimulator enables rapid prototyping and testing of your app in a simulated environment when a real device isn't available. Instruments helps you profile and analyze your app, improve performance, and investigate system resource usage. And you can use Icon Composer to design stunning layered icons out of Liquid Glass, Reality Composer Pro to create spatial content, train custom machine learning models with Create ML, and identify potential accessibility issues with Accessibility Inspector.\n\nTo test or run applications on an Apple device, all you need is a free Apple Account. To submit your apps to the App Store, you must be a member of the Apple Developer Program. Some features may require internet access and may not be available in all regions or on all Apple devices.","developerAppStorePageURL":"https://apps.apple.com/au/developer/apple/id284417353?mt=12&uo=4","developerID":284417353,"developerName":"Apple","fileSizeBytes":"2351343377","formattedPrice":"Free","icon60URL":"https://is1-ssl.mzstatic.com/image/thumb/Purple221/v4/4c/6d/8c/4c6d8c86-803d-e46c-d5a1-e41da9147ebc/Xcode-0-85-220-0-6-0-0-2x-P3-0-0.png/60x60bb.png","icon100URL":"https://is1-ssl.mzstatic.com/image/thumb/Purple221/v4/4c/6d/8c/4c6d8c86-803d-e46c-d5a1-e41da9147ebc/Xcode-0-85-220-0-6-0-0-2x-P3-0-0.png/100x100bb.png","icon512URL":"https://is1-ssl.mzstatic.com/image/thumb/Purple221/v4/4c/6d/8c/4c6d8c86-803d-e46c-d5a1-e41da9147ebc/Xcode-0-85-220-0-6-0-0-2x-P3-0-0.png/512x512bb.png","isVPPDeviceBasedLicensingEnabled":true,"kind":"mac-software","languageCodesISO2A":["EN"],"minimumOSVersion":"26.2","name":"Xcode","originalVersionReleaseDate":"2012-02-16T14:10:23Z","price":0.00,"primaryCategoryID":6026,"primaryCategoryName":"Developer Tools","releaseNotes":"Xcode 26.6 includes Swift 6.3.3 and SDKs for iOS 26.5, iPadOS 26.5, tvOS 26.5, watchOS 26.5, visionOS 26.5, and macOS 26.5.\n\nThis update adds support for Google Gemini in the coding assistant, in addition to Anthropic Claude Agent and OpenAI Codex. It also enables use of other compatible agents through the Agent Client Protocol, and provides bug fixes and improved stability.","screenshotURLs":["https://is1-ssl.mzstatic.com/image/thumb/PurpleSource211/v4/47/f5/36/47f536d6-b57c-12cf-c602-381bd211c1fb/1-Xcode26-Hero-Light.png/800x500bb.jpg","https://is1-ssl.mzstatic.com/image/thumb/PurpleSource211/v4/b7/15/8f/b7158f21-44da-09d5-8fea-351182a32199/2-Xcode26-ClaudeAgent-Light.png/800x500bb.jpg","https://is1-ssl.mzstatic.com/image/thumb/PurpleSource221/v4/63/c0/bb/63c0bb7a-bbef-483c-c48b-3fce1da73756/3-Xcode26-Claude-Playgrounds-Light.png/800x500bb.jpg","https://is1-ssl.mzstatic.com/image/thumb/PurpleSource211/v4/b1/61/f0/b161f0f0-3d30-a2ea-4f0d-e2000171c43e/4-Xcode26-Strings-Light.png/800x500bb.jpg","https://is1-ssl.mzstatic.com/image/thumb/PurpleSource221/v4/c6/f9/6a/c6f96a23-3aec-f217-5059-ced78c982f68/5-Xcode26-Instruments-Light.png/800x500bb.jpg","https://is1-ssl.mzstatic.com/image/thumb/PurpleSource211/v4/5f/70/33/5f7033ba-279b-3d0d-bfcb-1e069b47f732/6-Xcode26-IconComposer-Light.png/800x500bb.jpg","https://is1-ssl.mzstatic.com/image/thumb/PurpleSource221/v4/0d/a1/9d/0da19dd8-dccf-92a1-f144-74a2f0f62d3a/7-Xcode26-VisionOS-Dark.png/800x500bb.jpg","https://is1-ssl.mzstatic.com/image/thumb/PurpleSource211/v4/65/69/06/65690630-4dd9-5263-c449-39cd29628622/8-Xcode26-RCP-Dark1.png/800x500bb.jpg"],"sellerName":"Apple Pty Limited","sellerURL":"http://developer.apple.com/xcode","userRatingCount":1049,"userRatingCountForCurrentVersion":1049,"version":"26.6","wrapperType":"software"}
```

### `mas lookup --json com.apple.dt.Xcode | echo-json pretty --stdin`

currently installed:

``` json
{
  adamID: 497799835,
  appStorePageURL: "https://apps.apple.com/au/app/xcode/id497799835?mt=12&uo=4",
  averageUserRating: 3.20114,
  averageUserRatingForCurrentVersion: 3.20114,
  bundleID: "com.apple.dt.Xcode",
  categories: [ "Developer Tools" ],
  categoryIDs: [ "6026" ],
  censoredName: "Xcode",
  contentAdvisoryRating: "4+",
  contentRating: "4+",
  currency: "AUD",
  currentVersionReleaseDate: "2026-06-25T21:59:17Z",
  description: "Xcode offers the tools you need to develop, test, and distribute apps for Apple platforms, including predictive code completion, generative intelligence powered by the best coding models, advanced profiling and debugging tools, and simulators for Apple devices. It enables a unified workflow that spans from the earliest stages of app development to testing, debugging, optimization, and app distribution to testers and users. And with the Swift programming language, Xcode makes developing apps easy and fun.\n" +
    "\n" +
    "Simulator enables rapid prototyping and testing of your app in a simulated environment when a real device isn't available. Instruments helps you profile and analyze your app, improve performance, and investigate system resource usage. And you can use Icon Composer to design stunning layered icons out of Liquid Glass, Reality Composer Pro to create spatial content, train custom machine learning models with Create ML, and identify potential accessibility issues with Accessibility Inspector.\n" +
    "\n" +
    "To test or run applications on an Apple device, all you need is a free Apple Account. To submit your apps to the App Store, you must be a member of the Apple Developer Program. Some features may require internet access and may not be available in all regions or on all Apple devices.",
  developerAppStorePageURL: "https://apps.apple.com/au/developer/apple/id284417353?mt=12&uo=4",
  developerID: 284417353,
  developerName: "Apple",
  fileSizeBytes: "2351343377",
  formattedPrice: "Free",
  icon60URL: "https://is1-ssl.mzstatic.com/image/thumb/Purple221/v4/4c/6d/8c/4c6d8c86-803d-e46c-d5a1-e41da9147ebc/Xcode-0-85-220-0-6-0-0-2x-P3-0-0.png/60x60bb.png",
  icon100URL: "https://is1-ssl.mzstatic.com/image/thumb/Purple221/v4/4c/6d/8c/4c6d8c86-803d-e46c-d5a1-e41da9147ebc/Xcode-0-85-220-0-6-0-0-2x-P3-0-0.png/100x100bb.png",
  icon512URL: "https://is1-ssl.mzstatic.com/image/thumb/Purple221/v4/4c/6d/8c/4c6d8c86-803d-e46c-d5a1-e41da9147ebc/Xcode-0-85-220-0-6-0-0-2x-P3-0-0.png/512x512bb.png",
  isVPPDeviceBasedLicensingEnabled: true,
  kind: "mac-software",
  languageCodesISO2A: [ "EN" ],
  minimumOSVersion: "26.2",
  name: "Xcode",
  originalVersionReleaseDate: "2012-02-16T14:10:23Z",
  price: 0,
  primaryCategoryID: 6026,
  primaryCategoryName: "Developer Tools",
  releaseNotes: "Xcode 26.6 includes Swift 6.3.3 and SDKs for iOS 26.5, iPadOS 26.5, tvOS 26.5, watchOS 26.5, visionOS 26.5, and macOS 26.5.\n" +
    "\n" +
    "This update adds support for Google Gemini in the coding assistant, in addition to Anthropic Claude Agent and OpenAI Codex. It also enables use of other compatible agents through the Agent Client Protocol, and provides bug fixes and improved stability.",
  screenshotURLs: [
    "https://is1-ssl.mzstatic.com/image/thumb/PurpleSource211/v4/47/f5/36/47f536d6-b57c-12cf-c602-381bd211c1fb/1-Xcode26-Hero-Light.png/800x500bb.jpg",
    "https://is1-ssl.mzstatic.com/image/thumb/PurpleSource211/v4/b7/15/8f/b7158f21-44da-09d5-8fea-351182a32199/2-Xcode26-ClaudeAgent-Light.png/800x500bb.jpg",
    "https://is1-ssl.mzstatic.com/image/thumb/PurpleSource221/v4/63/c0/bb/63c0bb7a-bbef-483c-c48b-3fce1da73756/3-Xcode26-Claude-Playgrounds-Light.png/800x500bb.jpg",
    "https://is1-ssl.mzstatic.com/image/thumb/PurpleSource211/v4/b1/61/f0/b161f0f0-3d30-a2ea-4f0d-e2000171c43e/4-Xcode26-Strings-Light.png/800x500bb.jpg",
    "https://is1-ssl.mzstatic.com/image/thumb/PurpleSource221/v4/c6/f9/6a/c6f96a23-3aec-f217-5059-ced78c982f68/5-Xcode26-Instruments-Light.png/800x500bb.jpg",
    "https://is1-ssl.mzstatic.com/image/thumb/PurpleSource211/v4/5f/70/33/5f7033ba-279b-3d0d-bfcb-1e069b47f732/6-Xcode26-IconComposer-Light.png/800x500bb.jpg",
    "https://is1-ssl.mzstatic.com/image/thumb/PurpleSource221/v4/0d/a1/9d/0da19dd8-dccf-92a1-f144-74a2f0f62d3a/7-Xcode26-VisionOS-Dark.png/800x500bb.jpg",
    "https://is1-ssl.mzstatic.com/image/thumb/PurpleSource211/v4/65/69/06/65690630-4dd9-5263-c449-39cd29628622/8-Xcode26-RCP-Dark1.png/800x500bb.jpg"
  ],
  sellerName: "Apple Pty Limited",
  sellerURL: "http://developer.apple.com/xcode",
  userRatingCount: 1049,
  userRatingCountForCurrentVersion: 1049,
  version: "26.6",
  wrapperType: "software"
}
```

### `mas lookup com.super-productivity.app`

not currently installed:

```
App ▁▁▁▁▁▁▁▁ Super Productivity
Version ▁▁▁▁ 18.11.0
Price ▁▁▁▁▁▁ Free
By ▁▁▁▁▁▁▁▁▁ Johannes Millan
Released ▁▁▁ 2026-06-19
Minimum OS ▁ 12.0
Size ▁▁▁▁▁▁▁ 157 MB
From ▁▁▁▁▁▁▁ https://apps.apple.com/au/app/super-productivity/id1482572463?uo=4
```

### `mas lookup --json com.super-productivity.app`

not currently installed:

``` json
{"adamID":1482572463,"advisories":[],"appStorePageURL":"https://apps.apple.com/au/app/super-productivity/id1482572463?uo=4","appleTVScreenshotURLs":[],"averageUserRating":5,"averageUserRatingForCurrentVersion":5,"bundleID":"com.super-productivity.app","categories":["Productivity","Developer Tools"],"categoryIDs":["6007","6026"],"censoredName":"Super Productivity","contentAdvisoryRating":"4+","contentRating":"4+","currency":"AUD","currentVersionReleaseDate":"2026-06-18T22:21:29Z","description":"Plan. Focus. Ship work.\n\nSuper Productivity combines a fast to-do list, precise time tracking, and smart integrations in one local-first app for macOS.\n\nWHAT YOU CAN DO\n• Capture and prioritize tasks without friction\n• Track time per task (Pomodoro and focus timers included)\n• Plan your day and week with a clear, drag-and-drop planner\n• Export clean timesheets and work reports\n\nINTEGRATED, NOT INTRUSIVE\n• Connect Jira, GitHub, GitLab, and OpenProject\n• Import issues, filter what matters, and stay updated without noise\n\nBUILT FOR DEEP WORK\n• Focus mode, break reminders, and lightweight self-reviews\n• Wide keyboard shortcut coverage for a fast workflow\n\nPRIVATE & LOCAL-FIRST\n• Open source, no accounts, no data collection\n• Your data stays on your device; backups and exports are always available\n\nWHO IT’S FOR\nDevelopers, freelancers, and teams who care about clarity, speed, and privacy.","developerAppStorePageURL":"https://apps.apple.com/au/developer/johannes-millan/id1032083579?uo=4","developerID":1032083579,"developerName":"Johannes Millan","features":["iosUniversal"],"fileSizeBytes":"157206634","formattedPrice":"Free","iPadScreenshotURLs":[],"icon60URL":"https://is1-ssl.mzstatic.com/image/thumb/Purple211/v4/90/b8/13/90b813d1-c738-d7bd-0e73-32c5f6f9caad/icon.png/60x60bb.jpg","icon100URL":"https://is1-ssl.mzstatic.com/image/thumb/Purple211/v4/90/b8/13/90b813d1-c738-d7bd-0e73-32c5f6f9caad/icon.png/100x100bb.jpg","icon512URL":"https://is1-ssl.mzstatic.com/image/thumb/Purple211/v4/90/b8/13/90b813d1-c738-d7bd-0e73-32c5f6f9caad/icon.png/512x512bb.jpg","isGameCenterEnabled":false,"isVPPDeviceBasedLicensingEnabled":true,"kind":"software","languageCodesISO2A":["AF","AM","AR","BN","BG","CA","HR","CS","DA","NL","EN","ET","FI","FR","DE","EL","GU","HE","HI","HU","ID","IT","JA","KN","KO","LV","LT","MS","ML","MR","NB","FA","PL","PT","RO","RU","SR","ZH","SK","SL","ES","SW","SV","TA","TE","TH","ZH","TR","UK","UR","VI"],"minimumOSVersion":"12.0","name":"Super Productivity","originalVersionReleaseDate":"2020-10-12T07:00:00Z","price":0.00,"primaryCategoryID":6007,"primaryCategoryName":"Productivity","releaseNotes":"Features\n\n• Add notes directly from the add-task bar.\n• Added the built-in Plainspace theme and refreshed the Rainbow theme.\n• Project and tag dropdowns now follow their tree order.\n• Focus Mode is enabled in the time-tracker onboarding preset.\n• Updated Ukrainian translations.\n\nFixes\n\n• Improved sync reliability, conflict handling, retries, encryption operations, and lost-update protection.\n• Fullscreen note edits now persist when navigating, resizing, or ending a Focus Mode session.\n• Improved mobile backup restoration and durability, including large Android backups and iOS read failures.\n• Restored desktop plugin rendering, prevented empty side panels, and exposed the focused-task API to iframe plugins.\n• Fixed Windows tray icons, macOS shortcut layouts, and Meta/OS modifier recording.\n• Fixed Android keyboard positioning, status-bar spacing, and background battery drain.\n• Added support for app deep links such as `obsidian://`.\n• Fixed Daily Summary opening from the before-close dialog.\n• Fixed several task, Focus Mode, schedule, and idle-button visual issues.\n• Redacted provider credentials and WebSocket tokens from exportable logs.\n• Fixed Nextcloud Deck completion values and rejected negative counter values.\n\nPerformance\n\n• Improved sync performance by caching the latest full-state operation lookup.","screenshotURLs":[],"sellerName":"Johannes Millan","sellerURL":"https://super-productivity.com","supportedDevices":["MacDesktop-MacDesktop"],"userRatingCount":6,"userRatingCountForCurrentVersion":6,"version":"18.11.0","wrapperType":"software"}
```

### `mas lookup --json com.super-productivity.app | echo-json pretty --stdin`

not currently installed:

``` json
{
  adamID: 1482572463,
  advisories: [],
  appStorePageURL: "https://apps.apple.com/au/app/super-productivity/id1482572463?uo=4",
  appleTVScreenshotURLs: [],
  averageUserRating: 5,
  averageUserRatingForCurrentVersion: 5,
  bundleID: "com.super-productivity.app",
  categories: [ "Productivity", "Developer Tools" ],
  categoryIDs: [ "6007", "6026" ],
  censoredName: "Super Productivity",
  contentAdvisoryRating: "4+",
  contentRating: "4+",
  currency: "AUD",
  currentVersionReleaseDate: "2026-06-18T22:21:29Z",
  description: "Plan. Focus. Ship work.\n" +
    "\n" +
    "Super Productivity combines a fast to-do list, precise time tracking, and smart integrations in one local-first app for macOS.\n" +
    "\n" +
    "WHAT YOU CAN DO\n" +
    "• Capture and prioritize tasks without friction\n" +
    "• Track time per task (Pomodoro and focus timers included)\n" +
    "• Plan your day and week with a clear, drag-and-drop planner\n" +
    "• Export clean timesheets and work reports\n" +
    "\n" +
    "INTEGRATED, NOT INTRUSIVE\n" +
    "• Connect Jira, GitHub, GitLab, and OpenProject\n" +
    "• Import issues, filter what matters, and stay updated without noise\n" +
    "\n" +
    "BUILT FOR DEEP WORK\n" +
    "• Focus mode, break reminders, and lightweight self-reviews\n" +
    "• Wide keyboard shortcut coverage for a fast workflow\n" +
    "\n" +
    "PRIVATE & LOCAL-FIRST\n" +
    "• Open source, no accounts, no data collection\n" +
    "• Your data stays on your device; backups and exports are always available\n" +
    "\n" +
    "WHO IT’S FOR\n" +
    "Developers, freelancers, and teams who care about clarity, speed, and privacy.",
  developerAppStorePageURL: "https://apps.apple.com/au/developer/johannes-millan/id1032083579?uo=4",
  developerID: 1032083579,
  developerName: "Johannes Millan",
  features: [ "iosUniversal" ],
  fileSizeBytes: "157206634",
  formattedPrice: "Free",
  iPadScreenshotURLs: [],
  icon60URL: "https://is1-ssl.mzstatic.com/image/thumb/Purple211/v4/90/b8/13/90b813d1-c738-d7bd-0e73-32c5f6f9caad/icon.png/60x60bb.jpg",
  icon100URL: "https://is1-ssl.mzstatic.com/image/thumb/Purple211/v4/90/b8/13/90b813d1-c738-d7bd-0e73-32c5f6f9caad/icon.png/100x100bb.jpg",
  icon512URL: "https://is1-ssl.mzstatic.com/image/thumb/Purple211/v4/90/b8/13/90b813d1-c738-d7bd-0e73-32c5f6f9caad/icon.png/512x512bb.jpg",
  isGameCenterEnabled: false,
  isVPPDeviceBasedLicensingEnabled: true,
  kind: "software",
  languageCodesISO2A: [
    "AF", "AM", "AR", "BN", "BG", "CA", "HR",
    "CS", "DA", "NL", "EN", "ET", "FI", "FR",
    "DE", "EL", "GU", "HE", "HI", "HU", "ID",
    "IT", "JA", "KN", "KO", "LV", "LT", "MS",
    "ML", "MR", "NB", "FA", "PL", "PT", "RO",
    "RU", "SR", "ZH", "SK", "SL", "ES", "SW",
    "SV", "TA", "TE", "TH", "ZH", "TR", "UK",
    "UR", "VI"
  ],
  minimumOSVersion: "12.0",
  name: "Super Productivity",
  originalVersionReleaseDate: "2020-10-12T07:00:00Z",
  price: 0,
  primaryCategoryID: 6007,
  primaryCategoryName: "Productivity",
  releaseNotes: "Features\n" +
    "\n" +
    "• Add notes directly from the add-task bar.\n" +
    "• Added the built-in Plainspace theme and refreshed the Rainbow theme.\n" +
    "• Project and tag dropdowns now follow their tree order.\n" +
    "• Focus Mode is enabled in the time-tracker onboarding preset.\n" +
    "• Updated Ukrainian translations.\n" +
    "\n" +
    "Fixes\n" +
    "\n" +
    "• Improved sync reliability, conflict handling, retries, encryption operations, and lost-update protection.\n" +
    "• Fullscreen note edits now persist when navigating, resizing, or ending a Focus Mode session.\n" +
    "• Improved mobile backup restoration and durability, including large Android backups and iOS read failures.\n" +
    "• Restored desktop plugin rendering, prevented empty side panels, and exposed the focused-task API to iframe plugins.\n" +
    "• Fixed Windows tray icons, macOS shortcut layouts, and Meta/OS modifier recording.\n" +
    "• Fixed Android keyboard positioning, status-bar spacing, and background battery drain.\n" +
    "• Added support for app deep links such as `obsidian://`.\n" +
    "• Fixed Daily Summary opening from the before-close dialog.\n" +
    "• Fixed several task, Focus Mode, schedule, and idle-button visual issues.\n" +
    "• Redacted provider credentials and WebSocket tokens from exportable logs.\n" +
    "• Fixed Nextcloud Deck completion values and rejected negative counter values.\n" +
    "\n" +
    "Performance\n" +
    "\n" +
    "• Improved sync performance by caching the latest full-state operation lookup.",
  screenshotURLs: [],
  sellerName: "Johannes Millan",
  sellerURL: "https://super-productivity.com",
  supportedDevices: [ "MacDesktop-MacDesktop" ],
  userRatingCount: 6,
  userRatingCountForCurrentVersion: 6,
  version: "18.11.0",
  wrapperType: "software"
}
```

## `mas lucky`
### `mas lucky --help`

```
OVERVIEW: Install the first app returned from searching the App Store

App will install only if it has already been gotten

Requires root privileges to install apps

USAGE: mas lucky [--force] <search-term> ...

ARGUMENTS:
  <search-term>           Search terms are concatenated into a single search

OPTIONS:
  --force                 Force reinstall
  --version               Show the version.
  -h, --help              Show help information.
```

## `mas open`
### `mas open --help`

```
OVERVIEW: Open app page in 'App Store.app'

USAGE: mas open [--bundle] [<app-id>]

ARGUMENTS:
  <app-id>                App ID

OPTIONS:
  --bundle                Process all app IDs as bundle IDs
  --version               Show the version.
  -h, --help              Show help information.
```

## `mas outdated`
### `mas outdated --help`

```
OVERVIEW: List pending app updates from the App Store

USAGE: mas outdated [--json] [--accurate] [--inaccurate] [--check-min-os] [--no-check-min-os] [--verbose] [--bundle] [<app-id> ...]

ARGUMENTS:
  <app-id>                App ID

OPTIONS:
  --json                  Output JSON
  --accurate              Use accurate, slower logic that starts then cancels a download
                          for each queried app, which can exceed download limits & which
                          will open dialogs for undownloadable apps
  --inaccurate            Use inaccurate, faster logic that avoids dialogs (default:
                          --inaccurate)
  --check-min-os/--no-check-min-os
                          Check if macOS can install latest app version (default:
                          --check-min-os)
  --verbose               Warn about app IDs unknown to the App Store
  --bundle                Process all app IDs as bundle IDs
  --version               Show the version.
  -h, --help              Show help information.
```

### `mas outdated com.apple.dt.Xcode`

outputs nothing with exit status `0` if app is already up to date

so only way to know which apps need updating is via parsing, not via exit status

### `mas outdated`

note right-aligned ids:

```
1358823008  Flighty  (4.10.0 -> 4.10.1)
 302584613  Kindle   (7.62   -> 7.63)
```

### `mas outdated --json`

``` json
{"adamID":1358823008,"alternateNames":["Flighty.app"],"bundleID":"com.flightyapp.flighty","category":"Travel","categoryType":"public.app-category.travel","contentCreationDate":"2026-07-01T20:40:35Z","contentCreationDate_Ranking":"2026-07-01T00:00:00Z","contentModificationDate":"2026-07-08T02:58:58Z","contentModificationDate_Ranking":"2026-07-08T00:00:00Z","contentType":"com.apple.application-bundle","contentTypeTree":["com.apple.application-bundle","com.apple.application","public.executable","com.apple.localizable-name-bundle","com.apple.bundle","public.directory","public.item","com.apple.package"],"copyright":"","dateAdded":"2026-07-01T23:38:12Z","dateAdded_Ranking":"2026-07-01T00:00:00Z","description":"","displayName":"Flighty.app","displayNameWithExtensions":"Flighty.app","documentIdentifier":0,"executableArchitectures":["arm64","x86_64"],"fileSystemContentChangeDate":"2026-07-08T02:58:58Z","fileSystemCreationDate":"2026-07-01T20:40:35Z","fileSystemCreatorCode":0,"fileSystemFinderFlags":0,"fileSystemInvisible":false,"fileSystemIsExtensionHidden":true,"fileSystemLabel":0,"fileSystemName":"Flighty.app","fileSystemNodeCount":1,"fileSystemOwnerGroupID":0,"fileSystemOwnerUserID":0,"fileSystemTypeCode":0,"hasReceipt":true,"installerVersionID":"887600477","interestingDate_Ranking":"2026-07-08T00:00:00Z","isAppleSigned":true,"keywords":"","kind":"Application","lastUsedDate":"2026-07-02T11:01:16Z","lastUsedDate_Ranking":"2026-07-02T00:00:00Z","name":"Flighty","newVersion":"4.10.1","parentalControls":"4+","path":"/System/Volumes/Data/Applications/Flighty.app","purchaseDate":"2026-07-08T02:58:57Z","receiptIsMachineLicensed":false,"receiptIsRevoked":false,"receiptIsVPPLicensed":false,"receiptType":"Production","recentOutOfSpotlightEngagementDates":["2026-06-22T18:12:03Z","2026-06-22T18:12:36Z","2026-06-22T18:15:04Z"],"useCount":21,"usedDates":["2026-06-22T16:00:00Z","2026-07-01T16:00:00Z"],"version":"4.10.0"}
{"adamID":302584613,"alternateNames":["Amazon Kindle.app"],"bundleID":"com.amazon.Lassen","category":"Reference","categoryType":"public.app-category.reference","contentCreationDate":"2026-07-02T07:07:49Z","contentCreationDate_Ranking":"2026-07-02T00:00:00Z","contentModificationDate":"2026-07-02T19:00:27Z","contentModificationDate_Ranking":"2026-07-02T00:00:00Z","contentType":"com.apple.application-bundle","contentTypeTree":["com.apple.application-bundle","com.apple.application","public.executable","com.apple.localizable-name-bundle","com.apple.bundle","public.directory","public.item","com.apple.package"],"copyright":"","dateAdded":"2026-07-01T23:38:12Z","dateAdded_Ranking":"2026-07-01T00:00:00Z","description":"","displayName":"Kindle.app","displayNameWithExtensions":"Kindle.app","documentIdentifier":0,"executableArchitectures":["arm64","x86_64"],"fileSystemContentChangeDate":"2026-07-02T19:00:27Z","fileSystemCreationDate":"2026-07-02T07:07:49Z","fileSystemCreatorCode":0,"fileSystemFinderFlags":0,"fileSystemInvisible":false,"fileSystemIsExtensionHidden":true,"fileSystemLabel":0,"fileSystemName":"Amazon Kindle.app","fileSystemNodeCount":1,"fileSystemOwnerGroupID":0,"fileSystemOwnerUserID":0,"fileSystemSize":285727147,"fileSystemTypeCode":0,"hasReceipt":true,"installerVersionID":"887685008","interestingDate_Ranking":"2026-07-02T00:00:00Z","isAppleSigned":true,"keywords":"","kind":"Application","logicalSize":285727147,"name":"Kindle","newVersion":"7.63","parentalControls":"12+","path":"/System/Volumes/Data/Applications/Amazon Kindle.app","physicalSize":283713536,"purchaseDate":"2026-07-02T19:00:25Z","receiptIsMachineLicensed":false,"receiptIsRevoked":false,"receiptIsVPPLicensed":false,"receiptType":"Production","version":"7.62"}
```

### `mas outdated --json | echo-json stream --stdin | echo-json pretty --stdin

``` json
[
  {
    adamID: 1358823008,
    alternateNames: [ "Flighty.app" ],
    bundleID: "com.flightyapp.flighty",
    category: "Travel",
    categoryType: "public.app-category.travel",
    contentCreationDate: "2026-07-01T20:40:35Z",
    contentCreationDate_Ranking: "2026-07-01T00:00:00Z",
    contentModificationDate: "2026-07-08T02:58:58Z",
    contentModificationDate_Ranking: "2026-07-08T00:00:00Z",
    contentType: "com.apple.application-bundle",
    contentTypeTree: [
      "com.apple.application-bundle",
      "com.apple.application",
      "public.executable",
      "com.apple.localizable-name-bundle",
      "com.apple.bundle",
      "public.directory",
      "public.item",
      "com.apple.package"
    ],
    copyright: "",
    dateAdded: "2026-07-01T23:38:12Z",
    dateAdded_Ranking: "2026-07-01T00:00:00Z",
    description: "",
    displayName: "Flighty.app",
    displayNameWithExtensions: "Flighty.app",
    documentIdentifier: 0,
    executableArchitectures: [ "arm64", "x86_64" ],
    fileSystemContentChangeDate: "2026-07-08T02:58:58Z",
    fileSystemCreationDate: "2026-07-01T20:40:35Z",
    fileSystemCreatorCode: 0,
    fileSystemFinderFlags: 0,
    fileSystemInvisible: false,
    fileSystemIsExtensionHidden: true,
    fileSystemLabel: 0,
    fileSystemName: "Flighty.app",
    fileSystemNodeCount: 1,
    fileSystemOwnerGroupID: 0,
    fileSystemOwnerUserID: 0,
    fileSystemTypeCode: 0,
    hasReceipt: true,
    installerVersionID: "887600477",
    interestingDate_Ranking: "2026-07-08T00:00:00Z",
    isAppleSigned: true,
    keywords: "",
    kind: "Application",
    lastUsedDate: "2026-07-02T11:01:16Z",
    lastUsedDate_Ranking: "2026-07-02T00:00:00Z",
    name: "Flighty",
    newVersion: "4.10.1",
    parentalControls: "4+",
    path: "/System/Volumes/Data/Applications/Flighty.app",
    purchaseDate: "2026-07-08T02:58:57Z",
    receiptIsMachineLicensed: false,
    receiptIsRevoked: false,
    receiptIsVPPLicensed: false,
    receiptType: "Production",
    recentOutOfSpotlightEngagementDates: [
      "2026-06-22T18:12:03Z",
      "2026-06-22T18:12:36Z",
      "2026-06-22T18:15:04Z"
    ],
    useCount: 21,
    usedDates: [ "2026-06-22T16:00:00Z", "2026-07-01T16:00:00Z" ],
    version: "4.10.0"
  },
  {
    adamID: 302584613,
    alternateNames: [ "Amazon Kindle.app" ],
    bundleID: "com.amazon.Lassen",
    category: "Reference",
    categoryType: "public.app-category.reference",
    contentCreationDate: "2026-07-02T07:07:49Z",
    contentCreationDate_Ranking: "2026-07-02T00:00:00Z",
    contentModificationDate: "2026-07-02T19:00:27Z",
    contentModificationDate_Ranking: "2026-07-02T00:00:00Z",
    contentType: "com.apple.application-bundle",
    contentTypeTree: [
      "com.apple.application-bundle",
      "com.apple.application",
      "public.executable",
      "com.apple.localizable-name-bundle",
      "com.apple.bundle",
      "public.directory",
      "public.item",
      "com.apple.package"
    ],
    copyright: "",
    dateAdded: "2026-07-01T23:38:12Z",
    dateAdded_Ranking: "2026-07-01T00:00:00Z",
    description: "",
    displayName: "Kindle.app",
    displayNameWithExtensions: "Kindle.app",
    documentIdentifier: 0,
    executableArchitectures: [ "arm64", "x86_64" ],
    fileSystemContentChangeDate: "2026-07-02T19:00:27Z",
    fileSystemCreationDate: "2026-07-02T07:07:49Z",
    fileSystemCreatorCode: 0,
    fileSystemFinderFlags: 0,
    fileSystemInvisible: false,
    fileSystemIsExtensionHidden: true,
    fileSystemLabel: 0,
    fileSystemName: "Amazon Kindle.app",
    fileSystemNodeCount: 1,
    fileSystemOwnerGroupID: 0,
    fileSystemOwnerUserID: 0,
    fileSystemSize: 285727147,
    fileSystemTypeCode: 0,
    hasReceipt: true,
    installerVersionID: "887685008",
    interestingDate_Ranking: "2026-07-02T00:00:00Z",
    isAppleSigned: true,
    keywords: "",
    kind: "Application",
    logicalSize: 285727147,
    name: "Kindle",
    newVersion: "7.63",
    parentalControls: "12+",
    path: "/System/Volumes/Data/Applications/Amazon Kindle.app",
    physicalSize: 283713536,
    purchaseDate: "2026-07-02T19:00:25Z",
    receiptIsMachineLicensed: false,
    receiptIsRevoked: false,
    receiptIsVPPLicensed: false,
    receiptType: "Production",
    version: "7.62"
  }
]
```

### `mas outdated --json | jq -r '[.bundleID, .version, .newVersion] | join(" ")'`

```
com.flightyapp.flighty 4.10.0 4.10.1
com.amazon.Lassen 7.62 7.63
```

## `mas reset`
### `mas reset --help`

```
OVERVIEW: Reset App Store processes & clear cached App Store downloads

USAGE: mas reset

OPTIONS:
  --version               Show the version.
  -h, --help              Show help information.
```

## `mas search`

- `mas search` does fuzzy searches on titles and descriptions, as such our search actions have to combine `mas search` and `mas lookup`
- `mas search` when given an exact id, will still return recommendations, with closest match being first:

### `mas search --help`

```
OVERVIEW: Search for apps in the App Store

USAGE: mas search [--json] [--price] <search-term> ...

ARGUMENTS:
  <search-term>           Search terms are concatenated into a single search

OPTIONS:
  --json                  Output JSON
  --price                 Output the price of each app
  --version               Show the version.
  -h, --help              Show help information.
```

### `mas search com.apple.dt.Xcode`

note right alignment of id numbers:

```
 640199958  Apple Developer                (11.0.2)
1183412116  Swiftify for Xcode             (6.2)
1388020431  DevCleaner for Xcode           (2.8.0)
1496833156  Swift Playground               (4.7)
1504940162  RocketSim for Xcode Simulator  (16.3.0)
1296084683  Cleaner for Xcode              (4.0.6)
6759583690  CodeX : Code AI for Xcode      (1.3)
6761251070  Code: AI App For Xcode         (1.3)
 404009241  BBEdit                         (16.0.2)
1561328879  Assets Maker for Xcode         (3.0)
1450874784  Transporter                    (1.4)
1168397789  Alignment for Xcode            (1.2.0)
1218781096  LanguageTranslator for Xcode   (1.2)
6758531046  Eraser: Cleaner for Xcode      (1.0.7)
6755651521  SimCleaner for Xcode           (1.1)
1457192526  MyUtils for Xcode              (1.5)
1466841314  macOS Catalina                 (10.15.7)
1179234554  TabifyIndents for Xcode        (1.1)
1591155142  Fabula for SwiftUI             (1.2.71)
 734258109  Watchdog for Xcode             (1.9)
1024640650  CotEditor                      (7.0.7)
1528095640  Interactful                    (6.0.5)
6496860953  DockUI: Design for SwiftUI     (2026.3)
1550593510  Cleaner Tool for Xcode         (2.0.0)
1360667102  Character Commands for Xcode   (2021.1)
1380446739  InjectionIII                   (5.1.0)
1524366536  DetailsPro                     (6.19.0)
1377998565  Comment Wrapper for Xcode      (1.1)
1352808762  ActiveCoder                    (2.3)
6443806444  CodeWiki                       (2.8.1)
1176112058  CodeCows                       (1.0.12)
1551475309  Templates for Swift            (1.0)
1218784832  NamingTranslator for Xcode     (1.2)
```

### `mas search com.apple.dt.Xcode --json`

returns ndjson:

``` json
{"adamID":640199958,"advisories":[],"appStorePageURL":"https://apps.apple.com/au/app/apple-developer/id640199958?uo=4","appleTVScreenshotURLs":[],"averageUserRating":2.94118000000000012761347534251399338245391845703125,"averageUserRatingForCurrentVersion":2.94118000000000012761347534251399338245391845703125,"bundleID":"developer.apple.wwdc-Release","categories":["Developer Tools"],"categoryIDs":["6026"],"censoredName":"Apple Developer","contentAdvisoryRating":"4+","contentRating":"4+","currency":"AUD","currentVersionReleaseDate":"2026-06-07T03:00:09Z","description":"Welcome to Apple Developer, your source for developer news, features, and videos — and the best place to experience WWDC.\n\n• Keep up to date on the latest Apple frameworks and technologies.\n• Browse news, features, developer stories, and more.\n• Catch up on videos from past events and download them to watch offline.\n• Enroll in the Apple Developer Program in supported locales.","developerAppStorePageURL":"https://apps.apple.com/au/developer/apple/id284417353?mt=12&uo=4","developerID":284417353,"developerName":"Apple","features":["iosUniversal"],"fileSizeBytes":"9192687","formattedPrice":"Free","iPadScreenshotURLs":[],"icon60URL":"https://is1-ssl.mzstatic.com/image/thumb/Purple221/v4/51/87/9f/51879f8e-158a-2b53-7d7f-d50ea364d236/AppIcon-Release-0-85-220-0-6-0-0-2x-sRGB-0-0-0-0-0.png/60x60bb.jpg","icon100URL":"https://is1-ssl.mzstatic.com/image/thumb/Purple221/v4/51/87/9f/51879f8e-158a-2b53-7d7f-d50ea364d236/AppIcon-Release-0-85-220-0-6-0-0-2x-sRGB-0-0-0-0-0.png/100x100bb.jpg","icon512URL":"https://is1-ssl.mzstatic.com/image/thumb/Purple221/v4/51/87/9f/51879f8e-158a-2b53-7d7f-d50ea364d236/AppIcon-Release-0-85-220-0-6-0-0-2x-sRGB-0-0-0-0-0.png/512x512bb.jpg","isGameCenterEnabled":false,"isVPPDeviceBasedLicensingEnabled":true,"kind":"software","languageCodesISO2A":["EN","FR","JA","KO","PT","ZH","ES"],"minimumOSVersion":"15.0","name":"Apple Developer","originalVersionReleaseDate":"2013-06-03T13:41:42Z","price":0.00,"primaryCategoryID":6026,"primaryCategoryName":"Developer Tools","releaseNotes":"Thank you for your feedback! New in this release:\n\n• Refreshed look with Liquid Glass.\n• List filtering by Unwatched, Bookmarked, and Downloaded, and preferred topics.\n• Video player resizing to fit the window.\n• Improved reliability of image capture during enrollment.\n• Bug fixes and various other enhancements.","screenshotURLs":[],"sellerName":"Apple Pty Limited","sellerURL":"https://developer.apple.com/","supportedDevices":["MacDesktop-MacDesktop"],"userRatingCount":34,"userRatingCountForCurrentVersion":34,"version":"11.0.2","wrapperType":"software"}
{"adamID":1183412116,"appStorePageURL":"https://apps.apple.com/au/app/swiftify-for-xcode/id1183412116?mt=12&uo=4","averageUserRating":4.22222000000000008412825991399586200714111328125,"averageUserRatingForCurrentVersion":4.22222000000000008412825991399586200714111328125,"bundleID":"com.Swiftify.Xcode","categories":["Developer Tools","Productivity"],"categoryIDs":["6026","6007"],"censoredName":"Swiftify for Xcode","contentAdvisoryRating":"4+","contentRating":"4+","currency":"AUD","currentVersionReleaseDate":"2025-09-16T13:57:30Z","description":"To install Swiftify for Xcode in Xcode 26 (or Xcode 16) on macOS Sequoia (or Sonoma):\n• Quit Xcode\n• Launch “Swiftify for Xcode” from your Applications folder and follow the link to get your API key\n• Enable Swiftify extension in System Preferences -> Extensions -> Xcode Source Editor\n• Restart Xcode\n• Use the Editor -> Swiftify menu to convert selection, whole file, or clipboard contents from Objective-C to Swift\n\nImportant: if you don't see the “Xcode Source Editor” menu item under System Preferences -> Extensions, this is most likely due to a corrupt installation of the Xcode itself.\nIf this happens, reinstall both Xcode and Swiftify from the AppStore.\nRefer to https://support.swiftify.com/hc/en-us/articles/360030396531 for more information.\n\nSwiftify for Xcode allows converting your Objective-C code to Swift 6.2 (or 6.1.2) right in Xcode.\nThe app includes Xcode & Finder extensions and the Advanced Project Converter app best suited for gradual project migration.\n\nThe converted code is transferred over an encrypted HTTPS connection and is NEVER stored on our servers!","developerAppStorePageURL":"https://apps.apple.com/au/developer/swiftify-inc/id1183412115?mt=12&uo=4","developerID":1183412115,"developerName":"Swiftify, Inc.","fileSizeBytes":"22817271","formattedPrice":"Free","icon60URL":"https://is1-ssl.mzstatic.com/image/thumb/Purple211/v4/21/b3/82/21b38217-c391-1d2e-7384-b3f5705e2467/AppIcon-0-0-85-220-0-0-5-0-2x.png/60x60bb.png","icon100URL":"https://is1-ssl.mzstatic.com/image/thumb/Purple211/v4/21/b3/82/21b38217-c391-1d2e-7384-b3f5705e2467/AppIcon-0-0-85-220-0-0-5-0-2x.png/100x100bb.png","icon512URL":"https://is1-ssl.mzstatic.com/image/thumb/Purple211/v4/21/b3/82/21b38217-c391-1d2e-7384-b3f5705e2467/AppIcon-0-0-85-220-0-0-5-0-2x.png/512x512bb.png","isVPPDeviceBasedLicensingEnabled":true,"kind":"mac-software","languageCodesISO2A":["EN"],"minimumOSVersion":"13.0","name":"Swiftify for Xcode","originalVersionReleaseDate":"2016-12-20T00:47:49Z","price":0.00,"primaryCategoryID":6026,"primaryCategoryName":"Developer Tools","releaseNotes":"• Added support for Swift 6.2 and Xcode 26\n• Added ability to search across all project files","screenshotURLs":["https://is1-ssl.mzstatic.com/image/thumb/Purple113/v4/af/bb/65/afbb65b3-e679-c901-2947-11976acc53c0/mzl.oweeisze.png/800x500bb.jpg","https://is1-ssl.mzstatic.com/image/thumb/Purple123/v4/91/8b/f0/918bf02d-67ee-e263-d479-de5504e952bf/mzl.gnwwrktq.png/800x500bb.jpg","https://is1-ssl.mzstatic.com/image/thumb/Purple113/v4/ce/31/9f/ce319f33-902e-8522-0242-c03bee04c89e/mzl.xbnqwztc.png/800x500bb.jpg","https://is1-ssl.mzstatic.com/image/thumb/Purple123/v4/1a/02/f8/1a02f803-4df0-7cb6-bc58-40afb17df1f6/mzl.puxhqggk.png/800x500bb.jpg","https://is1-ssl.mzstatic.com/image/thumb/Purple123/v4/06/fe/8a/06fe8ac2-5ad8-7ccf-f494-8a8a0aa38819/pr_source.png/800x500bb.jpg","https://is1-ssl.mzstatic.com/image/thumb/Purple113/v4/72/e9/27/72e92714-9cb3-dbf6-b7e8-fa49b3da1cbc/pr_source.png/800x500bb.jpg"],"sellerName":"Swiftify, Inc.","sellerURL":"https://swiftify.com/swiftify-for-xcode/","userRatingCount":9,"userRatingCountForCurrentVersion":9,"version":"6.2","wrapperType":"software"}
// and so on
```

### `mas search com.apple.dt.Xcode --json | jq -r '[.bundleID, .version] | join(" ")'`

as with all exact searches, there are still plenty of results, with xcode being first as most relevant:

```
developer.apple.wwdc-Release 11.0.2
com.Swiftify.Xcode 6.2
com.oneminutegames.XcodeCleaner 2.8.0
com.apple.PlaygroundsMac 4.7
com.swiftLee.RocketSim 16.3.0
io.hyperapp.XcodeCleaner 4.0.6
com.code.ai.logic.app 1.3
com.codeix.app 1.3
com.barebones.bbedit 16.0.2
com.innovationKid.AssetsMaker 3.0
com.apple.TransporterApp 1.4
com.tid.Alignment-for-Xcode 1.2.0
net.homeunix.hio.app.LanguageTranslator 1.2
app.creatorview.Xplode 1.0.7
stepanok.com.XCode-Devices 1.1
com.sfs.MyUtils 1.5
com.apple.InstallAssistant.Catalina 10.15.7
net.homeunix.hio.app.TabifyIndents 1.1
com.devstore.FabulaLab 1.2.71
com.cerebralgardens.watchdog 1.9
com.coteditor.CotEditor 7.0.7
com.hdthomas.FieldGuide 6.0.5
com.Maicol.Dockui 2026.3
com.aust.xcodeCleaner 2.0.0
com.ifswllc.charcmd 2021.1
com.johnholdsworth.InjectionIII 5.1.0
app.funfocus.DetailsPro 6.19.0
com.stevebarnegren.xcodecommentwrapper 1.1
com.numathic.xb 2.3
felipenipper.CodeWiki 2.8.1
de.zeezide.cows.CodeCows 1.0.12
io.appstudio.UITemplates 1.0
net.homeunix.hio.app.NamingTranslator 1.2
```


### `mas seller --help`

```
OVERVIEW: Open apps' seller pages in the default web browser

USAGE: mas seller [--bundle] <app-id> ...

ARGUMENTS:
  <app-id>                App ID

OPTIONS:
  --bundle                Process all app IDs as bundle IDs
  --version               Show the version.
  -h, --help              Show help information.
```

### `mas signout --help`

```
OVERVIEW: Sign out of the App Store

USAGE: mas signout

OPTIONS:
  --version               Show the version.
  -h, --help              Show help information.
```

### `mas uninstall --help`

```
OVERVIEW: Uninstall apps installed from the App Store

Requires root privileges to uninstall apps

USAGE: mas uninstall [--dry-run] [--all] [--bundle] [<app-id> ...]

ARGUMENTS:
  <app-id>                App ID

OPTIONS:
  --dry-run               Perform dry run
  --all                   Uninstall all App Store apps
  --bundle                Process all app IDs as bundle IDs
  --version               Show the version.
  -h, --help              Show help information.
```

## `mas update`

### `mas update --help`

```
OVERVIEW: Update outdated apps installed from the App Store

Requires root privileges to update apps

USAGE: mas update [--force] [--accurate] [--inaccurate] [--check-min-os] [--no-check-min-os] [--verbose] [--bundle] [<app-id> ...]

ARGUMENTS:
  <app-id>                App ID

OPTIONS:
  --force                 Force reinstall
  --accurate              Use accurate, slower logic that starts then cancels a download
                          for each queried app, which can exceed download limits & which
                          will open dialogs for undownloadable apps
  --inaccurate            Use inaccurate, faster logic that avoids dialogs (default:
                          --inaccurate)
  --check-min-os/--no-check-min-os
                          Check if macOS can install latest app version (default:
                          --check-min-os)
  --verbose               Warn about app IDs unknown to the App Store
  --bundle                Process all app IDs as bundle IDs
  --version               Show the version.
  -h, --help              Show help information.
```

### `mas update com.apple.dt.Xcode`

no output at all, only success exit status, xcode is already updated

### `mas update 1358823008`

prompts for sudo password:

```
Password:
==> Downloading Flighty – Live Flight Tracker (4.10.1)
==> Downloaded Flighty – Live Flight Tracker (4.10.1)
==> Updating Flighty – Live Flight Tracker (4.10.1)
==> Updated Flighty – Live Flight Tracker (4.10.1) in /Applications/Flighty.app
```

### `sudo mas update 302584613`

```
==> Downloading Amazon Kindle: Reading App (7.63)
==> Downloaded Amazon Kindle: Reading App (7.63)
==> Updating Amazon Kindle: Reading App (7.63)
```

### `mas update com.super-productivity.app`

is not currently installed, will error to STDERR and exit status `1`:

```
Error: No installed apps with bundle ID com.super-productivity.app
```

## `mas version`

### `mas version --help`

```
OVERVIEW: Output version number

USAGE: mas version

OPTIONS:
  --version               Show the version.
  -h, --help              Show help information.
```
