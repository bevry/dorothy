# Conventions for Commands

## Location

There are several places commands are located, [ordered by least preferred to most preferred](https://github.com/bevry/dorothy/discussions/28).

- `$DOROTHY/commands/*` for Dorothy's stable commands
- `$DOROTHY/commands.beta/*` for Dorothy's beta commands
- `$DOROTHY/user/commands/*` for your public commands
- `$DOROTHY/user/commands.local/*` for your local/private commands

Commands that have demand by the wider community will be promoted to exist directly within Dorothy, but should always start within your own user configuration first.

## Structure

If it is a bash command, it's most basic template should be:

```bash
#!/usr/bin/env bash

function the_name_of_my_command() (
	source "$DOROTHY/sources/bash.bash"

	# ... the contents of my command ...
)

# fire if invoked standalone
if [[ "$0" = "${BASH_SOURCE[0]}" ]]; then
	the_name_of_my_command "$@"
fi
```

Filenames should have dashes, whereas function names should have underscores. If a function name is a single word, an underscore should be added to the end, such as `ask_`. This is because functions can behave differently to file invocations, so the distinction is important (see the notes on `eval_capture` for details).

The `function ... () (` creates a subshell, such that changes to our shell environment do not affect other commands.

The `source ...` sources our [`sources/bash.bash` file](https://github.com/bevry/dorothy/blob/master/sources/bash.bash) which sets sensible defaults, treats uncaught errors as exceptions, and provides some standard utilities, shims, and feature detection.

For instance:

- if your command needs to capture the exit status and/or output of a command, you can use `eval_capture ...`
- if your command requires `globstar` you can use `__require_globstar` to fail if that is unsupported.
- if your command accesses empty arrays you can use `__require_array 'empty'` to fail if that is unsupported.

If your bash command makes use of `ripgrep`, then use the following to ensure it is installed and that it won't output something silly.

```bash
source "$DOROTHY/sources/ripgrep.bash"
```

## User Commands

Dorothy prefers user commands to its own commands, allowing users to extend the functionality of the built in Dorothy commands.

For instance, if we want to have the user affirm honesty before any call to the the `ask` command, we can create our own `commands/ask` command in our user configuration:

```bash
touch -- "$DOROTHY/user/commands/ask"
fs-own --permissions=+x -- "$DOROTHY/user/commands/ask"
edit -- "$DOROTHY/user/commands/ask"
```

And set its contents to:

```bash
#!/usr/bin/env bash

function ask_() (
	source "$DOROTHY/sources/bash.bash"

	if confirm --linger --ppid=$$ --positive -- 'You will soon be asked a question. Do you affirm you reply honestly?'; then
		"$DOROTHY/commands/ask" "$@"
	else
		echo-style --error='If we cannot trust your answers, we cannot act reliably. Exiting...'
		return 1
	fi
)

# fire if invoked standalone
if [[ "$0" = "${BASH_SOURCE[0]}" ]]; then
	ask_ "$@"
fi
```

Now, when we call `ask` we will get our overlay:

```bash
ask --question='What is your name?'
```

As this is not a useful example, remember to remove it:

```bash
rm -f -- "$DOROTHY/user/commands/silent"
```

## Types

There are three types of commands:

1. generic: process arguments, execute something
1. installer: cross-platform installer for a package or application
1. transformer: transform input (args/stdin) into modified output

## Generics

These are your generic commands, they process arguments and execution something.

The example command is a good place to start: <https://github.com/bevry/dorothy/blob/master/commands.beta/example-generic-command>

## Installers

These are `setup-util-*` commands that install a utility (a CLI tool, or Application) in an automated and cross-platform way.

The one for CURL is a good place to start: <https://github.com/bevry/dorothy/blob/master/commands/setup-util-curl>

You want to replace all references of `curl` with your utility CLI name. If the utility has a different name to its CLI, you can also provide `--name="..."`. Add or remove as many methods (the uppercase options) as needed, by determining which methods (package systems) are available for the utility via its documentation or via [repology](https://repology.org/projects/).

## Transformers

These are most of the `echo-*` commands, they transform an input, be it an argument or a line of stdin, and do so easily via our [`sources/stdinargs.bash` helper](https://github.com/bevry/dorothy/blob/master/sources/stdinargs.bash).

The one for transforming inputs to lowercase is a good place to start: <https://github.com/bevry/dorothy/blob/master/commands/echo-lowercase>
