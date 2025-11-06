# Private Configuration

## Dorothy User Configuration

Your user configuration goes to the XDG location of `~/.local/config/dorothy` which Dorothy symlinks to `~/.local/share/dorothy/user`, your user configuration consists of the following:

- `commands` directory, for public commands
- `commands.local` directory, for private commands (git ignored by default)
- `config` directory, for public configuration
- `config.local` directory, for private configuration (git ignored by default)

The order of preference within Dorothy is `(commands|config).local` first, then `(commands|config)`, then Dorothy's own `(commands|config)` then everything else.

You can find the various configuration files that are available to you by browsing Dorothy's default [`config` directory](https://github.com/bevry/dorothy/tree/master/config).

## Using `*.local`

### Git Ignored

When setting up your user configuration, Dorothy will make sure that the `*.local` directories are git ignored by default (using `$DOROTHY/user/.gitignore`), so that they are not unintentionally pushed to the public.

To share this git ignored configuration between your machines, you would have to use a tool like Dorothy's [`fs-copy` command](https://github.com/bevry/dorothy/blob/master/commands/fs-copy) to copy the configuration between machines.

### Strongbox

#### Initial Setup

To work around the sharing difficulty of git ignored configuration, Dorothy also supports [Strongbox](https://github.com/uw-labs/strongbox) encryption, which allows you to encrypt your `*.local` directories, sync them with git, and keep them private from everyone who doesn't have your Strongbox key.

To start using Strongbox for your `*.local` configuration:

```bash
# enter your user configuration directory
cd "$DOROTHY/user"

# install strongbox
setup-util-strongbox

# initialize strongbox for your user repository
strongbox -git-config

# add the .local directories to your user repository's .gitattributes file
printf '%s\n' '*.local/* filter=strongbox diff=strongbox' >> .gitattributes

# generate your strongbox key
strongbox -gen-key 'username/repository'

# remove the .local entries from your .gitignore
edit .gitignore

# add the files to git and thus strongbox
git add .

# check if they are encrypted
git diff-index -p master
```

When Dorothy checks out a Strongbox configured repository it will prompt you to copy of the Strongbox key to the machine beforehand, to ensure decryption works correctly.

#### Subsequent Setup

If you are setting up a new machine with your Strongbox encrypted Dorothy User Configuration, Dorothy will walk you through the setup.

## Examples of Private Configuration

### Using the `secret` command

Dorothy's [`secret` command](https://github.com/bevry/dorothy/blob/master/commands/secret) allows you to map 1Password fields to easy to use identifiers, that you can securely fetch via `secret get SUPER_SECRET_TOKEN` or expose only to a specific command `secret env SUPER_SECRET_TOKEN -- echo-style --invert='$SUPER_SECRET_TOKEN'`. Its database that maps a secret identifier to a 1Password vault, item, and field is stored in `$DOROTHY/user/config.local/secret.json`.

### Exporting Private Environment Variables

If you aren't using the [`secret` command](https://github.com/bevry/dorothy/blob/master/commands/secret), you can use `$DOROTHY/user/config.local/environment.bash` to export private environment variables:

```bash
#!/usr/bin/env bash
# ...
export SUPER_SECRET_TOKEN

# load my default environment configuration
source "$DOROTHY/user/config/environment.bash"

# export my private environment variables
SUPER_SECRET_TOKEN='you will never know'
```

### Private DNS Configuration

Use `$DOROTHY/user/config.local/dns.bash` to configure private DNS configuration customized for your machine's hostname:

```bash
#!/usr/bin/env bash
# ...

hostname="$(get-hostname)"
if [[ "$hostname" = 'vm-'* ]]; then
	# use quad9 in virtual machines
	export DNS_PROVIDER='quad9'

elif [[ "$hostname" = 'blue-'* ]]; then
	# use custom settings on servers
	# redacted

elif [[ "$hostname" = 'green-'* ]]; then
	# use custom settings on personal machines
	# redacted

elif [[ "$hostname" = 'red-'* ]]; then
	# use custom settings on family machines
	# redacted
fi
```

## Private Setup Configuration

Use `$DOROTHY/user/config.local/setup.bash` to skip loading your `$DOROTHY/user/config/setup.bash` configuration on virtual machine hostnames:

```bash
#!/usr/bin/env bash

hostname="$(get-hostname)"
if [[ "$hostname" != 'vm-'* ]]; then
	source "$DOROTHY/user/config/setup.bash"
fi
```
