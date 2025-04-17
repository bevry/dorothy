# Mastering Version Incompatibilities in Bash

This topic will discuss incompatibilities between bash versions.

Sources:

- [Bash Changelog](https://git.savannah.gnu.org/cgit/bash.git/tree/CHANGES)

## bash v3.1

From manual discovery:

- Introduces `array+=(...)` for appending to an array.

## bash v3.2

> [!CAUTION]
> This is this is the minimum required version for Dorothy.

From manual discovery:

- Introduces the ability to initialize multiple arrays at once, e.g. `local a=() b=()`
- Introduces the ability to define a subshell `function subshell () ( ... )`
- Introduces the ability to do grouped conditions `[[ ... && ( ... || ... ) ]]`

## bash v4.0

> [!NOTE]
> Dorothy's `bash.bash` includes cross-version compatible implementations of `mapfile`, `__get_read_decimal_timeout`.

From changelog:

- Introduces `read -i <default>` for setting a default value.
- Introduces `read -t <decimal-timeout>` for setting a decimal/fractional timeout.
- Introduces `|&` as shorthand for `2>&1 |`.
- Introduces `shopt -s globstar`.
- Introduces `mapfile`, and `readarray` alias for `mapfile`.
- Introduces `${var^}` and `${var,}` for uppercase and lowercase conversions.

From manual discovery:

- Introduces `l` inside `$-` if login shell.
- Introduces escape code support inside `echo -en`, prior to that `printf` must be used.
- No longer needs `export BASH_SILENCE_DEPRECATION_WARNING=1` to silence Bash v3 deprecation warnings on macOS

Changelog:

> This document details the changes between this version, bash-4.0-release,
> and the previous version, bash-4.0-rc1.
>
> a. `readarray` is now a synonym for `mapfile`.

> This document details the changes between this version, bash-4.0-alpha, and the previous version, bash-3.2-release.
>
> p. The `read' builtin has a new -i option which inserts text into the reply buffer when using readline.
>
> u. There is a new `mapfile` builtin to populate an array with lines from a given file.
>
> w. There is a new shell option: `globstar`. When enabled, the globbing code treats `**` specially -- it matches all directories (and files within them, when appropriate) recursively.
>
> y. The `-t` option to the `read` builtin now supports fractional timeout values.
>
> dd. The parser now understands `|&` as a synonym for `2>&1 |`, which redirects the standard error for a command through a pipe
>
> hh. There are new case-modifying word expansions: uppercase `(^[^])` and lowercase `(,[,])`. They can work on either the first character or array element, or globally. They accept an optional shell pattern that determines which characters to modify. There is an optionally-configured feature to include capitalization operators.

## bash v4.1

From changelog:

- Introduces `${arr:0:-N}` for getting the last N items or characters of an array or string.

Changelog:

> This document details the changes between this version, bash-4.1-alpha, and the previous version, bash-4.0-release.
>
> ee. Fixed an off-by-one error when computing the number of positional parameters for the ${@:0:n} expansion.

## bash v4.2

From changelog:

- Introduces `test -v VAR` for testing variable declaration

Changelog:

> This document details the changes between this version, bash-4.2-alpha, and the previous version, bash-4.1-release.
>
> f. test/[/[[ have a new -v variable unary operator, which returns success if `variable' has been set.

## bash v4.4

> [!CAUTION]
> This is this is the recommended minimum version for Dorothy.

> [!NOTE]
> Dorothy's `bash.bash` disables `nounset` on earlier bash versions to prevent crashes on accessing empty arrays. This has no notable downside, as the exact same logic paths are hit on modern bash versions, so undefined variables will be still be caught for resolution on them.

From changelog:

- No longer throws upon accessing an empty array. Previously must do `[[ "${#arr[@]}" -ne 0 ]] && for item in "${arr[@]}"; do`.

Changelog:

> This document details the changes between this version, bash-4.4-rc2, and the previous version, bash-4.4-beta2.
>
> a. Using `${a[@]}` or `${a[*]}` with an array without any assigned elements when the nounset option is enabled no longer throws an unbound variable error.

## bash v5.0

Nothing notable to Dorothy in this release.

Changelog:

> This document details the changes between this version, bash-5.0-beta, and the previous version, bash-5.0-alpha.
>
> q. Fixed a bug that caused `lastpipe' and `pipefail' to return an incorrect status for the pipeline if there was more than one external command in a loop body appearing in the last pipeline element.

> This document details the changes between this version, bash-5.0-alpha, and the previous version, bash-4.4-release.
>
> f. Fixed a bug that caused SHLVL to be incremented one too many times when creating subshells.
>
> i. The shell no longer runs traps if a signal arrives while reading command substitution output.
>
> o. Changes to make sure that $* and ${array[*]} (and $@/${array[@]}) expand the same way after the recent changes for POSIX interpretation 888.
>
> u. Fixed a bug that could result in command substitution, when executed in a context where word splitting is not performed, to leave a stray '\001' character in the string.
>
> ee. The ERR trap now reports line numbers more reliably.
>
> ss. Fixed a bug that allowed some redirections to stay in place if a later redirection failed.
>
> ww. Fixed a bug that could cause `read -N' to fail to read complete multibyte characters, even when the sequences are incomplete or invalid, with or without readline.
>
> mmm. `read -n 0' and `read -N 0' now try a zero-length read in an attempt to detect file descriptor errors.
>
> yyy. `wait' without arguments attempts to wait for all active process substitution processes.
>
> a. The `wait' builtin can now wait for the last process substitution created.
>
> o. A new shopt option: localvar_inherit; if set, a local variable inherits the value of a variable with the same name at the nearest preceding scope.
>
> x. The shell only sets up BASH_ARGV and BASH_ARGC at startup if extended debugging mode is active. The old behavior of unconditionally setting them is available as part of the shell compatibility options.

## bash v5.1

> [!NOTE]
> Dorothy's `bash.bash` provides cross-version compatible implementations of `__is_var_set`, `__uppercase_first_letter`, `__lowercase_first_letter`.

From changelog:

- Introduces `${var@U}`, `${var@u}`, `${var@L}`
- Introduces `test -v INDEX` for testing positional declaration
- Introduces fixed support for associative arrays

Changelog:

> This document details the changes between this version, bash-5.1-alpha, and the previous version, bash-5.0-release.
>
> x. `test -v N` can now test whether or not positional parameter N is set.
>
> dd. New `U`, `u`, and `L` parameter transformations to convert to uppercase, convert first character to uppercase, and convert to lowercase, respectively.
>
> oo. Fixed several issues with assigning an associative array variable using a compound assignment that expands the value of the same variable.
