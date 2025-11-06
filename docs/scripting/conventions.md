# Conventions

## Committing

Each pushed commit should be working, and only change what it needs to. Your commits can contain junk code (aka placeholders) locally, however such junk should be removed/resolved before being squashed and pushed. This ensures the commit history is accurate, providing diffs only on productive changes.

## Linting

All code should be formatted properly before it is pushed.

Use `dorothy lint` to format/check your code.

Use `dorothy test` to test your code.

## Indentation

For leftmost indentation (i.e. initial code alignment) use tabs.

For rightmost indentation (i.e. whitespace significant alignment, e.g. `EOF` blocks), use spaces.

For example, in the below code example, tab indentation is used for code alignment, however 4 spaces are used to indent the description of options, this is because inside the `<<-EOF` block, the tabs will be stripped as insignificant and the spaces will be kept, allowing the correct formatting for the help text went outputted to the user.

```bash
# =====================================
# Arguments

# help
function help() {
	cat <<-EOF >&2
		ABOUT:
		Prompt the user for an input value in a clean and robust way.

		USAGE:
		ask [...options]

		OPTIONS:
		--question=<string>
		    Specifies the question that the prompt will be answering.
	EOF
	if [[ $# -ne 0 ]]; then
		__print_error "$@"
	fi
	return 22 # Invalid argument
}
```

## Naming

Explicit names are better than generic names.

Commands shall be in `lower-case`.

Functions shall be in `lower_case`.

Shared variables, such as environment variables, exported variables, and variables that are intended to be shared between scripts via sourcing, shall be in `UPPER_CASE`.

Global and local variables shall be in `lower_case`.

Variables that would otherwise conflict with another variable declaration should be named distinctly, rather than just using a `_` prefix or the like. Or they can be named the same, as bash does respect variable scopes:

```bash
#!/usr/bin/env bash

function test_dorothy_scopes() (
	source "$DOROTHY/sources/bash.bash"

	local var='a'
	__print_lines "$var"
	function nested_function {
		local var='b'
		__print_lines "$var"
	}
	nested_function
	__print_lines "$var"
	# a
	# b
	# a
)

# fire if invoked standalone
if [[ "$0" = "${BASH_SOURCE[0]}" ]]; then
	test_dorothy_scopes "$@"
fi
```

Variables can use the name of a function or command, e.g. `local source=...; printf '%s\n' "$source"` as variables do not conflict with functions/commands due to them requiring the `$` prefix.

As bash is a case-sensitive language, we are open to adopting `camelCase` and `CamelCase` if there is well reasoned grounds for it.

## Variables

Use `local` for everything that is not intended to be global.

Use `export` only for variables you want exposed to subshells, and such declarations should be done at the start of the command.

Variable declarations should be the first line of the function, even if a variable is only conditionally needed. This consistency reduces errors, as when the logic does become more complicated, you don't risk multiple conflicting declarations of the same variable, and one can easily see what a function is working with.

When defining local variables, use one or multiple `local var ...` declarations at the start of the function or block. It is ok to place variable assignments on their own subsequent line.

Create local variables for each argument, rather than using arguments directly. This names their intention and makes the code easier to follow.

## Values

To benefit from a clear distinction between values and variables/functions, wrap values in single or double quotes. There is no difference between `1` and `'1'`, or `true`, and `'true'`.

Use single-quotes `'` if there is no need for interpolation, use double-quotes `"..."` if there is a need for variable usage, use `$'...'` if there is a need for special characters such as newlines.

If doing value substitution, always use double-quotes `"` as single-quotes will be outputted:

```bash
printf '%s\n' "${missing:-'bad'} ${missing:-"good"}"
# outputs:
# 'bad' good
```

Variable usage should always be wrapped in double-quotes `"`, this offers consistency against edge cases where interpolation matters., e.g.

```bash
a='hello world'

# don't
echo-verbose $a
# outputs:
# [0] = [hello]
# [1] = [world]

# do
echo-verbose "$a"
# outputs:
# [0] = [hello world]
```

## Interpolation

Prefer `$var` rather than `${var}` for simple interpolations, for advanced interpolations it is up to you.

```bash
# recommended
local indent='  ' world='Earth'
printf '%s\n' "$world" # good
printf '%s\n' "${world}" # bad, unnecessary complexity
printf '%s\n' "${indent}Hello, $world." # fine
printf '%s\n' "${indent}Hello, ${world}." # also fine
```

Always use `"$HOME"` instead of `~`, as `~` doesn't work if it is inside a string, which becomes a common mistake when refactoring.

## Special Characters

Sometimes you may need to use special characters, such as newlines, here are some tips:

```bash
# this is good
printf '%s\n' $'hello\nworld'
# but it is too simple for most use cases

# a more involved use case would be variable interpolation
name='dorothy'
printf '%s\n' $'hello\n$name'
# which outputs:
# hello
# $name
# which is not what we desire

# let's try this:
printf '%s\n' $"hello\n$name"
# which outputs:
# hello\ndorothy
# which is is still not desire

# so let's use this, which is the right technique for the right bits
printf '%s\n' 'hello'$'\n'"$name" # fine
printf '%s\n' $'hello\n'"$name" # also fine
# which outputs:
# hello
# dorothy
# which is what we desire
```

## Exit Statuses

Specific exit statuses should be used, rather than just `return 1` or `exit 1`. Refer to [`docs/bash/errors.md`](https://github.com/bevry/dorothy/blob/master/docs/bash/errors.md) conventional errors statuses and how to capture them.

## Globbing

If you are intending to use `*` for globing, then ensure it is not inside a string as then it will not work correctly. For instance, to get all the paths inside your home folder, don't do `"$HOME/*"`, instead do `"$HOME/"*`.

If you are intending to use `**` for nested globbing, you will need to confirm the bash version executing the command supports it. You can do this via:

```bash
# require globstar support ** for nested globbing
source "$DOROTHY/sources/bash.bash"
require_globstar
```

## Conditionals

### Use `[[` with bash, `[` with sh, instead of `test`

Avoid `test` at all costs, as `test -n "$a" -a "$b" = "$c"` fails when `a='>'`, which Dorothy encountered in practice with it's `echo-*` commands.

If you are needing to do a privileged invocation of such a comparison, move the comparison into its own file and execute the file instead.

### Use `if`, not magic

Always use `if [condition] then [action]` statements over, implicit `condition && action` and `condition || action` magic.

Magic makes refactoring later more difficult, such as when eventually:

- conditions become more complicated, such as `if ... elif ... elif ... fi` statements
- adding more conditions, such as `condition && other-condition && action` or `(condition || else-condition) && action`
- adding more actions, such as: `condition && { action; other-action; }`

Magic is complex because it mixes and matches conditional statements with action statements, requiring grokking to understand the explicit intent of each statement, whether it is working as a condition, an action, or both as a condition and an action. `If ... then` statements make this explicit.

Magic is obtuse, because it the magic first needs to be understood (it's a wtf to beginners), and then to be parsed by our brains into the corresponding `if ... then` statements anyway. Such magic costs more brain cycles on each comprehension of the code, which reading of code is a task done thousands of times more than writing, just to save a few keystroke cycles initially. Our intent should be to use key strokes with the aim of saving mind cycles, not at the expense of mind cycles.

As a general ideal, our code (just like comments) should make an effort to explain to our brain what it does, rather than having to use our brains to understand what the code does. Our brains should spend less time functioning as machines that compile code, and more time functioning as creative agents.
