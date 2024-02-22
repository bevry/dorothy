# Dorothy

<!-- BADGES/ -->

<span class="badge-githubworkflow"><a href="https://github.com/bevry/dorothy/actions?query=workflow%3Adorothy-workflow" title="View the status of this project's GitHub Workflow: dorothy-workflow"><img src="https://github.com/bevry/dorothy/workflows/dorothy-workflow/badge.svg" alt="Status of the GitHub Workflow: dorothy-workflow" /></a></span>
<br class="badge-separator" />
<span class="badge-githubsponsors"><a href="https://github.com/sponsors/balupton" title="Donate to this project using GitHub Sponsors"><img src="https://img.shields.io/badge/github-donate-yellow.svg" alt="GitHub Sponsors donate button" /></a></span>
<span class="badge-thanksdev"><a href="https://thanks.dev/u/gh/bevry" title="Donate to this project using ThanksDev"><img src="https://img.shields.io/badge/thanksdev-donate-yellow.svg" alt="ThanksDev donate button" /></a></span>
<span class="badge-liberapay"><a href="https://liberapay.com/bevry" title="Donate to this project using Liberapay"><img src="https://img.shields.io/badge/liberapay-donate-yellow.svg" alt="Liberapay donate button" /></a></span>
<span class="badge-buymeacoffee"><a href="https://buymeacoffee.com/balupton" title="Donate to this project using Buy Me A Coffee"><img src="https://img.shields.io/badge/buy%20me%20a%20coffee-donate-yellow.svg" alt="Buy Me A Coffee donate button" /></a></span>
<span class="badge-opencollective"><a href="https://opencollective.com/bevry" title="Donate to this project using Open Collective"><img src="https://img.shields.io/badge/open%20collective-donate-yellow.svg" alt="Open Collective donate button" /></a></span>
<span class="badge-crypto"><a href="https://bevry.me/crypto" title="Donate to this project using Cryptocurrency"><img src="https://img.shields.io/badge/crypto-donate-yellow.svg" alt="crypto donate button" /></a></span>
<span class="badge-paypal"><a href="https://bevry.me/paypal" title="Donate to this project using Paypal"><img src="https://img.shields.io/badge/paypal-donate-yellow.svg" alt="PayPal donate button" /></a></span>
<br class="badge-separator" />
<span class="badge-discord"><a href="https://discord.gg/nQuXddV7VP" title="Join this project's community on Discord"><img src="https://img.shields.io/discord/1147436445783560193?logo=discord&amp;label=discord" alt="Discord server badge" /></a></span>
<span class="badge-twitch"><a href="https://www.twitch.tv/balupton" title="Join this project's community on Twitch"><img src="https://img.shields.io/twitch/status/balupton?logo=twitch" alt="Twitch community badge" /></a></span>

<!-- /BADGES -->

Dorothy is a dotfile ecosystem featuring:

