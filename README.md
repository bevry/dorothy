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

- 🐚 seamless support for [Bash](<https://en.wikipedia.org/wiki/Bash_(Unix_shell)>), [Zsh](https://en.wikipedia.org/wiki/Z_shell), [Fish](<https://en.wikipedia.org/wiki/Fish_(Unix_shell)>), [Nu](https://www.nushell.sh), [Xonsh](https://xon.sh), [Elvish](https://elv.sh), [Dash](https://wiki.archlinux.org/title/Dash), [KSH](https://en.wikipedia.org/wiki/KornShell)
- 🩻 seamless support for multiple operating systems and architectures
- 👩‍💻 seamless support for your favorite terminal and GUI editors
- 🦾 automatic configuration of your environment variables for what you have installed on your system
- 📦 automatic installation and updating of your specified packages
- 🌳 automatic Git, SSH, and GPG configuration based on what your system supports and your configuration
- ☄️ hundreds of [commands](https://github.com/bevry/dorothy/tree/master/commands) to improve your productivity
- ⚙️ completely extensible and configurable with your own user repository
- 🦸‍♀️ all this together, allows you to go from zero to hero within minutes, instead of days, on a brand new machine

## Introduction

[Watch the 2023 November Presentation to see what Dorothy can do!](https://youtu.be/EdoN9rQ2S4w)

[![Screenshot of the 2022 April Presentation](https://github.com/bevry/dorothy/blob/master/docs/assets/presentation.gif?raw=true)](https://youtu.be/EdoN9rQ2S4w)

## Setup

### Supported Platforms

<!-- Sorted arch relevance, then by alpha -->

| Operating System                                                                                               | Architecture             | Support |
| -------------------------------------------------------------------------------------------------------------- | ------------------------ | ------- |
| 🍏 macOS                                                                                                       | 🍏 Apple Silicon (ARM64) | 🤖 CI   |
| 🍏 macOS                                                                                                       | 👔 Intel/AMD (x86_64)    | 🤖 CI   |
| 🍓 [Raspberry Pi OS][PiOS]: [Desktop][PiOSDownload], [Lite][PiOSDownload]                                      | 🍓 Raspberry Pi (ARM64)  | 🤖 CI   |
| 🪟 Windows 10/11 [WSL2][WSL2]: [Ubuntu][UbuntuWSL], [Debian][DebianWSL], [AlmaLinux][AlmaWSL], [Kali][KaliWSL] | 👔 Intel/AMD (x86_64)    | 🤖 CI   |
| 👐 [AlmaLinux][AlmaLinux]                                                                                      | 👔 Intel/AMD (x86_64)    | 🤖 CI   |
| 👐 [AlmaLinux on Raspberry Pi][AlmaLinuxPi]                                                                    | 🍓 Raspberry Pi (ARM64)  | 🤖 CI   |
| ▲ [Arch][Arch]                                                                                                 | 👔 Intel/AMD (x86_64)    | 🤖 CI   |
| ![CachyOSLogo][CachyOSLogo] [CachyOS][CachyOS]                                                                 | 👔 Intel/AMD (x86_64)    | 🤖 CI   |
| ꩜ [Debian][Debian]                                                                                             | 👔 Intel/AMD (x86_64)    | 🤖 CI   |
| ꩜ [Debian on Raspberry Pi][DebianPi]                                                                           | 🍓 Raspberry Pi (ARM64)  | 🤖 CI   |
| 💫 [Devuan][Devuan]                                                                                            | 👔 Intel/AMD (x86_64)    | 🤖 CI   |
| 𝓮 [elementary OS][elementaryOS]                                                                                | 👔 Intel/AMD (x86_64)    | 🤖 CI   |
| ∞ [Fedora][Fedora]: [Workstation][FedoraW], [Server][FedoraS]                                                  | 👔 Intel/AMD (x84_64)    | 🤖 CI   |
| ∞ [Fedora on Raspberry Pi][FedoraPi]: [Workstation][FedoraW], [Server][FedoraS]                                | 🍓 Raspberry Pi (ARM64)  | 🤖 CI   |
| 🐉 [Kali][Kali]                                                                                                | 👔 Intel/AMD (x84_64)    | 🤖 CI   |
| 🐉 [Kali on ARM][KaliARM]                                                                                      | 🍓 Raspberry Pi (ARM64)  | 🤖 CI   |
| 𝚖 [Manjaro][Manjaro]                                                                                           | 👔 Intel/AMD (x86_64)    | 🤖 CI   |
| 𝚖 [Manjaro on ARM][ManjaroARM]                                                                                 | 🍓 Raspberry Pi (ARM64)  | 🤖 CI   |
| ![OpenEulerLogo][OpenEulerLogo] [OpenEuler][OpenEuler]                                                         | 👔 Intel/AMD (x84_64)    | 🤖 CI   |
| ![OpenEulerLogo][OpenEulerLogo] [OpenEuler on Raspberry Pi][OpenEulerPi]                                       | 🍓 Raspberry Pi (ARM64)  | 🤖 CI   |
| ❍ [OpenMandriva][Mandriva]: [Rock][MandrivaRock], [Rolling][MandrivaRolling]                                   | 👔 Intel/AMD (x86_64)    | 🤖 CI   |
| 🦎 [OpenSUSE][SUSE]: [Leap][SUSELeap], [Tumbleweed][SUSETumbleweed]                                            | 👔 Intel/AMD (x84_64)    | 🤖 CI   |
| 🦎 [OpenSUSE on Raspberry Pi][SUSEPi]: [Leap][SUSELeap], [Tumbleweed][SUSETumbleweed]                          | 🍓 Raspberry Pi (ARM64)  | 🤖 CI   |
| ⭕️ [Ubuntu][Ubuntu]: [Desktop][UbuntuD], [Server][UbuntuS]                                                     | 👔 Intel/AMD (x86_64)    | 🤖 CI   |
| ⭕️ [Ubuntu on Raspberry Pi][UbuntuPi]: Desktop, Server                                                         | 🍓 Raspberry Pi (ARM64)  | 🤖 CI   |
| ⭐ [Vanilla][Vanilla]                                                                                          | 👔 Intel/AMD (x86_64)    | 🤖 CI   |

<!-- Sorted alphabetically -->

[AlmaLinux]: https://almalinux.org
[AlmaLinuxPi]: https://wiki.almalinux.org/documentation/raspberry-pi.html
[AlmaWSL]: https://apps.microsoft.com/search/publisher?name=AlmaLinux+OS+Foundation
[Arch]: https://wiki.archlinux.org/title/Arch_Linux
[CachyOS]: https://cachyos.org/download/
[CachyOSLogo]: docs/assets/cachyos.svg
[Debian]: https://www.debian.org
[DebianPi]: https://raspi.debian.net
[DebianWSL]: https://apps.microsoft.com/detail/9msvkqc78pk6
[Devuan]: https://www.devuan.org
[elementaryOS]: https://elementary.io
[Fedora]: https://fedoraproject.org
[FedoraPi]: https://docs.fedoraproject.org/en-US/quick-docs/raspberry-pi/
[FedoraS]: https://fedoraproject.org/server/
[FedoraW]: https://fedoraproject.org/workstation/
[Kali]: https://www.kali.org/get-kali/#kali-platforms
[KaliARM]: https://www.kali.org/docs/arm/
[KaliWSL]: https://apps.microsoft.com/detail/9pkr34tncv07
[Mandriva]: https://www.openmandriva.org
[MandrivaRock]: https://wiki.openmandriva.org/en/distribution/releases/omlx60
[MandrivaRolling]: https://wiki.openmandriva.org/en/distribution/releases/rome
[Manjaro]: https://manjaro.org/download/
[ManjaroARM]: https://manjaro.org/products/download/arm
[OpenEuler]: https://www.openeuler.org/en/download/
[OpenEulerLogo]: docs/assets/openeuler.svg
[OpenEulerPi]: https://www.openeuler.org/en/wiki/install/raspberry-pi/
[PiOS]: https://www.raspberrypi.com/documentation/computers/os.html
[PiOSDownload]: https://www.raspberrypi.com/software/operating-systems/
[SUSE]: https://www.opensuse.org
[SUSELeap]: https://get.opensuse.org/leap/
[SUSEPi]: https://en.opensuse.org/HCL:Raspberry_Pi
[SUSETumbleweed]: https://get.opensuse.org/tumbleweed/
[Ubuntu]: https://ubuntu.com
[UbuntuD]: https://ubuntu.com/download/desktop
[UbuntuPi]: https://ubuntu.com/download/raspberry-pi
[UbuntuS]: https://ubuntu.com/download/server
[UbuntuWSL]: https://apps.microsoft.com/detail/9pdxgncfsczv
[Vanilla]: https://vanillaos.org
[WSL2]: https://docs.microsoft.com/en-au/windows/wsl/

<!--
Previously supported, but support broke.

| ⭕️ [Ubuntu Server][UbuntuFive]                           | 5️⃣ StarFive’s VisionFive (RISC-V)              | 🌗 Monthly Driver        |
| ⛰ [Alpine][Alpine]                                   | 👔 Intel/AMD (x84_64)                          | 🌗 Monthly Driver, 🤖 CI |
| ⛰ [Alpine][Alpine]                                   | 🍏 Apple Silicon (ARM64)                       | 🌗 Monthly Driver        |

[UbuntuFive]: https://ubuntu.com/blog/canonical-enables-ubuntu-on-starfives-visionfive-risc-v-boards
[Alpine]: https://www.alpinelinux.org/downloads/
[Rocky]: https://rockylinux.org
-->

Other platforms may or may not be supported. [Mageia, Nix, Gentoo are unsupported.](https://github.com/bevry/dorothy/issues/162)

### Dependencies

Dorothy has intelligent dependency management with its own [`setup-util`](https://github.com/bevry/dorothy/blob/master/commands/setup-util) command and `setup-util-*` ecosystem, that automates and assists dependency and package availability across platforms, architectures, and package systems.

Dependencies that are required to achieve your intended goal, will have their installations initiated correctly. Dependencies that are not required, but provide a superior experience, will have their installations attempted but if an installation fails or is unavailable, the command will not dazzle but will still execute successfully to satisfaction. Sometimes commands can go an extra mile if a dependency is detected, such as for performance or gathering additional optional information, however, if an already suitable dependency is already available then the suitable installed dependency will be used. This enables Dorothy to provide extreme robustness and superiority of its experience.

For instance, installing [curl](https://en.wikipedia.org/wiki/Curl) with Dorothy is as easy as executing [`setup-util-curl`](https://github.com/bevry/dorothy/blob/master/commands/setup-util-curl), or directly by `setup-util --cli=curl APK=curl APT=curl AUR=curl BREW=curl RPM=curl WINGET=cURL ZYPPER=curl`. If you want to make it optional, add `--optional`. If you want to write a command that prefers `curl` but also supports `wget` if curl isn't present, see Dorothy's [`fetch`](https://github.com/bevry/dorothy/blob/master/commands/fetch) command, or for something even more powerful, see Dorothy's [`down`](https://github.com/bevry/dorothy/blob/master/commands/down) command.

### Prerequisites

> [!IMPORTANT]
> To initiate Dorothy, some prerequisite dependencies are required:

macOS:

```bash
xcode-select --install
```

Windows 10/11:

```bash
# https://learn.microsoft.com/en-au/windows/wsl/install
wsl.exe --install --no-distribution
# wsl.exe --set-default-version 2
wsl.exe --list --online
wsl.exe --install # -d Debian
# wsl.exe --set-default Debian
wsl.exe --list --verbose
# wsl.exe --unregister Debian # do not use --uninstall, that removes WSL
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
doas apk add bash curl
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

#### Requisites

Now that the prerequisites are installed, Dorothy's intelligent dependency management will be enabled, so you can skip this section. Dorothy's complete requisites for its core experience are as follows:

- [`bash`](https://release-monitoring.org/project/166/), [`curl`](https://release-monitoring.org/project/381/): required prior to initiation of the Dorothy installer
- [`grep`](https://release-monitoring.org/project/1251/), [`git`](https://git-scm.com/downloads), [`awk`](https://release-monitoring.org/project/868/): guaranteed by the Dorothy installer, and used to to install Dorothy
- [`jq`](https://jqlang.github.io/jq/download/), [`deno`](https://deno.com/#installation): guaranteed by Dorothy, for robust regular expressions and configuration management

If the automated installation of any failed, [post an issue](https://github.com/bevry/dorothy/issues) including details of your environment, and use their links for alternative installation methods. If you are downloading their binaries straight from GitHub, you can unzip with `tar -xvf <archive>`, make a discoverable binary directory with `mkdir -p -- ~/.local/bin`, move the binary there with `mv -- <bin> ~/.local/bin`, and make the binaries executable with `chmod +x ~/.local/bin/*`.

### Try

> [!TIP]
> You can trial [Dorothy commands](https://github.com/bevry/dorothy/tree/master/commands) without configuring your shell:

To run a specific command in/from the Dorothy environment, enter the following, swapping out everything after the double-dash (`--`) with whatever command to run:

```bash
bash -i # in case your shell doesn't recognize the next command
bash -ic "$(curl -fsSL https://dorothy.bevry.me/run)" -- dorothy commands
```

To run multiple commands in/from a Dorothy-configured REPL, enter the following line by line:

```bash
bash -i # in case your shell doesn't recognize the next command
bash -ic "$(curl -fsSL https://dorothy.bevry.me/repl)"

# now you can run whatever and how many commands as you'd like, such as:
dorothy commands
echo-style --success=awesome

# once you are done, exit the trial environment
exit
```

### Install

> [!IMPORTANT]
> To install Dorothy enter the following into your favorite terminal application:

```bash
bash -i # in case your shell doesn't recognize the next command
bash -ic "$(curl -fsSL https://dorothy.bevry.me/install)"
```

During installation, Dorothy will ask you to create a repository to store your user configuration, such as a `dotfiles` repository. If you already have a dotfiles repository, you can use that, or make another.

Once installation has completed, open a new terminal instance such that Dorothy is loaded with the new configuration applied. In the new terminal instance, verify the installation and configuration was successful by running `dorothy commands`, which will list all the Dorothy commands available to you.

### Troubleshooting

If packages are failing to install, [go back to the "Prerequisites" section](https://github.com/bevry/dorothy#prerequisites).

If your shell doesn't recognize any of the Dorothy commands (you get a command not found error, or an undefined/unbound variable error), then it could be that:

- Your shell is not running as a login shell. [Verify that your Terminal is running the shell as a login shell.](https://github.com/bevry/dorothy/blob/master/docs/dorothy/dorothy-not-loading.md)
- Dorothy did not configure itself for the shell you use. Re-run the Dorothy installation process, and be sure to configure Dorothy for your shell.
- Your login shell is not one of the Dorothy supported shells. [Create an issue requesting support for your shell.](https://github.com/bevry/dorothy/issues)

If you see unrecognised symbols, you probably require fonts. Once Dorothy is loaded, run `setup-util-noto-emoji` which installs [Noto Emoji](https://github.com/googlefonts/noto-emoji), a font for enabling emojis inside your terminal. For rendering glyphs, run `setup-util-nerd-fonts` which will prompt you for which [Nerd Font](https://www.nerdfonts.com/font-downloads) to install. You may need to update your terminal preferences to leverage these installed fonts.

If you are using Visual Studio Code, due to a [`#wontfix` bug](https://github.com/microsoft/vscode/issues/267565) in their terminal rendering you will need `"terminal.integrated.minimumContrastRatio": 1` in your settings to fix background colours disabling foreground colours (this is automatically applied to the `dorothy edit` workspace). Visual Studio Code also has another [`#wontfix` bug](https://github.com/xtermjs/xterm.js/issues/734) where tab characters are converted to spaces, preventing their copying, without a workaround.

## Overview

### Dorothy Core

Dorothy installs itself to `$DOROTHY`, which defaults to the [XDG](https://wiki.archlinux.org/title/XDG_Base_Directory) location of `~/.local/share/dorothy`, and consists of the following:

- [`commands` directory](https://github.com/bevry/dorothy/tree/master/commands) contains executable commands of super-stable quality, they are actively used within the Dorothy core and by the users of Dorothy.
- [`commands.beta` directory](https://github.com/bevry/dorothy/tree/master/commands.beta) contains executable commands of beta quality, these are commands that require more usage or possible breaking changes before promotion to `commands`.
- [`config` directory](https://github.com/bevry/dorothy/tree/master/config) contains default configuration
- [`sources` directory](https://github.com/bevry/dorothy/tree/master/sources) contains scripts that are loaded into the shell environment
- [`themes` directory](https://github.com/bevry/dorothy/tree/master/themes) contains themes that you can select via the `DOROTHY_THEME` environment variable
- [`user` directory](https://github.com/balupton/dotfiles) is your own github repository for your custom configuration

For each shell that you configured during the Dorothy installation (can be reconfigured via the `dorothy install` command), the configured shell performs the following steps when you open a new shell instance via your terminal:

1.  The shell loads Dorothy's initialization script:
    - [Elvish](https://elv.sh) loads our [`init.elv`](https://github.com/bevry/dorothy/blob/master/init.elv) script
    - [Fish](<https://en.wikipedia.org/wiki/Fish_(Unix_shell)>) loads our [`init.fish`](https://github.com/bevry/dorothy/blob/master/init.fish) script
    - [Nu](https://www.nushell.sh) loads our [`init.nu`](https://github.com/bevry/dorothy/blob/master/init.nu) script
    - [Xonsh](https://xon.sh) loads our [`init.xsh`](https://github.com/bevry/dorothy/blob/master/init.xsh) script
    - POSIX shells ([Bash](<https://en.wikipedia.org/wiki/Bash_(Unix_shell)>), [Zsh](https://en.wikipedia.org/wiki/Z_shell), [Dash](https://wiki.archlinux.org/title/Dash), [KSH](https://en.wikipedia.org/wiki/KornShell), etc) load our [`init.sh`](https://github.com/bevry/dorothy/blob/master/init.sh) script
        - KSH and Dash first load their respective `init.ksh` and `init.dash` scripts before loading `init.sh`. This is because KSH, Dash, and Bash all share the same `.profile` configuration file, so different initialization scripts allow us to configure each of them independently.

1.  The initialization script will:
    1. Ensure the `DOROTHY` environment variable is set to the location of the Dorothy installation.

    1. If a login shell, it loads our login script `sources/login.(bash|dash|elv|fish|ksh|nu|xsh|zsh)`, which will:
        1. Apply any configuration changes necessary for that login shell
        1. Load our environment script `sources/environment.(bash|dash|elv|fish|ksh|nu|xsh|zsh)`, which will:
            1. Invoke `commands/setup-environment-commands` which determines and applies all necessary environment configuration changes to the shell. It loads your `user/config(.local)/environment.bash` configuration script for your own custom environment configuration that will be applied to all your login shells.

    1. If a login and interactive shell, it loads our interactive script `sources/interactive.(bash|dash|elv|fish|ksh|nu|xsh|zsh)`, which will:
        1. Load your own `user/config(.local)/interactive.(sh|bash|dash|elv|fish|ksh|nu|xsh|zsh)` configuration script for your own interactive login shell configuration.
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

- `commands` directory, for public commands
- `commands.local` directory, for private commands (git ignored by default)
- `config` directory, for public configuration
- `config.local` directory, for private configuration (git ignored by default)

The order of preference within Dorothy is `(commands|config).local` first, then `(commands|config)`, then Dorothy's own `(commands|config)` then everything else.

You can find the various configuration files that are available to you by browsing Dorothy's default [`config` directory](https://github.com/bevry/dorothy/tree/master/config).

## Showcase

Use these sources to find inspiration for your own user commands and configuration.

- [Dorothy's `commands` directory](https://github.com/bevry/dorothy/tree/master/commands) for super-stable commands with up to date conventions.
- [Dorothy's `commands.beta` directory](https://github.com/bevry/dorothy/tree/master/commands.beta) for beta-quality commands with possibly outdated conventions.
- [Dorothy's `docs` directory](https://github.com/bevry/dorothy/tree/master/docs) containing tips and tricks for Dorothy, and various shells, such as [enabling private user configurations](https://github.com/bevry/dorothy/blob/master/docs/dorothy/private-configuration.md), and the [manual to assisted](https://github.com/bevry/dorothy/blob/master/docs/dorothy/manual-to-assisted.md) philosophy of Dorothy
- Dorothy User Configurations:
    - [@balupton](https://github.com/balupton) / [dotfiles](https://github.com/balupton/dotfiles): uses Bash as login shell, plenty of Bash commands
    - [@molleweide](https://github.com/molleweide) / [dotfiles](https://github.com/molleweide/dotfiles): uses Zsh as login shell, plenty of Bash commands, kmonad user
    - [@jondpenton](https://github.com/jondpenton) / [dotfiles](https://github.com/jondpenton/dotfiles): uses Nu as login shell, plenty of Nu commands
    - [See more Dorothy User Configurations](https://github.com/stars/balupton/lists/dorothy-user-configurations)
    - To feature your own Dorothy User Configuration, send a pull request.

After installing Dorothy, there will now a plethora of commands available to you. You can invoke any stable command with `--help` to learn more about it. The most prominent commands are noted below.

Stable commands:

- [`setup-system`](https://github.com/bevry/dorothy/tree/master/commands/setup-system)
    - `setup-system install` correctly setup your system to your prompted preferences
    - `setup-system update` correctly update your system to your existing preferences

    This is done via these commands:
    - [`setup-linux`](https://github.com/bevry/dorothy/tree/master/commands/setup-linux) correctly setup your Linux system, and its various packaging systems, as desired
    - [`setup-mac`](https://github.com/bevry/dorothy/tree/master/commands/setup-mac) correctly setup your macOS system, including its homebrew and Mac App Store installations, as desired
    - [`setup-bin`](https://github.com/bevry/dorothy/tree/master/commands/setup-bin) correctly setup available CLI utilities from installed GUI Applications
    - [`setup-git`](https://github.com/bevry/dorothy/tree/master/commands/setup-git) correctly setup Git on your system, including your profile, SSH, GPG, and 1Password configurations, as desired.

        Related commands:
        - [`gpg-helper`](https://github.com/bevry/dorothy/tree/master/commands/gpg-helper) interact with your GPG keys
        - [`ssh-helper`](https://github.com/bevry/dorothy/tree/master/commands/ssh-helper) interact with your SSH keys

    - [`setup-go`](https://github.com/bevry/dorothy/tree/master/commands/setup-go) correctly setup GoLang on your system if desired or if required for your desired packages
    - [`setup-node`](https://github.com/bevry/dorothy/tree/master/commands/setup-node) correctly setup Node.js on your system if desired or if required for your desired packages
    - [`setup-python`](https://github.com/bevry/dorothy/tree/master/commands/setup-python) correctly setup Python on your system if desired or if required for your desired packages
    - [`setup-ruby`](https://github.com/bevry/dorothy/tree/master/commands/setup-ruby) correctly setup Ruby on your system if desired or if required for your desired packages
    - [`setup-rust`](https://github.com/bevry/dorothy/tree/master/commands/setup-rust) correctly setup Rust on your system if desired or if required for your desired packages
    - [`setup-utils`](https://github.com/bevry/dorothy/tree/master/commands/setup-utils) correctly setup your selected `setup-util-*` utilities as desired

- [`setup-util`](https://github.com/bevry/dorothy/tree/master/commands/setup-util) is an intelligent wrapper around every package system, allowing a cross-compatible way to install, upgrade, and uninstall utilities.

    It is used by the hundreds of `setup-util-*` commands, which enable installing a utility as easy as invoking `setup-util-<utility>`

    If you don't know which command you need to call, you can use [`get-installer`](https://github.com/bevry/dorothy/tree/master/commands/get-installer) to get which command you will need to invoke to install a utility/binary/application.

- [`setup-shell`](https://github.com/bevry/dorothy/tree/master/commands/setup-shell) correctly configure your desired shell to be your default shell.

    By default, your terminal application will use the login shell configured for the system, as well as maintain a whitelist of available shells that can function as login shells.

- [`edit`](https://github.com/bevry/dorothy/tree/master/commands/edit) quickly open a file in your preferred editor, respecting terminal, SSH, and desktop environments.

- [`down`](https://github.com/bevry/dorothy/tree/master/commands/down) download a file with the best available utility on your computer.

- [`github-download`](https://github.com/bevry/dorothy/tree/master/commands/github-download) download files from GitHub without the tedium.

- [`secret`](https://github.com/bevry/dorothy/tree/master/commands/secret) stops you from leaking your env secrets to the world when a malicious program sends your shell environment variables to a remote server. Instead, `secret` will use 1Password to securely expose your secrets to just the command that needs them. Specifically:
    - secrets are fetched directly from 1Password, with a short lived session
    - secrets are cached securely for speed and convenience, only root/sudo has access to the cache (cache can be made optional if you want)
    - secrets are not added to the global environment, only the secrets that are desired for the command are loaded for the command's environment only

- [`setup-dns`](https://github.com/bevry/dorothy/tree/master/commands/setup-dns) correctly configures your systems DNS to your preferences

    A large security concern these days of using the internet, is the leaking, and potential of modification of your DNS queries. A DNS query is what turns `google.com` to say `172.217.167.110`. With un-encrypted DNS (the default), your ISP, or say that public Wifi provider, can intercept these queries to find out what websites you are visiting, and they can even rewrite these queries, to direct you elsewhere. This is how many public Wifi providers offer their service for free, by selling the data they collect on you, or worse.

    The solution to this is encrypted DNS. Some VPN providers already include it within their service, however most don't. And if you have encrypted DNS, then you get the benefits of preventing eavesdropping without the need for expensive VPN, and the risk of your VPN provider eavesdropping on you.

    Dorothy supports configuring your DNS to encrypted DNS via the [`setup-dns`](https://github.com/bevry/dorothy/tree/master/commands/setup-dns) command, which includes installation and configuration for any of these:
    - AdGuard Home
    - Cloudflared
    - DNSCrypt

    Related commands:
    - [`flush-dns`](https://github.com/bevry/dorothy/tree/master/commands/flush-dns) lets you easily flush your DNS anytime, any system.
    - [`setup-hosts`](https://github.com/bevry/dorothy/tree/master/commands/setup-hosts) lets you easily select from a variety of HOSTS files for security and privacy, while maintaining your customizations.

- [`mount-helper`](https://github.com/bevry/dorothy/tree/master/commands/mount-helper) lets you easily, correctly, and safely mount, unmount, automount, various devices, filesystems, network shares, gocryptfs vaults, etc, on any system.

    Related commands:
    - [`get-devices`](https://github.com/bevry/dorothy/tree/master/commands/get-devices) cross-platform fetching and filtering of select and complete device information
    - [`gocryptfs-helper`](https://github.com/bevry/dorothy/tree/master/commands/gocryptfs-helper) helpers for [GoCryptFS](https://github.com/rfjakob/gocryptfs)
    - [`what-is-using`](https://github.com/bevry/dorothy/tree/master/commands/gocryptfs-helper) find out what is using a path so that you can unmount it safely

- Dorothy also provides commands for writing commands, such as:
    - [`bash.bash`](https://github.com/bevry/dorothy/tree/master/sourcces/bash.bash) for a Bash strict mode that actually works, and various shims/polyfills
    - [`ask`](https://github.com/bevry/dorothy/tree/master/commands/ask), [`confirm`](https://github.com/bevry/dorothy/tree/master/commands/confirm), and [`choose`](https://github.com/bevry/dorothy/tree/master/commands/choose) for prompting the user for input
    - [`echo-style`](https://github.com/bevry/dorothy/tree/master/commands/echo-style), [`echo-error`](https://github.com/bevry/dorothy/tree/master/commands/echo-error), [`echo-verbose`](https://github.com/bevry/dorothy/tree/master/commands/echo-verbose), and [`eval-helper`](https://github.com/bevry/dorothy/tree/master/commands/eval-helper) for output styling
    - Dozens of `echo-*`, `fs-*`, `get-*`, and `is-*` helpers

Beta commands:

- [`mail-sync`](https://github.com/bevry/dorothy/tree/master/commands.beta/mail-sync) helps you migrate all your emails from one cloud provider to another.

### macOS

Stable commands:

- [`fs-alias`](https://github.com/bevry/dorothy/tree/master/commands/fs-alias) helps you manage your macOS aliases, and if desired, convert them into symlinks.
- [`macos-drive`](https://github.com/bevry/dorothy/tree/master/commands/macos-drive) helps you turn a macOS installer into a bootable USB drive.
- [`macos-installer`](https://github.com/bevry/dorothy/tree/master/commands/macos-installer) fetches the latest macOS installer.
- [`sparse-vault`](https://github.com/bevry/dorothy/tree/master/commands/sparse-vault) lets you easily, and for free, create secure encrypted password-protected vaults on your mac, for securing those super secret data.

Beta commands:

- [`eject-all`](https://github.com/bevry/dorothy/tree/master/commands.beta/eject-all) eject all removable drives safely.
- [`icloud-helper`](https://github.com/bevry/dorothy/tree/master/commands.beta/icloud-helper) can free up space for time machine by evicting local iCloud caches.
- [`itunes-owners`](https://github.com/bevry/dorothy/tree/master/commands.beta/itunes-owners) generates a table of who legally owns what inside your iTunes Media Library — which is useful for debugging certain iTunes Store authorization issues, which can occur upon backup restorations.
- [`macos-settings`](https://github.com/bevry/dorothy/tree/master/commands.beta/macos-settings) helps configure macOS to your preferred system preferences.
- [`macos-state`](https://github.com/bevry/dorothy/tree/master/commands.beta/macos-state) helps you backup and restore your various application and system preferences, from time machine backups, local directories, and sftp locations. This makes setting up clean installs easy, as even the configuration is automated. And it also helps you never forget an important file, like your env secrets ever again.
- [`macos-theme`](https://github.com/bevry/dorothy/tree/master/commands.beta/macos-theme) helps you change your macOS theme to your preference, including your wallpaper and editor.
- [`tmutil-helper`](https://github.com/bevry/dorothy/tree/master/commands.beta/tmutil-helper) can free up space for bootcamp by evicting local Time Machine caches.

### media

Beta commands:

- [`convert-helper`](https://github.com/bevry/dorothy/tree/master/commands.beta/convert-helper) convert one media format to another
- [`get-codec`](https://github.com/bevry/dorothy/tree/master/commands.beta/get-codec) gets the codec of a media file
- [`is-audio-mono`](https://github.com/bevry/dorothy/tree/master/commands.beta/is-audio-mono) checks if an audio file is mono
- [`is-audio-stereo`](https://github.com/bevry/dorothy/tree/master/commands.beta/is-audio-stereo) checks if an audio file is stereo
- [`pdf-decrypt`](https://github.com/bevry/dorothy/tree/master/commands.beta/pdf-decrypt) will mass decrypt encrypted PDFs.
- [`pdf-decrypt`](https://github.com/bevry/dorothy/tree/master/commands.beta/pdf-encrypt) decrypts a PDF file
- [`svg-export`](https://github.com/bevry/dorothy/tree/master/commands.beta/svg-export) converts an SVG image into a desired image format
- [`video-merge`](https://github.com/bevry/dorothy/tree/master/commands.beta/video-merge) will merge multiple video files in a directory together into a single video file.
- [`wallhaven-helper`](https://github.com/bevry/dorothy/tree/master/commands.beta/wallhaven-helper) download your wallpaper collections from [Wallhaven](https://wallhaven.cc)
- [`xps2pdf`](https://github.com/bevry/dorothy/tree/master/commands.beta/xps2pdf) will convert a legacy XPS document into a modern PDF document.
- [`ytd-helper`](https://github.com/bevry/dorothy/tree/master/commands.beta/ytd-helper) helps you download videos from the internet with simplified options.

## Community

Join the [Bevry Software community](https://discord.gg/nQuXddV7VP) to stay up-to-date on the latest Dorothy developments and to get in touch with the rest of the community.

<!-- BACKERS/ -->

## Backers

### Code

[Discover how to contribute via the `CONTRIBUTING.md` file.](https://github.com/bevry/dorothy/blob/HEAD/CONTRIBUTING.md#files)

#### Authors

- [Benjamin Lupton](https://balupton.com) — Accelerating collaborative wisdom.

#### Maintainers

- [Benjamin Lupton](https://balupton.com) — Accelerating collaborative wisdom.

#### Contributors

- [Benjamin Lupton](https://github.com/balupton) — [view contributions](https://github.com/bevry/dorothy/commits?author=balupton 'View the GitHub contributions of Benjamin Lupton on repository bevry/dorothy')
- [Bevry Team](https://github.com/BevryMe) — [view contributions](https://github.com/bevry/dorothy/commits?author=BevryMe 'View the GitHub contributions of Bevry Team on repository bevry/dorothy')
- [BJReplay](https://github.com/BJReplay) — [view contributions](https://github.com/bevry/dorothy/commits?author=BJReplay 'View the GitHub contributions of BJReplay on repository bevry/dorothy')
- [Cœur](https://github.com/Coeur) — [view contributions](https://github.com/bevry/dorothy/commits?author=Coeur 'View the GitHub contributions of Cœur on repository bevry/dorothy')
- [Joel McCracken](https://github.com/joelmccracken) — [view contributions](https://github.com/bevry/dorothy/commits?author=joelmccracken 'View the GitHub contributions of Joel McCracken on repository bevry/dorothy')
- [molleweide](https://github.com/molleweide) — [view contributions](https://github.com/bevry/dorothy/commits?author=molleweide 'View the GitHub contributions of molleweide on repository bevry/dorothy')
- [Nutchanon](https://github.com/ninyawee) — [view contributions](https://github.com/bevry/dorothy/commits?author=ninyawee 'View the GitHub contributions of Nutchanon on repository bevry/dorothy')
- [Octavian](https://github.com/octavian-one) — [view contributions](https://github.com/bevry/dorothy/commits?author=octavian-one 'View the GitHub contributions of Octavian on repository bevry/dorothy')
- [Oscar Vargas Torres](https://github.com/oscarvarto) — [view contributions](https://github.com/bevry/dorothy/commits?author=oscarvarto 'View the GitHub contributions of Oscar Vargas Torres on repository bevry/dorothy')
- [Sam Gutentag](https://github.com/samgutentag) — [view contributions](https://github.com/bevry/dorothy/commits?author=samgutentag 'View the GitHub contributions of Sam Gutentag on repository bevry/dorothy')
- [Sumit Rai](https://github.com/sumitrai) — [view contributions](https://github.com/bevry/dorothy/commits?author=sumitrai 'View the GitHub contributions of Sumit Rai on repository bevry/dorothy')

### Finances

<span class="badge-githubsponsors"><a href="https://github.com/sponsors/balupton" title="Donate to this project using GitHub Sponsors"><img src="https://img.shields.io/badge/github-donate-yellow.svg" alt="GitHub Sponsors donate button" /></a></span>
<span class="badge-thanksdev"><a href="https://thanks.dev/u/gh/bevry" title="Donate to this project using ThanksDev"><img src="https://img.shields.io/badge/thanksdev-donate-yellow.svg" alt="ThanksDev donate button" /></a></span>
<span class="badge-liberapay"><a href="https://liberapay.com/bevry" title="Donate to this project using Liberapay"><img src="https://img.shields.io/badge/liberapay-donate-yellow.svg" alt="Liberapay donate button" /></a></span>
<span class="badge-buymeacoffee"><a href="https://buymeacoffee.com/balupton" title="Donate to this project using Buy Me A Coffee"><img src="https://img.shields.io/badge/buy%20me%20a%20coffee-donate-yellow.svg" alt="Buy Me A Coffee donate button" /></a></span>
<span class="badge-opencollective"><a href="https://opencollective.com/bevry" title="Donate to this project using Open Collective"><img src="https://img.shields.io/badge/open%20collective-donate-yellow.svg" alt="Open Collective donate button" /></a></span>
<span class="badge-crypto"><a href="https://bevry.me/crypto" title="Donate to this project using Cryptocurrency"><img src="https://img.shields.io/badge/crypto-donate-yellow.svg" alt="crypto donate button" /></a></span>
<span class="badge-paypal"><a href="https://bevry.me/paypal" title="Donate to this project using Paypal"><img src="https://img.shields.io/badge/paypal-donate-yellow.svg" alt="PayPal donate button" /></a></span>

#### Sponsors

- [Andrew Nesbitt](https://nesbitt.io) — Working on mapping the world of open source software @ecosyste-ms and empowering developers with @octobox
- [Canonical](https://canonical.com)
- [Divinci ™](https://divinci.ai) — A more comfortable AI conversation experience, with friends! 🤖🖤
- [Edward J. Schwartz](https://github.com/edmcman)
- [Frontend Masters](https://FrontendMasters.com) — The training platform for web app engineering skills – from front-end to full-stack! 🚀
- [Mr. Henry](https://mrhenry.be)
- [Poonacha Medappa](https://poonachamedappa.com)
- [Roboflow](https://roboflow.com)

#### Donors

- [Andrew Nesbitt](https://nesbitt.io)
- [Balsa](https://balsa.com)
- [Canonical](https://canonical.com)
- [Chad](https://opencollective.com/chad8)
- [Codecov](https://codecov.io)
- [Divinci ™](https://divinci.ai)
- [Edward J. Schwartz](https://github.com/edmcman)
- [entroniq](https://gitlab.com/entroniq)
- [Frontend Masters](https://FrontendMasters.com)
- [Jean-Luc Geering](https://github.com/jlgeering)
- [Michael Duane Mooring](https://divinci.ai)
- [Mr. Henry](https://mrhenry.be)
- [Poonacha Medappa](https://poonachamedappa.com)
- [Rob Morris](https://linktr.ee/recipromancer)
- [Roboflow](https://roboflow.com)
- [Sentry](https://sentry.io)
- [ServieJS](https://github.com/serviejs)
- [Shah](https://github.com/smashah)
- [Square](https://github.com/square)
- [Syntax](https://syntax.fm)

<!-- /BACKERS -->

<!-- LICENSE/ -->

## License

Unless stated otherwise all works are:

- Copyright &copy; [Benjamin Lupton](https://balupton.com)

and licensed under:

- [Reciprocal Public License 1.5](http://spdx.org/licenses/RPL-1.5.html)

<!-- /LICENSE -->
