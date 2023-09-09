# Commands Highlight

After installing Dorothy, there will now be hundreds of [commands](https://github.com/bevry/dorothy/tree/master/commands) available to you, with the most prominent commands below.

You can also use `--help` with any command to learn more about it.

## `setup-system`

Use `setup-system install` on a new system to configure everything according to your preferences, or `setup-system update` to just update the system with the latest tooling and configuration.

## `setup-util`

The [`setup-util` command](https://github.com/bevry/dorothy/tree/master/commands/setup-util) command is an intelligent wrapper around every package system, allowing a cross-compatible way to install, upgrade, and uninstall utilities.

It is used by the hundreds of `setup-util-*` commands, which enable installing a utility as easy as `setup-util-...`.

You can also use the [`get-installer` command](https://github.com/bevry/dorothy/tree/master/commands/select-shell) to find an invoke an installer if Dorothy is aware of it.

## `select-shell`

By default, your terminal application will use the login shell configured for the system, as well as maintain a whitelist of available shells that can function as login shells.

Use the [`select-shell` command](https://github.com/bevry/dorothy/tree/master/commands/select-shell) to make this configuration reflect your preference.

## `dorothy theme`

Use for selecting the theme that your login shell uses.

## `edit`

Use the [`edit` command](https://github.com/bevry/dorothy/tree/master/commands/edit) to quickly open a file in your preferred editor, respecting terminal, SSH, and desktop environments.

## `down`

Use the [`down` command](https://github.com/bevry/dorothy/tree/master/commands/down) to download a file with the best available utility on your computer.

## `github-download`

Use the [`github-download` command](https://github.com/bevry/dorothy/tree/master/commands/github-download) to download files from GitHub without the tedium.

## `setup-git`

Use the [`setup-git` command](https://github.com/bevry/dorothy/tree/master/commands/secret) to correctly configure you git configuration.

Related commands:

-   `gpg-helper`
-   `ssh-helper`

## `secret`

Use the [`secret` command](https://github.com/bevry/dorothy/tree/master/commands/secret) to stop leaking your env secrets to the world when a malicious program sends your shell environment variables to a remote server. Instead, `secret` will use 1Password to securely expose your secrets to just the command that needs them. Specifically:

-   secrets ares fetched directly from 1Password, with a short lived session
-   secrets are cached securely for speed and convenience, only root/sudo has access to the cache (cache can be made optional if you want)
-   secrets are not added to the global environment, only the secrets that are desired for the command are loaded for the command's environment only

## DNS

One of the biggest security concerns these days with using the internet, is the leaking, and potential of modification of your DNS queries. A DNS query is what turns `google.com` to say `172.217.167.110`. With un-encrypted DNS (the default), your ISP, or say that public Wifi provider, can intercept these queries to find out what websites you are visiting, and they can even rewrite these queries, to direct you elsewhere. This is how many public Wifi providers offer their service for free, by selling the data they collect on you, or worse.

The solution to this is encrypted DNS. Some VPN providers already include it within their service, however most don't. And if you have encrypted DNS, then you get the benefits of preventing eavesdropping without the need for expensive VPN, and the risk of your VPN provider eavesdropping on you.

Dorothy supports configuring your DNS to encrypted DNS via the [`setup-dns` command](https://github.com/bevry/dorothy/tree/master/commands/setup-dns), which includes installation and configuration for any of these:

-   AdGuard Home
-   Cloudflared
-   DNSCrypt

The [`flush-dns` command](https://github.com/bevry/dorothy/tree/master/commands/flush-dns) lets you easily flush your DNS anytime, any system.

The [`select-hosts` command](https://github.com/bevry/dorothy/tree/master/commands/select-hosts) lets you easily select from a variety of HOSTS files for security and privacy, while maintaining your customizations.

## macOS

The [`macos-installer` command](https://github.com/bevry/dorothy/tree/master/commands/macos-drive) fetches the latest macOS installer.

The [`macos-drive` command](https://github.com/bevry/dorothy/tree/master/commands/macos-drive) helps you turn a macOS installer into a bootable USB drive.

The [`sparse-vault` command](https://github.com/bevry/dorothy/tree/master/commands/sparse-vault) lets you easily, and for free, create secure encrypted password-protected vaults on your mac, for securing those super secret data.

The [`alias-helper`](https://github.com/bevry/dorothy/tree/master/commands/alias-helper) helps you manage your macOS aliases, and if desired, convert them into symlinks.

Beta commands:

The [`macos-settings` command](https://github.com/bevry/dorothy/tree/master/commands.beta/macos-settings) helps configure macOS to your preferred system preferences.

The [`macos-state` command](https://github.com/bevry/dorothy/tree/master/commands.beta/macos-state) helps you backup and restore your various application and system preferences, from time machine backups, local directories, and sftp locations. This makes setting up clean installs easy, as even the configuration is automated. And it also helps you never forget an important file, like your env secrets ever again.

The [`macos-theme` command](https://github.com/bevry/dorothy/tree/master/commands.beta/macos-theme) helps you change your macOS theme to your preference, including your wallpaper and editor.

The [`itunes-owners` command](https://github.com/bevry/dorothy/tree/master/commands.beta/itunes-owners) generates a table of who legally owns what inside your iTunes Media Library — which is useful for debugging certain iTunes Store authorization issues, which can occur upon backup restorations.

Other notable beta commands:

-   `eject-all`
-   `icloud-helper`
-   `tmutil-helper`

## media

Beta commands:

The [`pdf-decrypt` command](https://github.com/bevry/dorothy/tree/master/commands.beta/pdf-decrypt) will mass decrypt encrypted PDFs.

The [`podcast` command](https://github.com/bevry/dorothy/tree/master/commands.beta/podcast) will convert an audio file to a new file with Apple's recommended podcast encoding and settings `aac-he`, which is super optimized for podcast use cases with tiny file sizes and the same quality.

The [`podvideo` command](https://github.com/bevry/dorothy/tree/master/commands.beta/podvideo) will convert a video file to a new file with h264+aac encoding.

The [`video-merge` command](https://github.com/bevry/dorothy/tree/master/commands.beta/video-merge) will merge multiple video files in a directory together into a single video file.

The [`xps2pdf` command](https://github.com/bevry/dorothy/tree/master/commands.beta/xps2pdf) will convert a legacy XPS document into a modern PDF document.

The [`ytd-helper` command](https://github.com/bevry/dorothy/tree/master/commands.beta/ytd-helper) helps you download videos from the internet with simplified options.

Other notable beta commands:

-   `get-codec`
-   `is-audio-mono`
-   `is-audio-stereo`
-   `pdf-encrypt`
-   `svg-export`
-   `to-png`
-   `trim-audio`
-   `wallhave-helper`

## `mail-sync`

The [`mail-sync` command](https://github.com/bevry/dorothy/tree/master/commands.beta/mail-sync) helps you migrate all your emails from one cloud provider to another.
