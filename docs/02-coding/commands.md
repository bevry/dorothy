# Conventions for Commands

There are several places commands are located, [ordered by least preferred to most preferred](https://github.com/bevry/dorothy/discussions/28).

-   `$DOROTHY/commands/*` for Dorothy's commands
-   `$DOROTHY/user/commands/*` for your public commands
-   `$DOROTHY/user/commands.local/*` for your local/private commands

Commands that have demand by the wider community will be promoted to exist directly within Dorothy, but should always start within your own user configuration first.

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

## User Commands

Dorothy prefers user commands to its own commands, allowing users to extend the functionality of the built in Dorothy commands.

For instance, to display a whisper emote before silencing output with `silent`, we'd create our own `silent` command:

```bash
touch "$DOROTHY/user/commands/silent"
chmod +x "$DOROTHY/user/commands/silent"
edit "$DOROTHY/user/commands/silent"
```

Save it with the content:

```bash
#!/usr/bin/env bash
echo '🤫' > /dev/tty
"$DOROTHY/commands/silent" "$@"
```

And running it just like before:

```bash
silent echo 'do you hear me?'
```

As this is not the best example, remember to remove it:

```bash
rm "$DOROTHY/user/commands/silent"
```
