# Dorothy

Dorothy is a dotfile ecosystem featuring:

- seamless support for [bash](<https://en.wikipedia.org/wiki/Bash_(Unix_shell)>), [fish](<https://en.wikipedia.org/wiki/Fish_(Unix_shell)>), and [zsh](https://en.wikipedia.org/wiki/Z_shell)
- seamless support for multiple operating systems and architectures
- seamless support for your favorite terminal and GUI editors
- automatic configuration of your environment variables for what you have installed on your system
- automatic installation and updating of your specified packages
- automatic git ssh and gpg configuration based on what your system supports and your configuration
- hundreds of [commands](https://github.com/bevry/dorothy/tree/master/commands) to improve your productivity
- completely extensible and configurable with your own user repository
- all this together, allows you to go from zero to hero within minutes, instead of days, on a brand new machine

Dorothy maintainers are daily driving Dorothy on:

- macOS on Apple Silicon
- macOS on Intel
- Ubuntu Server on Raspberry Pi 4 (ARM64)
- Ubuntu Desktop on Raspberry Pi 400 (ARM64)
- Ubuntu Desktop on Intel/AMD (x86_64)

Dorothy users are daily driving Dorothy on:

- Manjaro/Arch on Intel/AMD (x86_64)
- Windows 11 via [Ubuntu](https://ubuntu.com/wsl) [WSL2](https://docs.microsoft.com/en-au/windows/wsl/) on Intel/AMD (x86_64)

Dorothy maintainers and users are occasionally driving Dorothy on:

- macOS on Apple Silicon with `HOMEBREW_ARCH="x86_64"`
- Fedora via Intel/AMD (x84_64) virtual machines

[Watch the 2022 April Presentation to see what Dorothy can do!](https://www.youtube.com/watch?v=gWLana1JmNk)

## Try

If you just want to trial [Dorothy commands](https://github.com/bevry/dorothy/tree/master/commands) without configuring your shell, you can do the following:

```bash
# IF you are on alpine, install the dependencies
sudo apk add curl bash

# IF you are on ubuntu, install the dependencies
sudo apt install curl bash

# IF you are on macOS, install the dependencies
xcode-select --install

# To run only a specific command, run the following and swap out `what-is-my-ip` with whatever command you wish to run
bash -ic "$(curl -fsSL https://dorothy.bevry.workers.dev/commands/what-is-my-ip)"

# To run multiple commands in a REPL, run the following then type the commands you wish to execute
eval "$(curl -fsSL https://dorothy.bevry.workers.dev)"
```

If your shell doesn't recognise the syntax above, run `bash -il` then run the command again.

## Install

To install Dorothy run the following in your favorite terminal application:

```bash
# IF you are on alpine, install the dependencies
sudo apk add curl bash

# IF you are on ubuntu, install the dependencies
sudo apt install curl bash

# IF you are on macOS, install the dependencies
xcode-select --install

# Run the dorothy installation script
bash -ilc "$(curl -fsSL https://raw.githubusercontent.com/bevry/dorothy/master/commands/dorothy)"
```

If your shell doesn't recognise the syntax above, run `bash -il` then run the command again.

During installation, Dorothy will ask you to create a repository to store your user configuration, such as a `dotfiles` repository. If you already have a dotfiles repository, you can use that, or make another.

Verify the installation worked by selecting a theme for Dorothy by running:

```bash
# you must open a new terminal instance first
dorothy theme
# then open a new terminal
```

If you get a command not found error, [verify that your terminal application has login shells enabled.](https://github.com/bevry/dorothy/discussions/141)

## Overview

This will by default install Dorothy to `$HOME/.dorothy`, which consists of the following:

- [`commands` directory](https://github.com/bevry/dorothy/tree/master/commands) contains executable commands
- [`sources` directory](https://github.com/bevry/dorothy/tree/master/sources) contains scripts that are loaded into the shell environment
- [`themes` directory](https://github.com/bevry/dorothy/tree/master/themes) contains themes that you can select via the `THEME` environment variable
- [`user` directory](https://github.com/balupton/dotfiles) is your own github repository for your custom configuration
- [`init.fish`](https://github.com/bevry/dorothy/blob/master/init.fish) the initialization script for the fish shell
- [`init.sh`](https://github.com/bevry/dorothy/blob/master/init.sh) the initialization script for other shells

The initialization of Dorothy works as follows:

1. Fish shell will be instructed to load Dorothy's `init.fish` file, and the other shell's will be instructed to load Dorothy's `init.sh` file.

1. The initialization file will set the `DOROTHY` environment variable to the location of the Dorothy installation, and load the appropriate `sources/*` files.

1. `source/init.(sh|fish)` will load `sources/environment.(sh|fish)` which will:

   1. invoke `setup-environment-commands` which will determine the appropriate environment configuration for the invoking shell
   2. evaluate its output, applying the configuration to the shell, achieving cross-shell environment compatibility

1. `source/shell.(sh|fish)` will load the additional configuration for our interactive login shell, such as:

   1. Enabling editor preferences
   1. Enabling aliases and functions
   1. Enabling the ssh agent
   1. Enabling zsh and its ecosystem
   1. Enabling shell auto-completions
   1. Enabling prompt theme

This is the foundation enables Dorothy's hundreds of commands, to work across hundreds of machines, across dozens of operating system and shell combinations, seamlessly.

## Documentation

[Complete discussions and documentation.](https://github.com/bevry/dorothy/discussions)

Staring with Dorothy:

- [XDG](https://github.com/bevry/dorothy/discussions/34)
- [manual to assisted installations](https://github.com/bevry/dorothy/discussions/38)
- [`config.local` for private configurations](https://github.com/bevry/dorothy/discussions/35)
- [dorothy prefers user commands](https://github.com/bevry/dorothy/discussions/28)

Conventions in Dorothy:

- [configuring editors](https://github.com/bevry/dorothy/discussions/137)
- [strict mode](https://github.com/bevry/dorothy/discussions/124)
- [exit and return codes](https://github.com/bevry/dorothy/discussions/125)

Coding with Dorothy:

- [writing a dorothy command](https://github.com/bevry/dorothy/discussions/37)
- [writing a utility installer](https://github.com/bevry/dorothy/discussions/73)
- [styling your command output](https://github.com/bevry/dorothy/discussions/134)
- [reading and writing configuration](https://github.com/bevry/dorothy/discussions/135)

Coding with Bash:

- [bash guides](https://github.com/bevry/dorothy/discussions/123)
- [bash builtins](https://github.com/bevry/dorothy/discussions/126)

Roadmap:

- [multi-repo configuration](https://github.com/bevry/dorothy/discussions/32)
- [choose-menu x1000](https://github.com/bevry/dorothy/issues/97)

## Support

To support the adoption of Dorothy, support tiers are issued in batches of five to active users to provide free realtime support and an hour of free scheduled support a month.

The first batch is for early adopters:

1. [@balupton](https://github.com/balupton/dotfiles)
2. [@sumitrai](https://github.com/sumitrai/dotfiles)
3. [@molleweide](https://github.com/molleweide/dotfiles)
4. Register yourself
5. Register yourself

The second batch is for adopters who [sponsor](https://github.com/sponsors/balupton) any amount:

1. Register yourself
2. Register yourself
3. Register yourself
4. Register yourself
5. Register yourself

The third batch is for adopters who [sponsor](https://github.com/sponsors/balupton) $25/month or more:

1. Register yourself
2. Register yourself
3. Register yourself
4. Register yourself
5. Register yourself

The fourth batch is for adopters who [sponsor](https://github.com/sponsors/balupton) $50/month or more:

1. Register yourself
2. Register yourself
3. Register yourself
4. Register yourself
5. Register yourself

And so on in $25/month increments.

## License

Public Domain via [The Unlicense](https://choosealicense.com/licenses/unlicense/)

```plain
This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.

In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <http://unlicense.org>
```
