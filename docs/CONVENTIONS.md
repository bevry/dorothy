# Conventions

This document is for all the conventions that will benefit your contributions to your own dotfiles, as well as to the Dorothy core.

Not all files yet follow this convention, if you modify a file, please update its conventions.

## Editors

### Visual Studio Code

Visual Studio Code is recommended, as VSCode will detect Dorothy's preferences and adapt accordingly, enabling automatic correct formatting and linting as you go.

For formatting, it makes use of the following extensions:

- [shell-format](https://marketplace.visualstudio.com/items?itemName=foxundermoon.shell-format)
- [shellcheck](https://marketplace.visualstudio.com/items?itemName=timonwong.shellcheck)
- [editorconfig](https://marketplace.visualstudio.com/items?itemName=editorconfig.editorconfig)
- [prettier-vscode](https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode)

### All other editors

The other editors will require manual configuration, please make sure they are configured for the following:

- [shfmt](https://github.com/mvdan/sh#shfmt)
- [shellcheck](https://github.com/koalaman/shellcheck)
- [prettier](https://prettier.io), [editor installation instructions](https://prettier.io/docs/en/editors.html)
- [editorconfig](https://editorconfig.org), [editor installation instructions](https://editorconfig.org/#download)

## Committing

Each pushed commit should be working, and only change what it needs to. Your commits can contain junk code (aka placeholders) locally, however such junk should be removed/resolved before being squashed, and then pushed. This ensures the commit history remains accurate, providing diffs only on productive changes.

## Linting

All code should be formatted properly before it is pushed.

Use `dorothy format` to format and lint your code.

Use `dorothy test` to format, lint, and test your code.

## Indentation

For leftmost indentation (i.e. initial code alignment) use tabs.

For rightmost indentation (i.e. whitespace significant alignment, e.g. `EOF` blocks), use spaces.

For example, in the below code example, tab indentation is used for code alignment, however 4 spaces are used to indent the description of options, this is because inside the `<<-EOF` block, the tabs will be stripped as insignificant and the spaces will be kept, allowing the correct formatting for the help text went outputted to the user.

```bash
# =====================================
# Arguments

# help
function help() {
	cat <<-EOF >/dev/stderr
		ABOUT:
		Prompt the user for an input value in a clean and robust way.

		USAGE:
		ask [...options]

		OPTIONS:
		--question=<string>
		    Specifies the question that the prompt will be answering.
	EOF
	if test "$#" -ne 0; then
		echo-error "$@"
	fi
	return 22 # Invalid argument
}
```

## Naming

Commands shall be in `lower-case`.

Functions shall be in `lower_case`.

Shared variables, such as environment variables, exported variables, and variables that are intended to be sourced in, shall be in `UPPER_CASE`.

Global variables shall be in `lower_case`.

Local variables shall be in `_lower_case`.

When defining local variables, use one or multiple `local _var ...` declarations at the start of the function, with any necessary variable assignments on their own subsequent line.

```bash
# do
function alias_info {
	local _path _src _target
	_path="${1-"$option_path"}"
	# ...
}

# don't
function alias_info {
	local _path"${1-"$option_path"}" _src _target
	# ...
}
```

## Interpolation

For the benefits of syntax highlighting, use `$var` rather than `${var}` to interpolate variables, however, do the opposite in [here-documents](https://www.gnu.org/software/bash/manual/bash.html#Here-Documents) (aka `<<-EOF` and `<<EOF`).

```bash
# do
world='Earth'
echo "Hello, $world."
cat <<-EOF
Hello, ${world}.
EOF

# don't
world='Earth'
echo "Hello, ${world}."
cat <<-EOF
Hello, $world.
EOF
```

## Exit Codes

Specific exit codes should be used, rather than just `return 1` or `exit 1`. You can find what error codes are conventional, by running:

```bash
# install errno
setup-util errno

# output available exit codes
errno -l
```

`errno` is one of the [`moreutils`](https://rentes.github.io/unix/utilities/2015/07/27/moreutils-package/), they are worth reading about.

## Naming

Explicit names are better than generic names.

Commands must be `lower-case`. Functions must be `lower_case`. Environment variables must be `UPPER_CASE`. Exported variables should be `UPPER_CASE`. Local variables should be `lower_case`.

Variables that would otherwise conflict with another declaration should be prefixed with `_` or named differently.

As bash is a case-sensitive language, we are open to adopting `camelCase` and `CamelCase` if there is well reasoned grounds for it.

## Variables

Variable declarations should be the first line of the function, even if a variable is only conditionally needed. This consistency reduces errors, as when the logic does become more complicated, you don't risk multiple conflicting declarations of the same variable, and one can easily see what a function is working with.

Rename arguments as local variables. This names their intention.

Use `local` for everything that is not intended to be global.

Use `export` only for variables you want exposed to subshells, and such declarations should be done at the start of the command.

## Values

There is no difference between `1` and `'1'`, or `true`, and `'true'`, but there is a difference between `a_value_that_may_be_a_function` and `'definitely_a_value'`. As such, always make sure values are inside quotes.

Use single-quotes `'` if there is no need for interpolation, use double-quotes `"` if there is a need for interpolation.

If doing value substitution, then use double-quotes `"` however, as single-quotes will be outputted:

```bash
echo "${missing:-'bad'} ${missing:-"good"}"
# outputs:
# 'bad' good
```

Variable usage should be wrapped in double-quotes `"`, this offers consistency against edge cases where interpolation matters., e.g.

```bash
a='hello world'
echo-verbose $a
# outputs:
# [0] = [hello]
# [1] = [world]
echo-verbose "$a"
[0] = [hello world]
```

This is why we do `return "$?"` instead of `return $?`, the consistency even in times where it is not needed, creates a rewarding habit.

The exception to the plentiful usage of double-quote `"` interpolation is when passing command output, where we do `<(` instead.

```bash
args=('--flag' '--' 'hello' 'world')
mapfile -t list < <(echo-after-separator "$string")
echo-verbose "${list[@]}"
# outputs:
# [0] = [hello]
# [1] = [world]
```

## Special Characters

Sometimes you may need to use special characters, such as newlines, here are some tips:

```bash
# this is good
echo $'hello\nworld'
# but it is too simple for most use cases

# a more involved use case would be variable interpolation
name='dorothy'
echo $'hello\n$name'
# which outputs:
# hello
# $name
# which is not what we desire

# let's try this:
echo $"hello\n$name"
# which outputs:
# hello\ndorothy
# which is is still not desire

# so let's use this, which is the right technique for the right bits
echo 'hello'$'\n'"$name"
# which outputs:
# hello
# dorothy
# which is what we desire
```

Always use `"$HOME"` instead of `~`, as `~` doesn't work if it is inside a string, which becomes a common mistake when refactoring.

## Globbing

If you are intending to use `*` for globing, then ensure it is not inside a string as then it will not work correctly. For instance, to get all the paths inside your home folder, don't do `"$HOME/*"`, instead do `"$HOME/"*`.

If you are globbing, you may need to include these to ensure globbing is supported and enabled by the executing shell.

```bash
# enable ** globbing, which searches nested directories
source "$DOROTHY/sources/globstar.bash"
if test "$GLOBSTAR" = 'no'; then
	exit 95 # Operation not supported
fi
```

```bash
# enable no globbing results to return a failure exit code
source "$DOROTHY/sources/nullglob.bash"
if test "$NULLGLOB" = 'no'; then
	exit 95 # Operation not supported
fi
```

## Conditionals

### Prefer `test`

Always use `test ...` instead of `[` or `[[` unless doing bash special comparisons such as `[[ "$var" = *suffix ]]`.

`test` is easy to get help for `help test`, and works consistently across shells for the vast majority of cases.

### Use `=`, not `==`

Always use a single `=`, as `==` does not matter.

### Use `if`, not magic

Always use `if [condition] then [action]` statements over, implicit `condition && action` and `condition || action` magic.

Magic makes refactoring later more difficult, such as when eventually:

- conditions become more complicated, such as `if ... elif ... elif ... fi` statements
- adding more conditions, such as `condition && other-condition && action` or `(condition || else-condition) && action`
- adding more actions, such as: `condition && { action; other-action; }`

Magic is complex because it mixes and matches conditional statements with action statements, requiring grokking to understand the explicit intent of each statement, whether it is working as a condition, an action, or both as a condition and an action. `If ... then` statements make this explicit.

Magic is obtuse, because it the magic first needs to be understood (it's a wtf to beginners), and then to be parsed by our brains into the corresponding `if ... then` statements anyway. Such magic costs more brain cycles on each comprehension of the code, which reading of code is a task done thousands of times more than writing, just to save a few keystroke cycles initially. Our intent should be to use key strokes with the aim of saving mind cycles, not at the expense of mind cycles.

As a general ideal, our code (just like comments) should make an effort to explain to our brain what it does, rather than having to use our brains to understand what the code does. Our brains should spend less time functioning as machines that compile code, and more time functioning as creative agents.

## Arguments

Each command should respond to a `--help` flag:

https://github.com/bevry/dorothy/blob/a3f301e4c00f592b4319970ad0d3a0da77fba1d2/commands/ask#L5-L26

You can use:

- [`is-help`](https://github.com/bevry/dorothy/blob/master/commands/is-help) to emit help if there is a `--help` flag
- [`is-help-empty`](https://github.com/bevry/dorothy/blob/master/commands/is-help-empty) to emit help if there is a `--help` flag, or no arguments and flags.
- [`is-help-separator`](https://github.com/bevry/dorothy/blob/master/commands/is-help-separator) to emit help if there is a a `--help` flag, or no arguments and flags, or no `--` argument.

If an argument is required, you must:

- check if it is missing and output help:
  - `if is-help "$@" || ! is-needle 'argument' "$@"; then`
  - `if is-help-separator "$@"; then` if the usage is `cmd --`
- use `ask` or `choose-option` with the `--required` flag to prompt the user for the value:
  - `location="$(ask --question='What is the location to geocode?' --required --flag=location -- "$@")"`
  - `npm config set init.author.email "$(ask --question="What is the email you want to configure npm with?" --default="$(npm config get init.author.email)" --required --confirm)"`
  - `option_algorithm="$(choose-option --required --question='Which checksum algorithm do you wish to use?' --filter="$option_algorithm" -- "${algorithms[@]}")"`

To process flags, you can use [`get-flag-value`](https://github.com/bevry/dorothy/blob/master/commands/get-flag-value):

```bash
# an example where the first argument is the slug, and the rest are optional flags
slug="$(ask --question='What is the repository slug? org/repo' --default="${1-}" --required)"
filter="$(get-flag-value filter -- "$@")" # filter of the release files
destination="$(get-flag-value destination -- "$@")" # custom destination
extract="$(get-flag-value extract -- "$@")" # custom extraction

# an example where flags go before the -- and arguments after the --
mapfile -t options < <(echo-before-separator "$@")
option_algorithm="$(get-flag-value algorithm -- "${options[@]}")"
mapfile -t option_paths < <(echo-after-separator "$@")

# an example where we accept the same flag repeating
mapfile -t find_array < <(get-flag-value find --multi -- "$@")
mapfile -t replace_array < <(get-flag-value replace --multi -- "$@")
```

## Parsing STDIN

The `echo-*` commands in Dorothy typically take pass stdin or arguments, and runs some processing on them, before dumping them back to stdout.

For instance [`echo-lowercase`](https://github.com/bevry/dorothy/blob/master/commands/echo-lowercase) transforms the arguments, or the stdin, into lowercase.

Whereas [`echo-verbose`](https://github.com/bevry/dorothy/blob/master/commands/echo-verbose) will output the line or argument number, with its value, otherwise `[nothing provided]`.

Whereas [`echo-or-fail`](https://github.com/bevry/dorothy/blob/master/commands/echo-or-fail) will output whatever it received, but if it received nothing, it will return a failure exit code.
