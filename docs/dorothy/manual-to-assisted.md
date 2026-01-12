# Manual to Assisted Installations

## Commands

If you are wanting to migrate your existing dotfiles configuration to Dorothy, you will probably have a legacy setup where instead of commands, you have functions, and instead of being cross-shell compatible, all your functions are written for one particular shell. To level-up your setup dramatically you will want to:

Turn each of these functions into their own command, such that they can be cross-compatible with any shell that calls it, do this by:

1. Moving the body of each function into their own command file at `$DOROTHY/user/commands/the-command-name`

1. Make the first line of the command file either `#!/usr/bin/env bash` for bash, `#!/usr/bin/env zsh` for zsh, `#!/usr/bin/env fish` for fish, and so on.

For functions that you want to keep in your shell environment rather than becoming commands:

1. Create a `$DOROTHY/user/sources/` directory, and store them in there with the appropriate extension prefix, e.g. `$DOROTHY/user/sources/my-function.bash`

1. Source the function file via your `$DOROTHY/user/config(.local)/interactive.*` configuration file, e.g. `source "$DOROTHY/user/sources/my-function.bash"`

For anything that modifies paths, or configures ecosystems, check the [`setup-environment-commands` command](https://github.com/bevry/dorothy/tree/master/commands/setup-environment-commands) to see if Dorothy already handles it for you, if so you can remove it, otherwise read on.

## Environment

Prior to Dorothy, when installing a utility, you would often have to manually modify your environment variables accordingly. This can get very complicated after a dozen or so utilities, and can be a matter of lock-in of which login shells you use.

Users of Dorothy don't have this manual tedium nor lock-in, as Dorothy crowd-shares this into efficiency, by figuring it out a single time, then applying the solution to all Dorothy users in a cross-compatible way.

Dorothy uses its [`setup-environment-commands` command](https://github.com/bevry/dorothy/blob/master/commands/setup-environment-commands) during its initialization process to update your login shells environment configuration accordingly, providing you a consistent experience across all your login shells. It supports best-practices for many utilities and environment configurations, and also allows you to extend it with your own customizations via your own `$DOROTHY/user/config/environment.bash` script.

## Setup

Prior to Dorothy, when installing a new machine we would have to manually restore a backup, or when doing a clean install, we would have to manually reinstall everything. If it was a different environment, or a new operating system version, that may mean having to remember or discover all the quirks of that environment, such as incompatibilities or different package managers.

Users of Dorothy don't have this manual tedium nor lock-in, as Dorothy crowd-shares this into efficiency, by figuring it out a single time, then applying the solution to all Dorothy users in a cross-compatible way.

So rather than figuring out how to install a package ecosystem, then what packages you need to install, and what packages need to change, you just run `setup-system install` or `setup-system update` and Dorothy will handle the rest.

This works by transforming statements like `brew install git bash` into the configuration value `HOMEBREW_INSTALL=(git bash)` inside your `$DOROTHY/user/config/setup.bash` file. With this, next time you run `setup-install` or `setup-update` they will be installed/updated automatically. In fact, both `git` and `bash` have their own Dorothy `setup-util-*` commands which would install them in a cross-platform way and move them to `SETUP_UTILS=(git bash)` instead.

### Example Setups

- [Dorothy's `config/setup.bash`](https://github.com/bevry/dorothy/blob/master/config/setup.bash)
- [@balupton's `config/setup.bash`](https://github.com/balupton/dotfiles/blob/master/config/setup.bash)

### Custom Setups

If you wish to install different things on different machines, you can configure your `$DOROTHY/user/config/setup.bash` like so:

```bash
#!/usr/bin/env bash
# ...

# based on hostname
hostname="$(get-hostname)"
if [[ "$hostname" = '...' ]]; then
	# ...
else
	# ...
fi

# based on platform
if is-system --macos; then
	# ...
elif is-system --ubuntu; then
	# ...
fi

# based on architecture
# https://github.com/bevry/dorothy/blob/master/commands/get-arch
arch="$(get-arch)"
if [[ "$arch" = 'a64' ]]; then
   # arm 64
else
   # not arm 64
fi
```

## Git

Prior to Dorothy, you'd have to figure out a way to securely and privately update your git configuration across all machines, including your git profile configuration, your git ssh configuration, your git signing configuration, and so on. This is very complex, even for the most experienced of us.

Users of Dorothy don't have this manual tedium nor lock-in, as Dorothy crowd-shares this into efficiency, by figuring it out a single time, then applying the solution to all Dorothy users in a cross-compatible way.

You can use Dorothy's [`setup-git` command](https://github.com/bevry/dorothy/blob/master/commands/setup-git) to configure your git configuration, not only for your desires, but also for the capabilities of your machine. Installing and configuring anything as necessary. One of its coolest accomplishments is correct handling of signing, supporting GPG, Krypton, SSH, and 1Password.

You can configure your preferences via `setup-git --configure` or by modifying your `$DOROTHY/user/config(.local)/git.bash` file directly.

## DNS

Prior to Dorothy, you'd have to figure out a way to securely and privately update your DNS configuration across all machines, manually figuring out DNS providers, whether it is IPv4 and IPv6 or HTTPS or something else, which specific encryption protocols it supports, and then how to actually correctly apply it to your machine! This is very complex, even for the most experienced of us.

Users of Dorothy don't have this manual tedium nor lock-in, as Dorothy crowd-shares this into efficiency, by figuring it out a single time, then applying the solution to all Dorothy users in a cross-compatible way.

You can use Dorothy's [`setup-dns` command](https://github.com/bevry/dorothy/blob/master/commands/setup-dns) to configure your DNS configuration, not only for your desires, but also for the capabilities of your machine. Installing and configuring anything as necessary. Its ability to correctly handle DNS encryption, makes it a superior performance and privacy alternative for what most people use and pay VPNs for.

You can configure your preferences via `setup-dns --configure` or by modifying your `$DOROTHY/user/config(.local)/dns.bash` file directly.
