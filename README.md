# Dorothy

<!-- BADGES/ -->

<span class="badge-githubsponsors"><a href="https://github.com/sponsors/balupton" title="Donate to this project using GitHub Sponsors"><img src="https://img.shields.io/badge/github-donate-yellow.svg" alt="GitHub Sponsors donate button" /></a></span>
<span class="badge-thanksdev"><a href="https://thanks.dev/u/gh/balupton" title="Donate to this project using ThanksDev"><img src="https://img.shields.io/badge/thanksdev-donate-yellow.svg" alt="ThanksDev donate button" /></a></span>
<span class="badge-patreon"><a href="https://patreon.com/bevry" title="Donate to this project using Patreon"><img src="https://img.shields.io/badge/patreon-donate-yellow.svg" alt="Patreon donate button" /></a></span>
<span class="badge-flattr"><a href="https://flattr.com/profile/balupton" title="Donate to this project using Flattr"><img src="https://img.shields.io/badge/flattr-donate-yellow.svg" alt="Flattr donate button" /></a></span>
<span class="badge-liberapay"><a href="https://liberapay.com/bevry" title="Donate to this project using Liberapay"><img src="https://img.shields.io/badge/liberapay-donate-yellow.svg" alt="Liberapay donate button" /></a></span>
<span class="badge-buymeacoffee"><a href="https://buymeacoffee.com/balupton" title="Donate to this project using Buy Me A Coffee"><img src="https://img.shields.io/badge/buy%20me%20a%20coffee-donate-yellow.svg" alt="Buy Me A Coffee donate button" /></a></span>
<span class="badge-opencollective"><a href="https://opencollective.com/bevry" title="Donate to this project using Open Collective"><img src="https://img.shields.io/badge/open%20collective-donate-yellow.svg" alt="Open Collective donate button" /></a></span>
<span class="badge-crypto"><a href="https://bevry.me/crypto" title="Donate to this project using Cryptocurrency"><img src="https://img.shields.io/badge/crypto-donate-yellow.svg" alt="crypto donate button" /></a></span>
<span class="badge-paypal"><a href="https://bevry.me/paypal" title="Donate to this project using Paypal"><img src="https://img.shields.io/badge/paypal-donate-yellow.svg" alt="PayPal donate button" /></a></span>
<span class="badge-wishlist"><a href="https://bevry.me/wishlist" title="Buy an item on our wishlist for us"><img src="https://img.shields.io/badge/wishlist-donate-yellow.svg" alt="Wishlist browse button" /></a></span>

<!-- /BADGES -->

Dorothy is a dotfile ecosystem featuring:

