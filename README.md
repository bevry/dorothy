# Dorothy

Dorothy is a dotfile ecosystem featuring:

-   seamless support for [bash](<https://en.wikipedia.org/wiki/Bash_(Unix_shell)>), [fish](<https://en.wikipedia.org/wiki/Fish_(Unix_shell)>), and [zsh](https://en.wikipedia.org/wiki/Z_shell)
-   seamless support for multiple operating systems and architectures
-   seamless support for your favorite terminal and GUI editors
-   automatic configuration of your environment variables for what you have installed on your system
-   automatic installation and updating of your specified packages
-   automatic git ssh and gpg configuration based on what your system supports and your configuration
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

## Try

If you just want to trial [Dorothy commands](https://github.com/bevry/dorothy/tree/master/commands) without configuring your shell, you can do the following:

```bash
# IF you are on Alpine, install the dependencies
doas apk add bash curl git

# IF you are on Ubuntu, install the dependencies
sudo apt install bash curl git

# IF you are on macOS, install the dependencies
xcode-select --install

# To run only a specific command, run the following and swap out `what-is-my-ip` with whatever command you wish to run
bash -ic "$(curl -fsSL https://dorothy.bevry.me/commands/what-is-my-ip)"

# To run multiple commands in a REPL, run the following then type the commands you wish to execute
eval "$(curl -fsSL https://dorothy.bevry.me/try)"
```

## Install

To install Dorothy run the following in your favorite terminal application:

```bash
# IF you are on Alpine, install the dependencies
doas apk add bash curl git

# IF you are on Ubuntu, install the dependencies
sudo apt install bash curl git

# IF you are on macOS, install the dependencies
xcode-select --install

# Run the Dorothy installation script
bash -ilc "$(curl -fsSL https://dorothy.bevry.me/install)"
```

During installation, Dorothy will ask you to create a repository to store your user configuration, such as a `dotfiles` repository. If you already have a dotfiles repository, you can use that, or make another.

Verify the installation worked by selecting a theme for Dorothy by running:

```bash
# you must open a new terminal instance first
dorothy theme
# then open a new terminal
```

## Troubleshooting

If your shell doesn't recognize the syntax, run `bash -il` then run the command again.

If you get a command not found error or an undefined/unbound variable error, [verify that your terminal application has login shells enabled.](https://github.com/bevry/dorothy/blob/master/docs/01-dorothy/dorothy-not-loading.md) If you are running in a login shell, then you may be running in an unsupported shell, run `bash -il` to open bash, if it still doesn't work, then run the installer again, and make sure to confirm the setup for Dorothy for each shell when prompted.

If packages are failing to install, update your Operating System's package manager so that it is using the latest references:

```bash
# Alpine
doas apk update

# Ubuntu
sudo apt update

# Fedora
sudo dnf check-update -y
sudo yum check-update -y

# Manjaro
sudo pacman-key --init
sudo pacman --refresh --sync

# OpenSUSE
sudo zypper --gpg-auto-import-keys refresh
```

## Overview

Dorothy will be installed to `$DOROTHY`, which consists of the following:

-   [`commands` directory](https://github.com/bevry/dorothy/tree/master/commands) contains executable commands
-   [`sources` directory](https://github.com/bevry/dorothy/tree/master/sources) contains scripts that are loaded into the shell environment
-   [`themes` directory](https://github.com/bevry/dorothy/tree/master/themes) contains themes that you can select via the `THEME` environment variable
-   [`user` directory](https://github.com/balupton/dotfiles) is your own github repository for your custom configuration
-   [`init.fish`](https://github.com/bevry/dorothy/blob/master/init.fish) the initialization script for the fish shell
-   [`init.sh`](https://github.com/bevry/dorothy/blob/master/init.sh) the initialization script for other shells

The initialization of Dorothy works as follows:

1. Fish shell will be instructed to load Dorothy's `init.fish` file, and the other shell's will be instructed to load Dorothy's `init.sh` file.

1. The initialization file will set the `DOROTHY` environment variable to the location of the Dorothy installation, and load the appropriate `sources/*` files.

1. `source/init.(sh|fish)` will load `sources/environment.(sh|fish)` which will:

    1. invoke `setup-environment-commands` which will determine the appropriate environment configuration for the invoking shell
    2. evaluate its output, applying the configuration to the shell, achieving cross-shell environment compatibility

1. `source/interactive.(sh|fish)` will load the additional configuration for our interactive login shell, such as:

    1. Enabling editor preferences
    1. Enabling aliases and functions
    1. Enabling the ssh agent
    1. Enabling zsh and its ecosystem
    1. Enabling shell auto-completions
    1. Enabling prompt theme

This is the foundation enables Dorothy's hundreds of commands, to work across hundreds of machines, across dozens of operating system and shell combinations, seamlessly.

## Documentation

[Discussions.](https://github.com/bevry/dorothy/discussions)

Staring with Dorothy:

-   [XDG](https://github.com/bevry/dorothy/blob/master/docs/01-dorothy/xdg.md)
-   [Assisted Installations](https://github.com/bevry/dorothy/blob/master/docs/01-dorothy/manual-to-assisted.md)
-   [Configuring Editors](https://github.com/bevry/dorothy/blob/master/docs/01-dorothy/editors.md)
-   [Private Configurations](https://github.com/bevry/dorothy/blob/master/docs/01-dorothy/private-configuration.md)
-   [Encrypted Configurations](https://github.com/bevry/dorothy/blob/master/docs/01-dorothy/encrypted-configuration.md)

Coding with Dorothy:

-   [Commands](https://github.com/bevry/dorothy/blob/master/docs/02-coding/commands.md)
-   [Strict Mode](https://github.com/bevry/dorothy/blob/master/docs/02-coding/strict.md)
-   [Exit and Return codes](https://github.com/bevry/dorothy/blob/master/docs/02-coding/exit-return-codes.md)
-   [Styling your Command Output](https://github.com/bevry/dorothy/blob/master/docs/02-coding/styling.md)
-   [Working with Prompts](https://github.com/bevry/dorothy/blob/master/docs/02-coding/prompts.md)
-   [Writing a Utility Installer](https://github.com/bevry/dorothy/blob/master/docs/02-coding/util.md)
-   [Reading and Writing Configuration](https://github.com/bevry/dorothy/blob/master/docs/02-coding/read-write-config.md)

Coding with Bash:

-   [Arrays](https://github.com/bevry/dorothy/blob/master/docs/03-bash/arrays.md)
-   [Builtins](https://github.com/bevry/dorothy/blob/master/docs/03-bash/builtins.md)
-   [Conditionals](https://github.com/bevry/dorothy/blob/master/docs/03-bash/conditionals.md)
-   [Foreach Line](https://github.com/bevry/dorothy/blob/master/docs/03-bash/foreach-line.md)
-   [Parameter Expansion](https://github.com/bevry/dorothy/blob/master/docs/03-bash/parameter-expansions.md)
-   [Replace Inline](https://github.com/bevry/dorothy/blob/master/docs/03-bash/replace-inline.md)
-   [Resources](https://github.com/bevry/dorothy/blob/master/docs/03-bash/resources.md)
-   [Subshells](https://github.com/bevry/dorothy/blob/master/docs/03-bash/subshells.md)
-   [Trailing Lines](https://github.com/bevry/dorothy/blob/master/docs/03-bash/trailing-lines.md)
-   [Versions](https://github.com/bevry/dorothy/blob/master/docs/03-bash/versions.md)

Roadmap:

-   [Multi-Repo Configuration](https://github.com/bevry/dorothy/discussions/32)
-   [choose-menu x1000](https://github.com/bevry/dorothy/issues/97)

## Showcase

If you use Dorothy, add yourself below:

-   @balupton: https://github.com/balupton/dotfiles
-   @molleweide: https://github.com/molleweide/dotfiles
-   @sumitrai: https://github.com/sumitrai/dotfiles

## Sponsors

Dorothy is supported by the following [sponsors](https://github.com/sponsors/balupton):

-   [Andrew Nesbitt](https://github.com/andrew)
-   [Balsa](https://github.com/balsa)
-   [dr.dimitru](https://github.com/dr-dimitru)
-   [Octavian](https://github.com/octavian-one)
-   [Poonacha Medappa](https://github.com/km-Poonacha)
-   [Rob Morris](https://github.com/Rob-Morris)
-   [Timothy H](https://github.com/timmyha)

<!-- LICENSE/ -->

<h2>License</h2>

Unless stated otherwise all works are:

<ul><li>Copyright &copy; 2013+ <a href="http://balupton.com">Benjamin Lupton</a></li></ul>

and licensed under:

<ul><li><a href="http://spdx.org/licenses/RPL-1.5.html">Reciprocal Public License 1.5</a></li></ul>

<!-- /LICENSE -->
