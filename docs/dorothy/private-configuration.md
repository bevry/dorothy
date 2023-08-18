# Private Configuration with `(config|commands).local`

Dorothy will not only look inside your `$DOROTHY/user/config/` directory for configuration files, but if `$DOROTHY/user/config.local/` exists, it will look there first. Furthermore, `config.local` and `commands.local` are both added to your `$DOROTHY/user/.gitignore` file, to by default, prevent their publishing to git.

This allows you to use `config` for public and generic configuration, and `config.local` for private and machine specific overrides.

## Private DNS Configuration

Use `$DOROTHY/user/config.local/dns.bash` to configure private DNS configuration, such as based on the hostname of the machine:

```bash
#!/usr/bin/env bash

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

Use `$DOROTHY/user/config.local/setup.bash` to disable loading default `setup.bash` configuration on virtual machine hostnames:

```bash
#!/usr/bin/env bash

hostname="$(get-hostname)"
if [[ "$hostname" != 'vm-'* ]]; then
	source "$DOROTHY/user/config/setup.bash"
fi
```