-   seamless support for [Bash](<https://en.wikipedia.org/wiki/Bash_(Unix_shell)>), [Zsh](https://en.wikipedia.org/wiki/Z_shell), [Fish](<https://en.wikipedia.org/wiki/Fish_(Unix_shell)>), [Nu](https://www.nushell.sh), [Xonsh](https://xon.sh), [Elvish](https://elv.sh)
-   seamless support for multiple operating systems and architectures
-   seamless support for your favorite terminal and GUI editors
-   automatic configuration of your environment variables for what you have installed on your system
-   automatic installation and updating of your specified packages
-   automatic Git, SSH, and GPG configuration based on what your system supports and your configuration
-   hundreds of [commands](https://github.com/bevry/dorothy/tree/master/commands) to improve your productivity
-   completely extensible and configurable with your own user repository
-   all this together, allows you to go from zero to hero within minutes, instead of days, on a brand new machine

Dorothy maintainers are daily driving Dorothy on:

-   macOS on Apple Silicon (ARM64)
-   macOS on Intel (x86_64)
-   Ubuntu Server on Raspberry Pi 4 (ARM64)
-   Ubuntu Desktop on Raspberry Pi 400 (ARM64)
-   Ubuntu Desktop on Intel/AMD (x86_64)

Dorothy users are daily driving Dorothy on:

-   Manjaro/Arch on Intel/AMD (x86_64)
-   Windows 11 via [Ubuntu](https://ubuntu.com/wsl) [WSL2](https://docs.microsoft.com/en-au/windows/wsl/) on Intel/AMD (x86_64)

Dorothy maintainers and users are occasionally driving Dorothy on:

-   macOS on Apple Silicon with `HOMEBREW_ARCH="x86_64"`
-   Fedora via Intel/AMD (x84_64) virtual machines
-   OpenSUSE via Intel/AMD (x84_64) virtual machines
-   Alpine via Intel/AMD (x84_64) virtual machines
-   Alpine via Apple Silicon (ARM64) virtual machines
-   [Ubuntu Server on StarFive’s VisionFive](https://ubuntu.com//blog/canonical-enables-ubuntu-on-starfives-visionfive-risc-v-boards) (RISC-V)

[Watch the 2022 April Presentation to see what Dorothy can do!](https://www.youtube.com/watch?v=gWLana1JmNk)

[![Screenshot of the 2022 April Presentation](https://github.com/bevry/dorothy/blob/master/docs/assets/presentation.gif?raw=true)](https://www.youtube.com/watch?v=gWLana1JmNk)

## Setup

### Prerequisites

macOS:

```bash
xcode-select --install
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

Mageia, Nix, and Gentoo are [currently unsupported.](https://github.com/bevry/dorothy/issues/162)

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
-   Your login shell is not one of the Dorothy supported shells ([Bash](<https://en.wikipedia.org/wiki/Bash_(Unix_shell)>), [Zsh](https://en.wikipedia.org/wiki/Z_shell), [Fish](<https://en.wikipedia.org/wiki/Fish_(Unix_shell)>), [Nu](https://www.nushell.sh), [Xonsh](https://xon.sh), [Elvish](https://elv.sh)). [Create an issue requesting support for your shell.](https://github.com/bevry/dorothy/issues)

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

    -   [Fish](<https://en.wikipedia.org/wiki/Fish_(Unix_shell)>) loads our [`init.fish`](https://github.com/bevry/dorothy/blob/master/init.fish) script
    -   [Nu](https://www.nushell.sh) loads our [`init.nu`](https://github.com/bevry/dorothy/blob/master/init.nu) script
    -   [Xonsh](https://xon.sh) loads our [`init.xsh`](https://github.com/bevry/dorothy/blob/master/init.xsh) script
    -   [Elvish](https://elv.sh) loads our [`init.elv`](https://github.com/bevry/dorothy/blob/master/init.elv) script
    -   POSIX shells ([Bash](<https://en.wikipedia.org/wiki/Bash_(Unix_shell)>), [Zsh](https://en.wikipedia.org/wiki/Z_shell), etc) load our [`init.sh`](https://github.com/bevry/dorothy/blob/master/init.sh) script

1.  The initialization script will:

    1. Ensure the `DOROTHY` environment variable is set to the location of the Dorothy installation.

    1. If a login shell, it loads our login script `sources/login.(sh|fish|nu|xsh|elv)`, which will:

        1. Apply any configuration changes necessary for that login shell
        1. Load our environment script `sources/environment.(sh|fish|nu|xsh|elv)`, which will:

            1. Invoke `commands/setup-environment-commands` which determines and applies all necessary environment configuration changes to the shell. It loads your `user/config(.local)/environment.bash` configuration script for your own custom environment configuration that will be applied to all your login shells.

    1. If a login and interactive shell, it loads our interactive script `sources/interactive.(sh|fish|nu|xsh|elv)`, which will:

        1. Load your own `user/config(.local)/interactive.(sh|fish|nu|xsh|elv)` configuration script for your own interactive login shell configuration.
            - [Fish](<https://en.wikipedia.org/wiki/Fish_(Unix_shell)>) shell will load `interactive.fish` if it exists, otherwise it will load `interactive.sh`.
            - [Nu](https://www.nushell.sh) will only load `interactive.nu` and it must exist.
            - [Xonsh](https://xon.sh) will only load `interactive.xsh` if it exists.
            - [Elvish](https://elv.sh) will only load `interactive.elv` if it exists.
            - POSIX shells ([Bash](<https://en.wikipedia.org/wiki/Bash_(Unix_shell)>), [Zsh](https://en.wikipedia.org/wiki/Z_shell), etc) will load their `interactive.(bash|zsh|...etc)` file if it exists, otherwise they will load `interactive.sh` if exists.
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
-   Dorothy User Configurations:
    -   [@balupton](https://github.com/balupton): <https://github.com/balupton/dotfiles>
    -   [@molleweide](https://github.com/molleweide): <https://github.com/molleweide/dotfiles>
    -   [@sumitrai](https://github.com/sumitrai): <https://github.com/sumitrai/dotfiles>
    -   if you use Dorothy, send a pull request to add your own user configuration to this list.

## Community

Join the [Bevry Software community](https://discord.gg/nQuXddV7VP) to stay up-to-date on the latest Dorothy developments and to get in touch with the rest of the community.

## Sponsors

Dorothy is supported by the following [sponsors](https://github.com/sponsors/balupton):

-   [Andrew Nesbitt](https://github.com/andrew)
-   [Balsa](https://github.com/balsa)
-   [dr.dimitru](https://github.com/dr-dimitru)
-   [Nermal](https://github.com/nermalcat69)
-   [Poonacha Medappa](https://github.com/km-Poonacha)
-   [Rob Morris](https://github.com/Rob-Morris)

<!-- LICENSE/ -->

<h2>License</h2>

Unless stated otherwise all works are:

<ul><li>Copyright &copy; 2013+ <a href="https://github.com/balupton">Benjamin Lupton</a></li></ul>

and licensed under:

<ul><li><a href="http://spdx.org/licenses/RPL-1.5.html">Reciprocal Public License 1.5</a></li></ul>

<!-- /LICENSE -->
