# Contributing

## Commands

Your command should go inside your user configuration's `commands` directory, which will be located at `$DOROTHY/user/commands/`. If you don't want the command to be public, put in side your `commands.local` directory instead. Commands that have demand by the wider community will be promoted to exist directly within Dorothy, but should always start within your own user configuration first.

If it is a bash command, it should always start with:

```bash
#!/usr/bin/env bash
source "$DOROTHY/sources/strict.bash"
```

If your bash command requires arrays, use:

```bash
source "$DOROTHY/sources/arrays.bash"
if test "$ARRAYS" = 'no'; then
	exit 95 # Operation not supported
fi
```

If your bash command makes use of `ripgrep`, then use the following to ensure it is installed and that it won't output something silly.

```bash
source "$DOROTHY/sources/ripgrep.bash"
```