-   seamless support for [Bash](<https://en.wikipedia.org/wiki/Bash_(Unix_shell)>), [Zsh](https://en.wikipedia.org/wiki/Z_shell), [Fish](<https://en.wikipedia.org/wiki/Fish_(Unix_shell)>), [Nu](https://www.nushell.sh), [Xonsh](https://xon.sh), [Elvish](https://elv.sh), [Dash](https://wiki.archlinux.org/title/Dash), [KSH](https://en.wikipedia.org/wiki/KornShell)
-   seamless support for multiple operating systems and architectures
-   seamless support for your favorite terminal and GUI editors
-   automatic configuration of your environment variables for what you have installed on your system
-   automatic installation and updating of your specified packages
-   automatic Git, SSH, and GPG configuration based on what your system supports and your configuration
-   hundreds of [commands](https://github.com/bevry/dorothy/tree/master/commands) to improve your productivity
-   completely extensible and configurable with your own user repository
-   all this together, allows you to go from zero to hero within minutes, instead of days, on a brand new machine

## Introduction

[Watch the 2022 April Presentation to see what Dorothy can do!](https://www.youtube.com/watch?v=gWLana1JmNk)

[![Screenshot of the 2022 April Presentation](https://github.com/bevry/dorothy/blob/master/docs/assets/presentation.gif?raw=true)](https://www.youtube.com/watch?v=gWLana1JmNk)

## Setup

### Supported Platforms

| Operating System                                  | Architecture                                   | Support                  |
| ------------------------------------------------- | ---------------------------------------------- | ------------------------ |
| 🍏 macOS                                          | 🍏 Apple Silicon (ARM64)                       | 👌 Daily Driver          |
| 🍏 macOS                                          | 🍏 Apple on Intel (x86_64)                     | 👌 Daily Driver, 🤖 CI   |
| 🍏 macOS                                          | 🍏 Apple Silicon with `HOMEBREW_ARCH="x86_64"` | 🌗 Monthly Driver        |
| 🪟 Windows 10/11 [WSL2][WSL2] [Ubuntu][UWSL]      | 👔 Intel/AMD (x86_64)                          | 👌 Daily Driver          |
| 🍓 [Raspberry Pi OS with Desktop][RPIOS]          | 🍓 Raspberry Pi 4/400/5 (ARM64)                | 👌 Daily Driver          |
| 🍓 [Raspberry Pi OS Lite][RPIOS]                  | 🍓 Raspberry Pi 4/400/5 (ARM64)                | 🌗 Monthly Driver        |
| ⭕️ [Ubuntu Desktop][URPI]                         | 🍓 Raspberry Pi 4/400/5 (ARM64)                | 👌 Daily Driver          |
| ⭕️ [Ubuntu Desktop][UD]                           | 👔 Intel/AMD (x86_64)                          | 👌 Daily Driver          |
| ⭕️ [Ubuntu Server][URPI]                          | 🍓 Raspberry Pi 4/400/5 (ARM64)                | 👌 Daily Driver          |
| ⭕️ [Ubuntu Server][US]                            | 👔 Intel/AMD (x86_64)                          | 👌 Daily Driver, 🤖 CI   |
| ⭕️ [Ubuntu Server][UV5]                           | 5️⃣ StarFive’s VisionFive (RISC-V)              | 🌗 Monthly Driver        |
| ▲ [Manjaro][M]/[Arch][A]                          | 👔 Intel/AMD (x86_64)                          | 👌 Daily Driver, 🤖 CI   |
| ∞ [Fedora Workstation][FW]                        | 👔 Intel/AMD (x84_64)                          | 🌗 Monthly Driver, 🤖 CI |
| 🦎 [OpenSUSE][OS] [Leap][OSL] & [Tumbleweed][OST] | 👔 Intel/AMD (x84_64)                          | 🌗 Monthly Driver, 🤖 CI |
| ⛰ [Alpine][AL]                                   | 👔 Intel/AMD (x84_64)                          | 🌗 Monthly Driver, 🤖 CI |
| ⛰ [Alpine][AL]                                   | 🍏 Apple Silicon (ARM64)                       | 🌗 Monthly Driver        |
| 🐉 [Kali][K]                                      | 👔 Intel/AMD (x84_64)                          | 🌗 Monthly Driver, 🤖 CI |

[WSL2]: https://docs.microsoft.com/en-au/windows/wsl/
[UWSL]: https://ubuntu.com/wsl
[RPIOS]: https://www.raspberrypi.com/software/operating-systems/
[URPI]: https://ubuntu.com/download/raspberry-pi
[UD]: https://ubuntu.com/download/desktop
[US]: https://ubuntu.com/download/server
[UV5]: https://ubuntu.com/blog/canonical-enables-ubuntu-on-starfives-visionfive-risc-v-boards
[M]: https://manjaro.org/download/
[A]: https://wiki.archlinux.org/title/Installation_guide
[FW]: https://fedoraproject.org/workstation/
[OS]: https://www.opensuse.org
[OSL]: https://get.opensuse.org/leap/
[OST]: https://get.opensuse.org/tumbleweed/
[AL]: https://www.alpinelinux.org/downloads/
[K]: https://www.kali.org/get-kali/#kali-platforms

Other platforms may or may not be supported. [Mageia, Nix, Gentoo are unsupported.](https://github.com/bevry/dorothy/issues/162)

### Prerequisites

macOS:

```bash
xcode-select --install
```

Windows 10/11:

```bash
# [Install WSL.](https://learn.microsoft.com/en-au/windows/wsl/install)
wsl --install
wsl --set-default-version 2
# note that [wsl --version] does not report WSL2, you need to do [wsl -l -v]
```

Ubuntu / Debian / Kali:

```bash
sudo apt-get update
sudo apt-get install bash curl
```

Fedora:

```bash
dnf check-update
dnf --refresh --best install bash curl
```

OpenSUSE / SUSE:

```bash
zypper --gpg-auto-import-keys refresh
zypper install bash curl
```

Alpine:

```bash
doas apk update
doas apk add bash curl grep
```

Manjaro:

```bash
pamac install bash curl
```

Arch:

```bash
pacman-key --init
pacman --refresh --sync --needed bash curl
```

Void:

```bash
xbps-install --sync --update xbps
xbps-install --sync bash curl
```

### Try

You can trial [Dorothy commands](https://github.com/bevry/dorothy/tree/master/commands) without configuring your shell.

To run a specific command in/from the Dorothy environment, enter the following, swapping out everything after the double-dash (`--`) with whatever command to run:

```bash
bash -ic "$(curl -fsSL https://dorothy.bevry.me/run)" -- echo-verbose -- a b c
# if your shell doesn't recognize any of the above syntax, run `bash -i` then try again
```

To run multiple commands in/from a Dorothy-configured REPL, enter the following line by line:

```bash
bash -ic "$(curl -fsSL https://dorothy.bevry.me/repl)"
# if your shell doesn't recognize any of the above syntax, run `bash -i` then try again

# now you can run whatever and how many commands as you'd like, such as:
echo-verbose -- a b c
echo-style --success=awesome

# once you are done, exit the trial environment
exit
```

### Install

To install Dorothy enter the following in your favorite terminal application:

```bash
bash -ic "$(curl -fsSL https://dorothy.bevry.me/install)"
# if your shell doesn't recognize any of the above syntax, run `bash -i` then try again
```

During installation, Dorothy will ask you to create a repository to store your user configuration, such as a `dotfiles` repository. If you already have a dotfiles repository, you can use that, or make another.

Verify the installation worked by selecting a theme for Dorothy by running:

```bash
# you must open a new terminal instance first
dorothy theme
# then open a new terminal
```

To select your login shell, run `setup-shell`.

### Troubleshooting

If packages are failing to install, [go back to the "Prerequisites" section](https://github.com/bevry/dorothy#prerequisites).

If your shell doesn't recognize any of the Dorothy commands (you get a command not found error, or an undefined/unbound variable error), then it could be that:

-   Your shell is not running as a login shell. [Verify that your Terminal is running the shell as a login shell.](https://github.com/bevry/dorothy/blob/master/docs/dorothy/dorothy-not-loading.md)
-   Dorothy did not configure itself for the shell you use. Re-run the Dorothy installation process, and be sure to configure Dorothy for your shell.
-   Your login shell is not one of the Dorothy supported shells. [Create an issue requesting support for your shell.](https://github.com/bevry/dorothy/issues)

If you see unrecognised symbols, you probably require fonts. Once Dorothy is loaded, run `setup-util-noto-emoji` which installed [Noto Emoji](https://github.com/googlefonts/noto-emoji), a font for enabling emojis inside your terminal. For rendering glyphs, run `setup-util-nerd-fonts` which will prompt you for which [Nerd Font](https://www.nerdfonts.com/font-downloads) to install. You may need to update your terminal preferences the installed fonts.

## Overview

### Dorothy Core

Dorothy installs itself to `$DOROTHY`, which defaults to the [XDG](https://wiki.archlinux.org/title/XDG_Base_Directory) location of `~/.local/share/dorothy`, and consists of the following:

-   [`commands` directory](https://github.com/bevry/dorothy/tree/master/commands) contains executable commands of super-stable quality, they are actively used within the Dorothy core and by the users of Dorothy.
-   [`commands.beta` directory](https://github.com/bevry/dorothy/tree/master/commands.beta) contains executable commands of beta quality, these are commands that require more usage or possible breaking changes before promotion to `commands`.
-   [`config` directory](https://github.com/bevry/dorothy/tree/master/config) contains default configuration
-   [`sources` directory](https://github.com/bevry/dorothy/tree/master/sources) contains scripts that are loaded into the shell environment
-   [`themes` directory](https://github.com/bevry/dorothy/tree/master/themes) contains themes that you can select via the `DOROTHY_THEME` environment variable
-   [`user` directory](https://github.com/balupton/dotfiles) is your own github repository for your custom configuration

For each shell that you configured during the Dorothy installation (can be reconfigured via the `dorothy install` command), the configured shell performs the following steps when you open a new shell instance via your terminal:

1.  The shell loads Dorothy's initialization script:

    -   [Elvish](https://elv.sh) loads our [`init.elv`](https://github.com/bevry/dorothy/blob/master/init.elv) script
    -   [Fish](<https://en.wikipedia.org/wiki/Fish_(Unix_shell)>) loads our [`init.fish`](https://github.com/bevry/dorothy/blob/master/init.fish) script
    -   [Nu](https://www.nushell.sh) loads our [`init.nu`](https://github.com/bevry/dorothy/blob/master/init.nu) script
    -   [Xonsh](https://xon.sh) loads our [`init.xsh`](https://github.com/bevry/dorothy/blob/master/init.xsh) script
    -   POSIX shells ([Bash](<https://en.wikipedia.org/wiki/Bash_(Unix_shell)>), [Zsh](https://en.wikipedia.org/wiki/Z_shell), [Dash](https://wiki.archlinux.org/title/Dash), [KSH](https://en.wikipedia.org/wiki/KornShell), etc) load our [`init.sh`](https://github.com/bevry/dorothy/blob/master/init.sh) script

1.  The initialization script will:

    1. Ensure the `DOROTHY` environment variable is set to the location of the Dorothy installation.

    1. If a login shell, it loads our login script `sources/login.(bash|dash|elv|fish|ksh|nu|xsh|zsh)`, which will:

        1. Apply any configuration changes necessary for that login shell
        1. Load our environment script `sources/environment.(bash|dash|elv|fish|ksh|nu|xsh|zsh)`, which will:

            1. Invoke `commands/setup-environment-commands` which determines and applies all necessary environment configuration changes to the shell. It loads your `user/config(.local)/environment.bash` configuration script for your own custom environment configuration that will be applied to all your login shells.

    1. If a login and interactive shell, it loads our interactive script `sources/interactive.(bash|dash|elv|fish|ksh|nu|xsh|zsh)`, which will:

        1. Load your own `user/config(.local)/interactive.(bash|dash|elv|fish|ksh|nu|xsh|zsh)` configuration script for your own interactive login shell configuration.
            - [Elvish](https://elv.sh) will only load `interactive.elv` if it exists.
            - [Fish](<https://en.wikipedia.org/wiki/Fish_(Unix_shell)>) will load `interactive.fish` if it exists, otherwise it will load `interactive.sh`.
            - [Nu](https://www.nushell.sh) will only load `interactive.nu` and it must exist.
            - [Xonsh](https://xon.sh) will only load `interactive.xsh` if it exists.
            - POSIX shells ([Bash](<https://en.wikipedia.org/wiki/Bash_(Unix_shell)>), [Zsh](https://en.wikipedia.org/wiki/Z_shell), [Dash](https://wiki.archlinux.org/title/Dash), [KSH](https://en.wikipedia.org/wiki/KornShell), etc) will load their `interactive.(bash|zsh|...etc)` file if it exists, otherwise they will load `interactive.sh` if exists.
        1. Load any common alias and function utilities.
        1. Load our theme configuration.
        1. Load our ssh configuration.
        1. Load our autocomplete configuration.

This is the foundation that enables Dorothy's hundreds of commands to work across hundreds of machines, across dozens of operating system and shell combinations, seamlessly.

### Dorothy User Configuration

Your user configuration goes to the XDG location of `~/.local/config/dorothy` which Dorothy symlinks to `~/.local/share/dorothy/user`, your user configuration consists of the following:

-   `commands` directory, for public commands
-   `commands.local` directory, for private commands (git ignored by default)
-   `config` directory, for public configuration
-   `config.local` directory, for private configuration (git ignored by default)

The order of preference within Dorothy is `(commands|config).local` first, then `(commands|config)`, then Dorothy's own `(commands|config)` then everything else.

You can find the various configuration files that are available to you by browsing Dorothy's default [`config` directory](https://github.com/bevry/dorothy/tree/master/config).

## Showcase

Use these sources to find inspiration for your own user commands and configuration.

-   [Dorothy's `commands` directory](https://github.com/bevry/dorothy/tree/master/commands) for super-stable commands with up to date conventions.
-   [Dorothy's `commands.beta` directory](https://github.com/bevry/dorothy/tree/master/commands.beta) for beta-quality commands with possibly outdated conventions.
-   [Dorothy's `docs` directory](https://github.com/bevry/dorothy/tree/master/docs) containing tips and tricks for Dorothy, and various shells, such as [enabling private user configurations](https://github.com/bevry/dorothy/blob/master/docs/dorothy/private-configuration.md), and the [manual to assisted](https://github.com/bevry/dorothy/blob/master/docs/dorothy/manual-to-assisted.md) philosophy of Dorothy
-   Dorothy User Configurations:
    -   [@balupton](https://github.com/balupton) / [dotfiles](https://github.com/balupton/dotfiles): uses Fish as login shell, plenty of Bash commands
    -   [@molleweide](https://github.com/molleweide) / [dotfiles](https://github.com/molleweide/dotfiles): uses Zsh as login shell, plenty of Bash commands, kmonad user
    -   [@jondpenton](https://github.com/jondpenton) / [dotfiles](https://github.com/jondpenton/dotfiles): uses Nu as login shell, plenty of Nu commands
    -   if you use Dorothy, send a pull request to add your own user configuration to this list.

After installing Dorothy, there will now a plethora of commands available to you. You can invoke any stable command with `--help` to learn more about it. The most prominent commands are noted below.

Stable commands:

-   [`setup-system`](https://github.com/bevry/dorothy/tree/master/commands/setup-system)

    -   `setup-system install` correctly setup your system to your prompted preferences
    -   `setup-system update` correctly update your system to your existing preferences

    This is done via these commands:

    -   [`setup-linux`](https://github.com/bevry/dorothy/tree/master/commands/setup-linux) correctly setup your Linux system, and its various packaging systems, as desired
    -   [`setup-mac`](https://github.com/bevry/dorothy/tree/master/commands/setup-mac) correctly setup your macOS system, including its homebrew and Mac App Store installations, as desired
    -   [`setup-bin`](https://github.com/bevry/dorothy/tree/master/commands/setup-bin) correctly setup available CLI utilities from installed GUI Applications
    -   [`setup-git`](https://github.com/bevry/dorothy/tree/master/commands/setup-git) correctly setup Git on your system, including your profile, SSH, GPG, and 1Password configurations, as desired.

        Related commands:

        -   [`gpg-helper`](https://github.com/bevry/dorothy/tree/master/commands/gpg-helper) interact with your GPG keys
        -   [`ssh-helper`](https://github.com/bevry/dorothy/tree/master/commands/ssh-helper) interact with your SSH keys

    -   [`setup-go`](https://github.com/bevry/dorothy/tree/master/commands/setup-go) correctly setup GoLang on your system if desired or if required for your desired packages
    -   [`setup-node`](https://github.com/bevry/dorothy/tree/master/commands/setup-node) correctly setup Node.js on your system if desired or if required for your desired packages
    -   [`setup-python`](https://github.com/bevry/dorothy/tree/master/commands/setup-python) correctly setup Python on your system if desired or if required for your desired packages
    -   [`setup-ruby`](https://github.com/bevry/dorothy/tree/master/commands/setup-ruby) correctly setup Ruby on your system if desired or if required for your desired packages
    -   [`setup-rust`](https://github.com/bevry/dorothy/tree/master/commands/setup-rust) correctly setup Rust on your system if desired or if required for your desired packages
    -   [`setup-utils`](https://github.com/bevry/dorothy/tree/master/commands/setup-utils) correctly setup your selected `setup-util-*` utilities as desired

-   [`setup-util`](https://github.com/bevry/dorothy/tree/master/commands/setup-util) is an intelligent wrapper around every package system, allowing a cross-compatible way to install, upgrade, and uninstall utilities.

    It is used by the hundreds of `setup-util-*` commands, which enable installing a utility as easy as invoking `setup-util-<utility>`

    If you don't know which command you need to call, you can use [`get-installer`](https://github.com/bevry/dorothy/tree/master/commands/get-installer) to get which command you will need to invoke to install a utility/binary/application.

-   [`setup-shell`](https://github.com/bevry/dorothy/tree/master/commands/setup-shell) correctly configure your desired shell to be your default shell.

    By default, your terminal application will use the login shell configured for the system, as well as maintain a whitelist of available shells that can function as login shells.

-   [`edit`](https://github.com/bevry/dorothy/tree/master/commands/edit) quickly open a file in your preferred editor, respecting terminal, SSH, and desktop environments.

-   [`down`](https://github.com/bevry/dorothy/tree/master/commands/down) download a file with the best available utility on your computer.

-   [`github-download`](https://github.com/bevry/dorothy/tree/master/commands/github-download) download files from GitHub without the tedium.

-   [`secret`](https://github.com/bevry/dorothy/tree/master/commands/secret) stops you from leaking your env secrets to the world when a malicious program sends your shell environment variables to a remote server. Instead, `secret` will use 1Password to securely expose your secrets to just the command that needs them. Specifically:

    -   secrets are fetched directly from 1Password, with a short lived session
    -   secrets are cached securely for speed and convenience, only root/sudo has access to the cache (cache can be made optional if you want)
    -   secrets are not added to the global environment, only the secrets that are desired for the command are loaded for the command's environment only

-   [`setup-dns`](https://github.com/bevry/dorothy/tree/master/commands/setup-dns) correctly configures your systems DNS to your preferences

    A large security concern these days of using the internet, is the leaking, and potential of modification of your DNS queries. A DNS query is what turns `google.com` to say `172.217.167.110`. With un-encrypted DNS (the default), your ISP, or say that public Wifi provider, can intercept these queries to find out what websites you are visiting, and they can even rewrite these queries, to direct you elsewhere. This is how many public Wifi providers offer their service for free, by selling the data they collect on you, or worse.

    The solution to this is encrypted DNS. Some VPN providers already include it within their service, however most don't. And if you have encrypted DNS, then you get the benefits of preventing eavesdropping without the need for expensive VPN, and the risk of your VPN provider eavesdropping on you.

    Dorothy supports configuring your DNS to encrypted DNS via the [`setup-dns`](https://github.com/bevry/dorothy/tree/master/commands/setup-dns) command, which includes installation and configuration for any of these:

    -   AdGuard Home
    -   Cloudflared
    -   DNSCrypt

    Related commands:

    -   [`flush-dns`](https://github.com/bevry/dorothy/tree/master/commands/flush-dns) lets you easily flush your DNS anytime, any system.
    -   [`setup-hosts`](https://github.com/bevry/dorothy/tree/master/commands/setup-hosts) lets you easily select from a variety of HOSTS files for security and privacy, while maintaining your customizations.

Beta commands:

-   [`mail-sync`](https://github.com/bevry/dorothy/tree/master/commands.beta/mail-sync) helps you migrate all your emails from one cloud provider to another.

### macOS

Stable commands:

-   [`alias-helper`](https://github.com/bevry/dorothy/tree/master/commands/alias-helper) helps you manage your macOS aliases, and if desired, convert them into symlinks.
-   [`macos-drive`](https://github.com/bevry/dorothy/tree/master/commands/macos-drive) helps you turn a macOS installer into a bootable USB drive.
-   [`macos-installer`](https://github.com/bevry/dorothy/tree/master/commands/macos-installer) fetches the latest macOS installer.
-   [`sparse-vault`](https://github.com/bevry/dorothy/tree/master/commands/sparse-vault) lets you easily, and for free, create secure encrypted password-protected vaults on your mac, for securing those super secret data.

Beta commands:

-   [`eject-all`](https://github.com/bevry/dorothy/tree/master/commands.beta/eject-all) eject all removable drives safely.
-   [`icloud-helper`](https://github.com/bevry/dorothy/tree/master/commands.beta/icloud-helper) can free up space for time machine by evicting local iCloud caches.
-   [`itunes-owners`](https://github.com/bevry/dorothy/tree/master/commands.beta/itunes-owners) generates a table of who legally owns what inside your iTunes Media Library — which is useful for debugging certain iTunes Store authorization issues, which can occur upon backup restorations.
-   [`macos-settings`](https://github.com/bevry/dorothy/tree/master/commands.beta/macos-settings) helps configure macOS to your preferred system preferences.
-   [`macos-state`](https://github.com/bevry/dorothy/tree/master/commands.beta/macos-state) helps you backup and restore your various application and system preferences, from time machine backups, local directories, and sftp locations. This makes setting up clean installs easy, as even the configuration is automated. And it also helps you never forget an important file, like your env secrets ever again.
-   [`macos-theme`](https://github.com/bevry/dorothy/tree/master/commands.beta/macos-theme) helps you change your macOS theme to your preference, including your wallpaper and editor.
-   [`tmutil-helper`](https://github.com/bevry/dorothy/tree/master/commands.beta/tmutil-helper) can free up space for bootcamp by evicting local Time Machine caches.

### media

Beta commands:

-   [`get-codec`](https://github.com/bevry/dorothy/tree/master/commands.beta/get-codec) gets the codec of a media file
-   [`is-audio-mono`](https://github.com/bevry/dorothy/tree/master/commands.beta/is-audio-mono) checks if an audio file is mono
-   [`is-audio-stereo`](https://github.com/bevry/dorothy/tree/master/commands.beta/is-audio-stereo) checks if an audio file is stereo
-   [`pdf-decrypt`](https://github.com/bevry/dorothy/tree/master/commands.beta/pdf-decrypt) will mass decrypt encrypted PDFs.
-   [`pdf-decrypt`](https://github.com/bevry/dorothy/tree/master/commands.beta/pdf-encrypt) decrypts a PDF file
-   [`podcast`](https://github.com/bevry/dorothy/tree/master/commands.beta/podcast) will convert an audio file to a new file with Apple's recommended podcast encoding and settings `aac-he`, which is super optimized for podcast use cases with tiny file sizes and the same quality.
-   [`podvideo`](https://github.com/bevry/dorothy/tree/master/commands.beta/podvideo) will convert a video file to a new file with h264+aac encoding.
-   [`svg-export`](https://github.com/bevry/dorothy/tree/master/commands.beta/svg-export) converts an SVG image into a desired image format
-   [`to-png`](https://github.com/bevry/dorothy/tree/master/commands.beta/to-png) coverts various image formats to PNG
-   [`trim-audio`](https://github.com/bevry/dorothy/tree/master/commands.beta/trim-audio) trims superfluous audio-streams from a video file
-   [`video-merge`](https://github.com/bevry/dorothy/tree/master/commands.beta/video-merge) will merge multiple video files in a directory together into a single video file.
-   [`wallhaven-helper`](https://github.com/bevry/dorothy/tree/master/commands.beta/wallhaven-helper) download your wallpaper collections from [Wallhaven](https://wallhaven.cc)
-   [`xps2pdf`](https://github.com/bevry/dorothy/tree/master/commands.beta/xps2pdf) will convert a legacy XPS document into a modern PDF document.
-   [`ytd-helper`](https://github.com/bevry/dorothy/tree/master/commands.beta/ytd-helper) helps you download videos from the internet with simplified options.

## Community

Join the [Bevry Software community](https://discord.gg/nQuXddV7VP) to stay up-to-date on the latest Dorothy developments and to get in touch with the rest of the community.

<!-- BACKERS/ -->

## Backers

### Code

[Discover how to contribute via the `CONTRIBUTING.md` file.](https://github.com/bevry/dorothy/blob/HEAD/CONTRIBUTING.md#files)

#### Authors

-   [Benjamin Lupton](https://balupton.com) — Accelerating collaborative wisdom.

#### Maintainers

-   [Benjamin Lupton](https://balupton.com) — Accelerating collaborative wisdom.

#### Contributors

-   [Benjamin Lupton](https://github.com/balupton) — [view contributions](https://github.com/bevry/dorothy/commits?author=balupton 'View the GitHub contributions of Benjamin Lupton on repository bevry/dorothy')
-   [Bevry Team](https://github.com/BevryMe) — [view contributions](https://github.com/bevry/dorothy/commits?author=BevryMe 'View the GitHub contributions of Bevry Team on repository bevry/dorothy')
-   [BJReplay](https://github.com/BJReplay) — [view contributions](https://github.com/bevry/dorothy/commits?author=BJReplay 'View the GitHub contributions of BJReplay on repository bevry/dorothy')
-   [molleweide](https://github.com/molleweide) — [view contributions](https://github.com/bevry/dorothy/commits?author=molleweide 'View the GitHub contributions of molleweide on repository bevry/dorothy')
-   [Nutchanon Ninyawee](https://github.com/wasdee) — [view contributions](https://github.com/bevry/dorothy/commits?author=wasdee 'View the GitHub contributions of Nutchanon Ninyawee on repository bevry/dorothy')
-   [Sumit Rai](https://github.com/sumitrai) — [view contributions](https://github.com/bevry/dorothy/commits?author=sumitrai 'View the GitHub contributions of Sumit Rai on repository bevry/dorothy')

### Finances

<span class="badge-githubsponsors"><a href="https://github.com/sponsors/balupton" title="Donate to this project using GitHub Sponsors"><img src="https://img.shields.io/badge/github-donate-yellow.svg" alt="GitHub Sponsors donate button" /></a></span>
<span class="badge-thanksdev"><a href="https://thanks.dev/u/gh/bevry" title="Donate to this project using ThanksDev"><img src="https://img.shields.io/badge/thanksdev-donate-yellow.svg" alt="ThanksDev donate button" /></a></span>
<span class="badge-liberapay"><a href="https://liberapay.com/bevry" title="Donate to this project using Liberapay"><img src="https://img.shields.io/badge/liberapay-donate-yellow.svg" alt="Liberapay donate button" /></a></span>
<span class="badge-buymeacoffee"><a href="https://buymeacoffee.com/balupton" title="Donate to this project using Buy Me A Coffee"><img src="https://img.shields.io/badge/buy%20me%20a%20coffee-donate-yellow.svg" alt="Buy Me A Coffee donate button" /></a></span>
<span class="badge-opencollective"><a href="https://opencollective.com/bevry" title="Donate to this project using Open Collective"><img src="https://img.shields.io/badge/open%20collective-donate-yellow.svg" alt="Open Collective donate button" /></a></span>
<span class="badge-crypto"><a href="https://bevry.me/crypto" title="Donate to this project using Cryptocurrency"><img src="https://img.shields.io/badge/crypto-donate-yellow.svg" alt="crypto donate button" /></a></span>
<span class="badge-paypal"><a href="https://bevry.me/paypal" title="Donate to this project using Paypal"><img src="https://img.shields.io/badge/paypal-donate-yellow.svg" alt="PayPal donate button" /></a></span>

#### Sponsors

-   [Andrew Nesbitt](https://nesbitt.io) — Software engineer and researcher
-   [Codecov](https://codecov.io) — Empower developers with tools to improve code quality and testing.
-   [Frontend Masters](https://FrontendMasters.com) — The training platform for web app engineering skills – from front-end to full-stack! 🚀
-   [Poonacha Medappa](https://poonachamedappa.com)
-   [Rob Morris](https://github.com/Rob-Morris)
-   [Sentry](https://sentry.io) — Real-time crash reporting for your web apps, mobile apps, and games.
-   [Syntax](https://syntax.fm) — Syntax Podcast

#### Donors

-   [Andrew Nesbitt](https://nesbitt.io)
-   [Balsa](https://balsa.com)
-   [Chad](https://opencollective.com/chad8)
-   [Codecov](https://codecov.io)
-   [entroniq](https://gitlab.com/entroniq)
-   [Frontend Masters](https://FrontendMasters.com)
-   [Jean-Luc Geering](https://github.com/jlgeering)
-   [Michael Duane Mooring](https://mdm.cc)
-   [Mohammed Shah](https://github.com/smashah)
-   [Mr. Henry](https://mrhenry.be)
-   [Poonacha Medappa](https://poonachamedappa.com)
-   [Rob Morris](https://github.com/Rob-Morris)
-   [Sentry](https://sentry.io)
-   [ServieJS](https://github.com/serviejs)
-   [Syntax](https://syntax.fm)

<!-- /BACKERS -->

<!-- LICENSE/ -->

## License

Unless stated otherwise all works are:

-   Copyright &copy; [Benjamin Lupton](https://balupton.com)

and licensed under:

-   [Reciprocal Public License 1.5](http://spdx.org/licenses/RPL-1.5.html)

<!-- /LICENSE -->
