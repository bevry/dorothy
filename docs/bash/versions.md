# Mastering Version Incompatibilities in Bash

This topic will discuss incompatibilities between bash versions.

Sources:

- [Bash Manual](https://www.gnu.org/software/bash/manual/bash.html)
- Bash Changelog:
    - <https://git.savannah.gnu.org/cgit/bash.git/tree/CHANGES>
    - <https://tiswww.case.edu/php/chet/bash/CHANGES>
    - <https://github.com/bminor/bash/blob/master/CHANGES>

## bash v3.1

From manual discovery:

- Introduces `array+=(...)` for appending to an array.

## bash v3.2

> [!IMPORTANT]
> This is this is the minimum required version for Dorothy.

From manual discovery:

- Introduces the ability to initialize multiple arrays at once, e.g. `local a=() b=()`
- Introduces the ability to define a subshell `function subshell () ( ... )`
- Introduces the ability to do grouped conditions `[[ ... && ( ... || ... ) ]]`
- Has a bug where using `\001` in an array would result in its duplication: `arr=($'\001'); printf '%q' "${arr[0]}" "${#arr[0]}"` outputs `$'\001\001'2`. Use `bash.bash:$ANSI_ALL` instead, such as `arr=("$ANSI_ALL")`.

## bash v4.0

> [!NOTE]
> Dorothy's `bash.bash` includes cross-version compatible implementations of `__split`, `__get_read_decimal_timeout`, `__get_uppercase_string`, `__get_lowercase_string`.

From manual discovery:

- Introduces `l` inside `$-` if login shell.
- Introduces escape code support inside `echo -en`, prior to that `printf` must be used.
- No longer needs `export BASH_SILENCE_DEPRECATION_WARNING=1` to silence Bash v3 deprecation warnings on macOS
- Fixes the bug where using `\001` in an array would result in its duplication: `arr=($'\001'); printf '%q' "${arr[0]}" "${#arr[0]}"` outputs `$'\001\001'2`

From changelog:

- Introduces `read -i <default>` for setting a default value.
- Introduces `read -t <decimal-timeout>` for setting a decimal/fractional timeout.
- Introduces `|&` as shorthand for `2>&1 |`.
- Introduces `shopt -s globstar`.
- Introduces `mapfile`, as well as the `readarray` alias for `mapfile`.
- Introduces `${var^}` and `${var,}` for uppercase and lowercase conversions.
- Introduces associative arrays, via `declare -A <var-name>`. Note that `declare -A assoc_array=(key1 value1 key2 value2)` is not yet supported, and only becomes working in bash v5.3.

<details>
<summary>Changelog:</summary>

> This document details the changes between this version, `bash-4.0-release`,
> and the previous version, `bash-4.0-rc1`.
>
> a. `readarray` is now a synonym for `mapfile`.

> This document details the changes between this version, `bash-4.0-alpha`, and the previous version,`bash-3.2-release`.
>
> c. There is a new variable, `$BASHPID`, which always returns the process id of the current shell.
>
> n. The `-p` option to `declare` now displays all variable values and attributes (or function values and attributes if used with `-f`).
>
> p. The `read` builtin has a new `-i` option which inserts text into the reply buffer when using readline.
>
> u. There is a new `mapfile` builtin to populate an array with lines from a given file.
>
> w. There is a new shell option: `globstar`. When enabled, the globbing code treats `**` specially -- it matches all directories (and files within them, when appropriate) recursively.
>
> y. The `-t` option to the `read` builtin now supports fractional timeout values.
>
> cc. There is a new `&>>` redirection operator, which appends the standard output and standard error to the named file.
>
> dd. The parser now understands `|&` as a synonym for `2>&1 |`, which redirects the standard error for a command through a pipe
>
> ee. The new `;&` case statement action list terminator causes execution to continue with the action associated with the next pattern in the statement rather than terminating the command.
>
> ff. The new `;;&` case statement action list terminator causes the shell to test the next set of patterns after completing execution of the current action, rather than terminating the command.
>
> hh. There are new case-modifying word expansions: uppercase `(^[^])` and lowercase `(,[,])`. They can work on either the first character or array element, or globally. They accept an optional shell pattern that determines which characters to modify. There is an optionally-configured feature to include capitalization operators.
>
> ii. The shell provides associative array variables, with the appropriate support to create, delete, assign values to, and expand them.
>
> jj. The `declare` builtin now has new `-l` (convert value to lowercase upon assignment) and `-u` (convert value to uppercase upon assignment) options. There is an optionally-configurable `-c` option to capitalize a value at assignment.

</details>

## bash v4.1

> [!CAUTION]
> Because of the bugs in this version, this version is discouraged.

> [!NOTE]
> Dorothy's `bash.bash` includes cross-version compatible implementations of `__open_fd`.

From manual discovery:

- Has a bug where modifications of a file do not actually modify the file, see comment at `bash.bash:__wait_for_semaphores`.

From changelog:

- Introduces `BASH_XTRACEFD` for redirecting xtrace output to a file descriptor.
- Introduces `{fd}` syntax for opening unused file descriptors.
- Fixes `${@:0:n}` and `${*:0:n}` incorrectly functioning as `n-1`, affects all prior versions. Workaround for prior versions: `args=("$@"); args=("${args[@]:0:n}")`.
- Fixes `printf -v array[index] format ...` for assigning formatted strings to array indices.

<details>
<summary>Changelog:</summary>

> This document details the changes between this version, `bash-4.1-alpha`, and the previous version, `bash-4.0-release`.
>
> o. New variable `$BASH_XTRACEFD`; when set to an integer bash will write xtrace output to that file descriptor.
>
> e. `printf -v` can now assign values to array indices.
>
> p. If the optional left-hand-side of a redirection is of the form `{var}`, the shell assigns the file descriptor used to `$var` or uses `$var` as the file descriptor to move or close, depending on the redirection operator.
>
> ee. Fixed an off-by-one error when computing the number of positional parameters for the `${@:0:n}` expansion.

</details>

## bash v4.2

> [!CAUTION]
> Because of the exit status bug in this version, this version is discouraged.

> [!NOTE]
> Dorothy's `bash.bash` includes cross-version compatible implementations of `__is_var_defined`, `__is_var_declared`, `__is_var_set`, `__get_date`, `__slice`.

From manual discovery:

- If a crash occurs via `errexit` the exit status will always be `1` instead of the intended exit status. Refer to <errors.md> for guidance.
- Has a bug where closing a file descriptor does not close the stdin of its process substitution, use Dorothy's `bash.bash:BASH_CLOSURE_OF_FILE_DESCRIPTOR_CLOSES_THE_STDIN_OF_ITS_PROCESS_SUBSTITUTION` to detect this and search for it to see the appropriate workarounds.
- `$'\001'` cannot be used in a regex comparison, e.g. `[[ $'\001' =~ $'\001' ]]` will crash with exit status `2`

From changelog:

- Introduces `\u...` and `\U...` escape sequences
- Introduces `test -v VAR` for testing variable declaration
- Introduces `printf %(datefmt)T`
- Introduces negative lengths for arrays and strings, e.g. `${array[@]:0: -1}` for all except the last element
- Introduces `lastpipe`

<details>
<summary>Changelog:</summary>

> This document details the changes between this version, `bash-4.2-alpha`, and the previous version, `bash-4.1-release`.
>
> b. Subshells begun to execute command substitutions or run shell functions or builtins in subshells do not reset trap strings until a new trap is specified. This allows `$(trap)` to display the caller's traps and the trap strings to persist until a new trap is set.
>
> d. `$'...'`, `echo`, and `printf` understand `\uXXXX` and `\UXXXXXXXX` escape sequences.
>
> f. `test`/`[`/`[[` have a new `-v` variable unary operator, which returns success if `variable` has been set.
>
> m. The `printf` builtin has a new %(fmt)T specifier, which allows time values to use `strftime`-like formatting.
>
> p. Negative subscripts to indexed arrays, previously errors, now are treated as offsets from the maximum assigned index + 1.
>
> t. There is a new `lastpipe` shell option that runs the last command of a pipeline in the current shell context. The `lastpipe` option has no effect if job control is enabled.

</details>

## bash v4.3

> [!CAUTION]
> Because of the exit status bug in this version, this version is discouraged.

> [!NOTE]
> Dorothy's `bash.bash` includes cross-version compatible implementations of `__get_var_declaration`.

From manual discovery:

- If a crash occurs via `errexit` the exit status will always be `1` instead of the intended exit status. Refer to <errors.md> for guidance.
- `declare -p ...<var>` fails to correctly find the declaration for `<var>` even though it exists within `declare -p`.

From changelog:

- Introduces `declare -n` for creating nameref variables.
- Fixes a bug where `<&-` would not close the file descriptor

<details>
<summary>Changelog:</summary>

> This document details the changes between this version, `bash-4.3-alpha`, and the previous version, `bash-4.2-release`.
>
> w. The shell has `nameref` variables and new `-n`(/`+n`) options to declare and unset to use them, and a `test -R` option to test for them.
>
> bbbbb. Fixed a bug that caused redirections like <&n- to leave file descriptor n closed if executed with a builtin command.

</details>

## bash v4.4

> [!IMPORTANT]
> This is this is the recommended minimum version for Dorothy.

> [!NOTE]
> Dorothy's `bash.bash` disables `nounset` on earlier bash versions to prevent crashes on accessing empty arrays. This has no notable downside, as the exact same logic paths are hit on modern bash versions, so undefined variables will be still be caught for resolution on them.

From manual discovery:

- Crashes now return the correct exit status.

From changelog:

- No longer throws upon accessing an empty array. Previously must do `[[ "${#arr[@]}" -ne 0 ]] && for item in "${arr[@]}"; do`.
- Fixes `printf -v var ''` not setting `var` to the empty string.

<details>
<summary>Changelog:</summary>

> This document details the changes between this version, `bash-4.4-rc2`, and the previous version, `bash-4.4-beta2`.
>
> a. Using `${a[@]}` or `${a[*]}` with an array without any assigned elements when the nounset option is enabled no longer throws an unbound variable error.
>
> This document details the changes between this version, `bash-4.4-alpha`, and the previous version, `bash-4.3-release`.
>
> d. The `mapfile` builtin now has a `-d` option to use an arbitrary character as the record delimiter, and a `-t` option to strip the delimiter as supplied with `-d`.
>
> m. `printf -v var ""` will now set `var' to the empty string, as if `var=""` had been executed.

</details>

## bash v5.0

> [!NOTE]
> Dorothy's `bash.bash` includes cross-version compatible implementations of `__get_epoch_time`.

From changelog:

- Introduces `EPOCHSECONDS` and `EPOCHREALTIME`
- Fixes zero-length keys in associative arrays
- No longer causes strange duplications when working with `$'\001'`

<details>
<summary>Changelog:</summary>

> This document details the changes between this version, `bash-5.0-beta2`, and the previous version, `bash-5.0-beta`.
>
> a. Associative and indexed arrays now allow subscripts consisting solely of whitespace.

> This document details the changes between this version, `bash-5.0-beta`, and the previous version, `bash-5.0-alpha`.
>
> q. Fixed a bug that caused `lastpipe` and `pipefail` to return an incorrect status for the pipeline if there was more than one external command in a loop body appearing in the last pipeline element.
>
> o. Changes to make sure that `$*` and `${array[*]}` (and `$@/${array[@]}`) expand the same way after the recent changes for POSIX interpretation 888.
>
> ooo. Fixed some cases where `printf -v` did not return failure status on a variable assignment error.

> This document details the changes between this version, `bash-5.0-alpha`, and the previous version, `bash-4.4-release`.
>
> a. The `wait` builtin can now wait for the last process substitution created.
>
> b. There is an `EPOCHSECONDS` variable, which expands to the time in seconds since the Unix epoch.
>
> c. There is an `EPOCHREALTIME` variable, which expands to the time in seconds since the Unix epoch with microsecond granularity.
>
> f. Fixed a bug that caused `SHLVL` to be incremented one too many times when creating subshells.
>
> i. The shell no longer runs traps if a signal arrives while reading command substitution output.
>
> n. Fixed a bug that could cause an IFS character in a word to result in an extra `\001` character in the expansion.
>
> o. A new `shopt` option: `localvar_inherit`; if set, a local variable inherits the value of a variable with the same name at the nearest preceding scope.
>
> u. Fixed a bug that could result in command substitution, when executed in a context where word splitting is not performed, to leave a stray `\001` character in the string.
>
> x. The shell only sets up `BASH_ARGV` and `BASH_ARGC` at startup if extended debugging mode is active. The old behavior of unconditionally setting them is available as part of the shell compatibility options.
>
> ee. The `ERR` trap now reports line numbers more reliably.
>
> ss. Fixed a bug that allowed some redirections to stay in place if a later redirection failed.
>
> ww. Fixed a bug that could cause `read -N` to fail to read complete multibyte characters, even when the sequences are incomplete or invalid, with or without readline.
>
> mmm. `read -n 0` and `read -N 0` now try a zero-length read in an attempt to detect file descriptor errors.
>
> yyy. `wait` without arguments attempts to wait for all active process substitution processes.

</details>

## bash v5.1

> [!IMPORTANT]
> This is this is the recommended minimum version for Dorothy on SUSE platforms.

> [!NOTE]
> Dorothy's `bash.bash` provides cross-version compatible implementations of `__get_uppercase_string`, `__get_uppercase_first_letter`, `__get_lowercase_string`.

From changelog:

- Introduces `${var@U}`, `${var@u}`, `${var@L}` for uppercase, uppercase first letter, and lowercase conversions.
- Introduces `test -v INDEX` for testing positional declaration
- Introduces associative array compound assignments with key-value pairs, e.g. `assoc_array=(key1 value1 key2 value2)`, however is broken until 5.3.
- Fixes `wait_for: No record of process ...` crashes; according to [this user report](https://gist.github.com/azat/affbda3f8c6b5c38648d4ab105777d88), it is this version that fixes it

<details>
<summary>Changelog:</summary>

> This document details the changes between this version, `bash-5.1-beta`, and the previous version, `bash-5.1-alpha`.
>
> e. Make sure `SIGCHLD` is blocked in all cases where `waitchld()` is not called from a signal handler.

> This document details the changes between this version, `bash-5.1-alpha`, and the previous version, `bash-5.0-release`.
>
> x. `test -v N` can now test whether or not positional parameter `N` is set.
>
> dd. New `U`, `u`, and `L` parameter transformations to convert to uppercase, convert first character to uppercase, and convert to lowercase, respectively.
>
> gg. Associative arrays may be assigned using a list of key-value pairs within a compound assignment. Compound assignments where the words are not of the form `[key]=value` are assumed to be key-value assignments. A missing or empty key is an error; a missing value is treated as `NULL`. Assignments may not mix the two forms.
>
> oo. Fixed several issues with assigning an associative array variable using a compound assignment that expands the value of the same variable.

</details>

## bash v5.2

From changelog:

- Nameref variables (`declare -n nameref`) now properly functional.
- Fixes `test -v` with `@` and `*` indices.
- Fixes `printf`, `read`, `wait` assignment to associative arrays.

<details>
<summary>Changelog:</summary>

> This document details the changes between this version, `bash-5.2-alpha`, and the previous version, `bash-5.1-release`.
>
> g. Fixed a problem with performing an assignment with `+=` to an array element that was the value of a nameref.
>
> h. Fixed a bug that could cause a nameref containing an array reference using `@` or `*` not to expand to multiple words.
>
> j. Associative array assignment and certain instances of referencing (e.g., `test -v`) now allow `@` and `*` to be used as keys.
>
> bb. Array references using `@` and `*` that are the value of nameref variables (`declare -n ref='v[@]' ; echo $ref`) no longer cause the shell to exit if `set -u` is enabled and the array (`v`) is unset.
>
> ss. Builtins like `printf`/`read`/`wait` now behave more consistently when assigning arbitrary keys to associative arrays (like `]`. when appropriately quoted).

</details>

## bash v5.3

From changelog:

- Introduces performant command interpolation, via command substitution `${command;}` or `${|command;}` instead of process substitution `$(command)`.
- Introduces `fltexpr` for floating point arithmetic.
- Fixes associative array compound assignments with key-value pairs, e.g. `assoc_array=(key1 value1 key2 value2)`.
- When debugging, `LINENO` is now correct.
- We've likely encountered the plethora of bugs fixed in this version, however, by the time of its release, Dorothy already implemented workarounds, such that these bugs are not surfaced.

<details>
<summary>Changelog:</summary>

> This document details the changes between this version, `bash-5.3-rc2`, and the previous version, `bash-5.3-rc1`.
>
> f. Fixed an issue with a backslash-newline appearing after a right paren in a nested subshell command.
>
> h. Fixed an issue with a nameref variable referencing an unset array element when the `nounset` option is enabled.

> This document details the changes between this version, `bash-5.3-rc1`, and the previous version, `bash-5.3-beta`.
>
> d. Changes to `set -e` exit behavior in posix mode, since POSIX now says to exit as if executing the `exit builtin with no arguments`.
>
> a. There is a new `fltexpr` loadable builtin to perform floating-point arithmetic similarly to `let'.

