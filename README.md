# Dorothy

Dorothy is a dotfile ecosystem featuring:

- seamless support for bash, fish, and zsh
- seamless support for multiple operating systems, such as MacOS and Ubuntu
- seamless support for your favorite terminal and GUI editors
- automatic configuration of your environment variables for what you have installed on your system
- automatic installation and updating of your specified packages
- automatic git ssh and gpg configuration based on what your system supports and your configuration
- hundreds of [commands](https://github.com/bevry/dorothy/tree/master/commands) to improve your productivity
- completely extensible and configurable with your own user repository
- all this together, allows you to go from zero to hero within minutes, instead of days, on a brand new machine

## Try

If you just want to trial [Dorothy commands](https://github.com/bevry/dorothy/tree/master/commands) without configuring your shell, you can do the following:

```bash
# IF you are on alpine, install the dependencies
apk add curl git bash

# IF you are on ubuntu, install the dependencies
apt update
apt install curl git bash

# IF you are on macOS, install the dependencies
xcode-select --install

# To run only a specific command, run the following and swap out `what-is-my-ip` with whatever command you wish to run
sh -ic "$(curl -fsSL https://dorothy.bevry.workers.dev/commands/what-is-my-ip)"

# To run multiple commands in a REPL, run the following then type the commands you wish to execute
sh --rcfile <(curl -fsSL https://dorothy.bevry.workers.dev)
```

If your shell doesn't recognise the syntax above, run `bash -il` then run the command again.


## Install

To install Dorothy run the following in your favorite terminal application:

```bash
# IF you are on alpine, install the dependencies
apk add curl git bash

# IF you are on ubuntu, install the dependencies
apt update
apt install curl git bash

# IF you are on macOS, install the dependencies
xcode-select --install

# Run the dorothy installation script
bash -ilc "$(curl -fsSL https://raw.githubusercontent.com/bevry/dorothy/master/commands/setup-dorothy)"
```

If your shell doesn't recognise the syntax above, run `bash -il` then run the command again.

If you would like to do the installation manually, refer to [`commands/setup-dorothy`](https://github.com/bevry/dorothy/blob/master/commands/setup-dorothy).

During installation, Dorothy will ask you to create a repository to store your user configuration, such as a `dotfiles` repository. If you already have a dotfiles repository, you can use that, or make another. If you decide to use your existing dotfiles repository refer to the [Configuration section](https://github.com/bevry/dorothy#configuration) for the expectations.

## Explanation

This will by default install Dorothy to `$HOME/.dorothy`, which consists of the following:

- [`commands` directory](https://github.com/bevry/dorothy/tree/master/commands) contains executable commands
- [`sources` directory](https://github.com/bevry/dorothy/tree/master/sources) contains scripts that are loaded into the shell environment
- [`themes` directory](https://github.com/bevry/dorothy/tree/master/themes) contains themes that you can select via the `THEME` environment variable
- [`user` directory](https://github.com/balupton/dotfiles) is your own github repository for your custom configuration
- [`init.fish`](https://github.com/bevry/dorothy/blob/master/init.fish) the initialization script for the fish shell
- [`init.sh`](https://github.com/bevry/dorothy/blob/master/init.sh) the initialization script for other shells

The initialization of Dorothy works as follows:

1. Fish shell will be instructed to load Dorothy's `init.fish` file, and the other shell's will be instructed to load Dorothy's `init.sh` file.
1. The initialization file will set the `DOROTHY` environment variable to the location of the Dorothy installation, and load the appropriate `sources/essentials` and `sources/extras` file for our shell.
1. The essentials will configure the scripting necessities:

   1. evaluate the output of `setup-paths-commands` which will setup the various environment variables for what our system has installed (such as adding ecosystem tooling to `PATH` and setting up the various `*ROOT` variables etc)
   1. load our user configuration and overrides

1. The extras will configure everything needed for user shells, rather than necessarily scripting:

   1. Configure our editor preferences
   1. Configure our aliases and functions
   1. Configure ssh
   1. Configure zsh
   1. Configure azure and google cloud
   1. Configure shell auto-completions
   1. Configure the theme

All up, this is pretty amazing.

## Documentation

After installing Dorothy, there will now be hundreds of [commands](https://github.com/bevry/dorothy/tree/master/commands) available to you, most should be intuitive, and if they receive arguments, then they should alert you to what they are. [Soon](https://github.com/bevry/dorothy/issues/7) there will also be man page documentation for these.

The most prominent commands and functionality are grouped into categories below.

### Configuration

Dorothy is highly configurable. During the installation process, it would have set you up with your own `user` repository inside Dorothy. You can run `edit "$DOROTHY/user"` to open it in your favorite GUI editor. Or if you haven't installed Dorothy yet, you can refer to [Benjamin Lupton's dotfiles](https://github.com/balupton/dotfiles) for his directory.

Inside the user configuration will be a `commands` directory, which is automatically inside your `PATH` (meaning it is runnable by just typing its name in your terminal). If you have created a new command, ensure it is executable by running [`setup-dorothy-permissions`](https://github.com/bevry/dorothy/tree/master/commands/setup-dorothy-permissions).

There will also be a `source.bash` file and a `source.sh` file inside the user configuration. The `source.bash` file is where the configuration for our various bash commands will go, such as our [`setup-*` installation scripts](https://github.com/bevry/dorothy#installation). The `source.sh` file is where you will put configuration that is compatible with all your shells, and is for things primarily outside the Dorothy ecosystem.

#### `source.bash`

Available `source.bash` configuration:

- `USER_SHELLS` to specify your preferential order of the shell, such that [`select-shell`](https://github.com/bevry/dorothy/tree/master/commands/select-shell) which is run within [`setup-install`](https://github.com/bevry/dorothy/tree/master/commands/setup-install) will select your favorite shell that is available
- Other configuration is detailed in the various functionality sections.

Open/edit your `source.bash` file:

```bash
edit "$DOROTHY/user/source.bash"
```

Examples of the `source.bash` file:

- [Dorothy's `defaults.bash` which contains the defaults.](https://github.com/bevry/dorothy/tree/master/sources/defaults.bash)
- [Benjamin Lupton's `source.bash` which contains many installation customizations.](https://github.com/balupton/dotfiles/tree/master/source.bash)

#### `source.sh`

Available `source.sh` configuration:

- `DOROTHY_THEME` to specify which cross-shell theme you would like to use, supported themes are:

  - [`oz` for the bundled dorothy theme](https://github.com/bevry/dorothy/tree/master/themes/oz)

  - [`starship` for the external Starship theme](https://starship.rs) provided by [`setup-util-starship`](https://github.com/bevry/dorothy/tree/master/commands/setup-util-starship)

- Other `source.sh` configuration is detailed in the various functionality sections.

To open/edit your `source.sh` file:

```bash
edit "$DOROTHY/user/source.sh"
```

Examples of the `source.sh` file:

- [Dorothy's `defaults.sh` which contains the defaults.](https://github.com/bevry/dorothy/tree/master/sources/defaults.sh)
- [Benjamin Lupton's `source.sh` which contains a few shell configurations, as well as loading of a `env.sh` file.](https://github.com/balupton/dotfiles/tree/master/source.sh)

#### Existing dotfiles

If you are wanting to migrate your existing dotfiles configuration to Dorothy, you will probably have a legacy setup where instead of commands, you have functions, and instead of being cross-shell compatible, all your functions are written for one particular shell. To level-up your setup dramatically you will want to:

Turn each of these functions into their own command, such that they can be cross-compatible with any shell that calls it, do this by:

1. Moving the body of each function into their own command file at `$DOROTHY/user/commands/the-command-name`, and the shell prefix to the file, e.g. `#!/usr/bin/env bash` for bash, `#!/usr/bin/env zsh` for zsh, and `#!/usr/bin/env fish` for fish.

2. For functions that you want to keep in your shell environment rather than becoming commands, create a `$DOROTHY/user/sources/` directory, and store them in there with the appropriate prefix, and include them via your `source.bash`, `source.zsh`, or `source.sh` file.

For anything that modifies paths, or configures ecosystems, check the [`setup-paths-commands` command](https://github.com/bevry/dorothy/tree/master/commands/setup-paths-commands) to see if Dorothy already handles it for you, if so you can remove it.

### Installation

To automatically configure and install a brand new system, you can run [`setup-install`](https://github.com/bevry/dorothy/tree/master/commands/setup-install) which will go through the various installation scripts for various tooling, and ask you questions about configuring the defaults for your system, and if you wish to install from any backups.

To routinely keep your system up to date with all the latest tooling, you can use [`setup-update`](https://github.com/bevry/dorothy/tree/master/commands/setup-install).

Both of these use [your configuration](https://github.com/bevry/dorothy#configuration) to determine what to install and keep updated.

Available `source.bash` configuration:

- `APK_INSTALL` to specify what should be installed/updated with the APK ecosystem
- `APT_REMOVE` to specify what should be removed with the APT (Debian/Ubuntu) ecosystem
- `APT_ADD` to specify what should be installed/updated with the APT (Debian/Ubuntu) ecosystem
- `SNAP_INSTALL` to specify what should be installed/updated with the SNAP (Ubuntu) ecosystem
- `HOMEBREW_ARCH` to specify which architecture the Homebrew ecosystem should be used (only relevant for Apple Silicon machines)
- `HOMEBREW_INSTALL` to specify what should be installed/updated with the Homebrew (Mac) ecosystem
- `HOMEBREW_INSTALL_SLOW` to specify what should be installed/updated with the Homebrew (Mac) ecosystem, for things that take a very long time to install/update
- `HOMEBREW_INSTALL_CASK` to specify what applications should be installed/updated with the Homebrew (Mac) ecosystem
- `GO_INSTALL` to specify what should be installed/updated with the Golang ecosystem
- `NODE_INSTALL` to specify what global dependencies should be installed/updated with the Node (npm/yarn) ecosystem
- `PYTHON_INSTALL` to specify what should be installed/updated with the Python (Pip) ecosystem
- `RUBY_INSTALL` to specify what should be installed/updated with the Ruby (Gem) ecosystem
- `RUST_INSTALL` to specify what should be installed/updated with the Rust (Cargo) ecosystem
- `SETUP_UTILS` to specify what cross-package-manager utilities should be setup

If you would prefer to focus on a specify ecosystem, you the relevant commands are:

- `setup-linux-*`: installs and configures linux
- `setup-mac-*`: installs and configures mac
- [`setup-go`](https://github.com/bevry/dorothy/tree/master/commands/setup-go), [`setup-node`](https://github.com/bevry/dorothy/tree/master/commands/setup-node), [`setup-python`](https://github.com/bevry/dorothy/tree/master/commands/setup-python), [`setup-ruby`](https://github.com/bevry/dorothy/tree/master/commands/setup-ruby), [`setup-rust`](https://github.com/bevry/dorothy/tree/master/commands/setup-rust), [`setup-utils`](https://github.com/bevry/dorothy/tree/master/commands/setup-utils) installs and configures their various ecosystems
- `setup-*-fonts`: installs fonts for your specify operating system
- [`setup-bin`](https://github.com/bevry/dorothy/tree/master/commands/setup-bin): installs the CLI commands for the GUI apps you have installed

### Editors

The [`edit` command](https://github.com/bevry/dorothy/tree/master/commands/edit) will open your favorite installed editor automatically:

- in GUI environments (such as your desktop computer and laptop) will open your favorite available GUI editor (such as VSCode, Atom, etc)
- in terminal environments (such as accessing your computer via SSH, or accessing a remote computer that is using Dorothy) will open your favorite available terminal editor (such as vim, nano, etc)
- git prompts, such as confirming a commit message or git tag annotation, are automatically configured to use your favorite editor for your environment

Available `source.bash` configuration:

- `TERMINAL_EDITORS` to specify your preferential order of the command line editors, such that `git` or `edit` (when running over SSH) will use your favorite terminal editor that is installed
- `GUI_EDITORS` to specify your preferential order of the GUI editors, such that `edit` (when running inside a desktop environment) will use your favorite GUI editor that is available

This is functionality is initialized via the [`setup-editor-commands` command](https://github.com/bevry/dorothy/tree/master/commands/setup-editor-commands) which is evaluated via the appropriate `source/edit` file.

### Git

The [`setup-git` command](https://github.com/bevry/dorothy/tree/master/commands/setup-git) (which is included in the [`setup-update`](https://github.com/bevry/dorothy/tree/master/commands/setup-update) flow) will configure git such that:

- your user name, email, github preferences are all configured
- your favorite available diff editor is selected
- passwords will be stored securely in the operating system's secure keychain storage, so you don't have to renter them every time
- ssh will be configured, and includes support for [krypton](https://krypt.co) if available
- gpg will be configured, and includes support for [krypton](https://krypt.co) and [keybase](https://keybase.io) if available

Available `source` configuration:

- `GIT_PROTOCOL` to specify your preferred protocol when interacting with git repositories (`ssh` or `https`)
- `GIT_DEFAULT_BRANCH` to specify your preferred branch name for new repositories (e.g. `main` or `master`)
- `GPG_SIGNING_KEY` to specify your preferred GPG key

The [`key` command](https://github.com/bevry/dorothy/tree/master/commands/key) will walk you through the management and creation of your gpg keys.

The [`ssh-add-all` command](https://github.com/bevry/dorothy/tree/master/commands/ssh-add-all) will add new ssh keys to your ssh profile, and correct their permissions, ensuring they are correctly loaded from now on

The [`ssh-new` command](https://github.com/bevry/dorothy/tree/master/commands/ssh-new) will walk you through the creation of new ssh keys.

The [`git-review` command](https://github.com/bevry/dorothy/tree/master/commands/git-review) will open your favorite git review editor (e.g. GitHub Desktop, Gitfox, Tower, etc)

The [`git-fix-email` command](https://github.com/bevry/dorothy/tree/master/commands/git-fix-email) will allow you to make sure that a repository's git history is using the correct emails for the various users that have committed to it.

The [`git-protocol-apply` command](https://github.com/bevry/dorothy/tree/master/commands/git-protocol-apply) will ensure the remote you are using for your git repository is configured to the your desired git protocol.

### Secrets

Use the [`secret` command](https://github.com/bevry/dorothy/tree/master/commands/secret) to stop leaking your env secrets to the world when a malicious program sends your shell environment variables to a remote server. Instead, `secret` will use 1Password to securely expose your secrets to just the command that needs them. Specifically:

- secrets ares fetched directly from 1Password, with a short lived session
- secrets are cached securely for speed and convenience, only root/sudo has access to the cache (cache can be made optional if you want)
- secrets are not added to the global environment, only the secrets that are desired for the command are loaded for the command's environment only

Available `source` configuration:

- `SECRETS` to customize the database location for your [Secrets](https://github.com/bevry/dorothy#secrets) (defaults to `$DOROTHY/user/secrets`)

### DNS

One of the biggest security concerns these days with using the internet, is the leaking, and potential of modification of your DNS queries. A DNS query is what turns `google.com` to say `172.217.167.110`. With un-encrypted DNS (the default), your ISP, or say that public Wifi provider, can intercept these queries to find out what websites you are visiting, and they can even rewrite these queries, to direct you elsewhere. This is how many public Wifi providers offer their service for free, by selling the data they collect on you, or worse.

The solution to this is encrypted DNS. Some VPN providers already include it within their service, however most don't. Any if you have encrypted DNS, then you get the benefits of preventing evesdropping without the need for expensive VPN, and the risk of your VPN provider evesdropping on you.

Dorothy supports configuring your DNS to encrypted DNS via the [`setup-dns` command](https://github.com/bevry/dorothy/tree/master/commands/setup-dns), which includes installation and configuration for any of these:

- AdGuard Home
- Cloudflared
- DNSCrypt

The [`select-dns` command](https://github.com/bevry/dorothy/tree/master/commands/select-dns) lets you easily select your DNS provider out of many popular and secure variations, some even support adult content filtering and adblocking builtin.

The [`flush-dns` command](https://github.com/bevry/dorothy/tree/master/commands/flush-dns) lets you easily flush your DNS anytime, any system.

The [`select-hosts` command](https://github.com/bevry/dorothy/tree/master/commands/select-hosts) lets you easily select from a variety of HOSTS files for security and privacy, while maintaining your customizations.

Available `source` configuration for `setup-dns`:

- `DNS_SERVICE` to automate selection of which DNS provider to use

Available `source.bash` configuration for `select-dns`:

- `DNS_PROVIDER` to automate selection of which DNS service you wish to get your DNS Queries from, if you use `env`, then you can set `DNS_IPV4SERVERS` and `DNS_IPV6SERVERS` to the specific servers to use (this is useful if you are using a local AdGuard Home installation that is available on another machine)

- If you are a NoFapper, then you can configure `DNS_NOFAP`, `NOFAP_DISCORD_USERNAME`, `NOFAP_DISCORD_WEBHOOK`, `NOFAP_DISCORD_WEBHOOK_AUTH` to ensure your DNS prevents adult content, and alert your mates via the webhook if you are attempting to bypass it

### Downloads

The [`down` command](https://github.com/bevry/dorothy/tree/master/commands/down) will use the best downloader app that you currently have available for performing the download. Very useful for cross-system compatibility, as well as for resuming downloads. Supported apps are `aria2c`, `wget`, `curl`, `http` (httpie).

## Mac

The [`macos-state` command](https://github.com/bevry/dorothy/tree/master/commands/macos-state) for backup and restore of your various application and system preferences, from time machine backups, local directories, and sftp locations. This makes setting up clean installs easy, as even the configuration is automated. And it also helps you never forget an important file, like your env secrets ever again.

The [`macos-drive` command](https://github.com/bevry/dorothy/tree/master/commands/macos-drive) is for easily turning a MacOS installer download into a bootable MacOS installer USB drive.

The [`sparse-vault` command](https://github.com/bevry/dorothy/tree/master/commands/sparse-vault) lets you easily, and for free, create secure encrypted password-protected vaults on your mac, for securing those super secret data.

The [`itunes-owners` command](https://github.com/bevry/dorothy/tree/master/commands/itunes-owners) will generate a table of who legally owns what inside your iTunes Media Library — which is useful for debugging certain iTunes Store authorization issues, which can occur upon backup restorations.

The [`ios-dev` command](https://github.com/bevry/dorothy/tree/master/commands/ios-dev) lets you easily open the iOS simulator from the terminal.

The [`alias-details`](https://github.com/bevry/dorothy/tree/master/commands/alias-details), [`aliases`](https://github.com/bevry/dorothy/tree/master/commands/aliases), [`aliases-to-symlink`](https://github.com/bevry/dorothy/tree/master/commands/aliases-to-symlink), [`alias-path`](https://github.com/bevry/dorothy/tree/master/commands/alias-path), [`alias-verify`](https://github.com/bevry/dorothy/tree/master/commands/alias-details) commands will help you convert MacOS aliases into symlinks.

### Media

The [`podcast` command](https://github.com/bevry/dorothy/tree/master/commands/podcast) will convert an audio file to a new file with Apple's recommended podcast encoding and settings `aac-he`, which is super optimized for podcast use cases with tiny file sizes and the same quality.

The [`podvideo` command](https://github.com/bevry/dorothy/tree/master/commands/podvideo) will convert a video file to a new file with h264+aac encoding.

The [`youtube-dl-archive` command](https://github.com/bevry/dorothy/tree/master/commands/youtube-dl-archive) will download something from youtube, with all the necessary extras such that you know you got everything.

The [`video-merge` command](https://github.com/bevry/dorothy/tree/master/commands/video-merge) will merge multiple video files in a directory together into a single video file.

### Scripting

The [`expand-path` command](https://github.com/bevry/dorothy/tree/master/commands/expand-path) will output the results of glob patterns each on their own line.

The [`ok` command](https://github.com/bevry/dorothy/tree/master/commands/ok) will execute the command and always return a success exit code, in a way that is cross-shell compatible.

The [`silent` command](https://github.com/bevry/dorothy/tree/master/commands/silent) and its `silent-*` variants, will hide the various outputs of a command, in a way that is cross-shell compatible.

Any plenty more for cross-shell scripting with the following namespaces:

- `command-*`
- `confirm-*`
- `contains-*`
- `is-*`
- `rm-*`

### Utilities

The [`mail-sync` command](https://github.com/bevry/dorothy/tree/master/commands/mail-sync) will move everything from one IMAP provider to another IMAP provider.

The [`pdf-decrypt` command](https://github.com/bevry/dorothy/tree/master/commands/pdf-decrypt) will mass decrypt encrypted PDFs and store their results.

The [`xps2pdf` command](https://github.com/bevry/dorothy/tree/master/commands/xps2pdf) will convert a legacy XPS document into a modern PDF document.

[There are hundreds more commands](https://github.com/bevry/dorothy/tree/master/commands), so you can check them out or carry on knowing that when the time comes, Dorothy probably already has it.

## License

Public Domain via [The Unlicense](https://choosealicense.com/licenses/unlicense/)

```
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
