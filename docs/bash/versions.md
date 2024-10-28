# Mastering Version Incompatibilities in Bash

This topic will discuss incompatibilities between bash versions.

Sources:

-   [Bash Changelog](https://git.savannah.gnu.org/cgit/bash.git/tree/CHANGES)

## bash v4.0

From changelog:

-   Introduces `|&` as shorthand for `2>&1 |`.
-   Introduces `shopt -s globstar`.
-   Introduces `mapfile`, and `readarray` alias for `mapfile`.
-   Introduces support for decimal timeouts on `read -t TIMEOUT`.
-   Introduces `${var^}` and `${var,}` for uppercase and lowercase conversions.

From manual discovery:

-   Introduces `l` inside `$-` if login shell.
-   Introduces escape code support inside `echo -en`, prior to that `printf` must be used.
-   No longer needs `export BASH_SILENCE_DEPRECATION_WARNING=1` to silence Bash v3 deprecation warnings on macOS

Changelog:

> This document details the changes between this version, bash-4.0-release,
> and the previous version, bash-4.0-rc1.
>
> a. `readarray` is now a synonym for `mapfile`.

> This document details the changes between this version, bash-4.0-alpha, and the previous version, bash-3.2-release.
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

-   Introduces `${arr:0:-N}` for getting the last N items or characters of an array or string.

Changelog:

> This document details the changes between this version, bash-4.1-alpha, and the previous version, bash-4.0-release.
>
> ee. Fixed an off-by-one error when computing the number of positional parameters for the ${@:0:n} expansion.

## bash v4.2

From changelog:

-   Introduces `test -v VAR` for testing variable declaration

Changelog:

> This document details the changes between this version, bash-4.2-alpha, and the previous version, bash-4.1-release.
>
> f. test/[/[[ have a new -v variable unary operator, which returns success if `variable' has been set.

## bash v4.4

From changelog:

-   No longer crashes if accessing an empty array. Previously must do `[[ "${#arr[@]}" -ne 0 ]] && for item in "${arr[@]}"; do`.

Changelog:

> This document details the changes between this version, bash-4.4-rc2, and the previous version, bash-4.4-beta2.
>
> a. Using `${a[@]}` or `${a[*]}` with an array without any assigned elements when the nounset option is enabled no longer throws an unbound variable error.

## bash v5.1

From changelog:

-   Introduces `${var@U}`, `${var@u}`, `${var@L}`
-   Introduces `test -v INDEX` for testing positional declaration
-   Introduces fixed support for associative arrays

Changelog:

> This document details the changes between this version, bash-5.1-alpha, and the previous version, bash-5.0-release.
>
> x. `test -v N` can now test whether or not positional parameter N is set.
>
> dd. New `U`, `u`, and `L` parameter transformations to convert to uppercase, convert first character to uppercase, and convert to lowercase, respectively.
> oo. Fixed several issues with assigning an associative array variable using a compound assignment that expands the value of the same variable.