> This document details the changes between this version, `bash-5.3-beta`, and the previous version, `bash-5.3-alpha`.
>
> e. The bash build process now assumes a `C90` compilation environment and a `POSIX.1-1990` execution environment.
>
> x. Fix for return status for commands whose return status is being inverted when set -e is ignored.
>
> i. `wait -n` can now return terminated process substitutions, jobs about which the user has already been notified (like `wait` without options)
>
> q. If `exit` is run in a trap and not supplied an exit status argument, it uses the value of `$?` from before the trap only if it's run at the trap's `top level` and would cause the trap to end (that is, not in a subshell). This is from Posix interp 1602.

> This document details the changes between this version, `bash-5.3-alpha`, and the previous version, `bash-5.2-release`.
>
> c. Fixed a bug with subshell command execution that caused it to set `LINENO` incorrectly.
>
> g. Fixed a bug where nested word expansions confused the state parser and resulted in quotes being required where they should not have been.
>
> s. Fixed a bug that caused the shell to unlink FIFOs used for process substitution before a compound command completes.
>
> u. Fixed a bug that caused subshells not to run the `EXIT` trap if a signal arrived after the command and before returning to the caller.
>
> v. Fixed a bug where `wait` without arguments could wait for inherited process substitutions, which are not children of this shell.
>
> w. Fixed a bug with expanding $\* in a here-document body.
>
> y. Change for POSIX interpretation 1602 about the default return status for `return` in a trap command.
>
> gg. Fixed a bug that caused `eval` to run the ERR trap in commands where it should not.
>
> zz. Fixed key-value pair associative array assignment to be more consistent with compound array assignment, and indexed array assignment (`a=(zero one)`) to be more consistent with explicitly assigning indices one by one.
>
> rrr. Treat the failure to open file in `$(<file)` as a non-fatal expansion error instead of a fatal redirection error.
>
> ttt. Fix `{var}>&-` so it doesn't silently close stdin if var is not a number.
>
> yyy. Fix bug that caused `FUNCNAME` not to be reset after a parse error with compound assignments to local variables.
>
> kkkk. `BASH_REMATCH` can now be a local variable.
>
> xxxx. Fix bug with closing `/dev/fd` process substitutions in shell functions.
>
> j. `trap` has a new `-P` option that prints the trap action associated with each signal argument.
>
> l. `printf` uses the `alternate form` for `%q` and `%Q` to force single quoting.
>
> s. New form of command substitution: `${ command; }` or `${|command;}` to capture the output of COMMAND without forking a child process and using pipes.
>
> q. `GLOBSORT`: new variable to specify how to sort the results of pathname expansion (`name`, `size`, `blocks`, `mtime`, `atime`, `ctime`, `none`) in ascending or descending order.
>
> x. `BASH_TRAPSIG`: new variable, set to the numeric signal number of the trap being executed while it's running.

</details>
