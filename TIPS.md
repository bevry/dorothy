# dorothy

> - [Dorothy Tips](https://github.com/bevry/dorothy/discussions/categories/tips)

# shell features

## manuals

> - [bash manual](http://www.gnu.org/software/bash/manual/bash.html#Shell-Parameter-Expansion)

## tutorials

> - [Shell Scripts Matter](https://dev.to/thiht/shell-scripts-matter)

## exit codes

> - [common exit codes](https://gist.github.com/shinokada/5432e491f9992da994fbed05948bfba1)

```bash
# get exit codes
errno -l | cut -d' ' -f2-

# ignore exit code with Dorothy's `ok` command
ok the-error-command arg1 arg2
ok exit 1

# ignore exit code with `|| :` bash builtin, note that this makes exit code always 0
the-error-command arg1 arg2 || :
echo $?  # 0

# ignore exist code with `|| true` for cross-shell, note that this makes exit code always 0
the-error-command arg1 arg2 || true
echo $?  # 0
```

## get backslash escapes

```bash
printf '%q' "$value"
```

## builtins

> - [bash manual: builtins](https://www.gnu.org/software/bash/manual/bash.html#Bash-Builtins)

```bash
# in bash
help

# in any shell
bash -c help
```

## functions

> - [bash manual: functions](https://www.gnu.org/software/bash/manual/bash.html#Shell-Functions)
>   - [stack exchange](http://stackoverflow.com/a/6212408/130638)

## pipes

### redirections

> - [bash manual: redirections](https://www.gnu.org/software/bash/manual/bash.html#Redirections)
>   - [stack exchange](http://unix.stackexchange.com/q/70963/50703)
> - [fish manual: redirections](http://fishshell.com/docs/current/tutorial.html#tut_pipes_and_redirections)

### accidental subshells

> - [explanation](https://mywiki.wooledge.org/BashFAQ/024)

```bash
# never apply variables within pipes
printf '%s\n' foo bar | mapfile -t line
printf 'total number of lines: %s\n' "${#line[@]}"
# outputs 0

# always use <, <<<, or <( instead
mapfile -t line < <(printf '%s\n' foo bar)
printf 'total number of lines: %s\n' "${#line[@]}"
# outputs 2
```

## loops

> - [bash manual: loops](https://www.gnu.org/software/bash/manual/bash.html#Looping-Constructs)
>   - [examples](https://www.cyberciti.biz/faq/bash-for-loop/)

### trailing lines

> - [stack exchange](https://unix.stackexchange.com/a/418067/50703)

```bash
# fails to output trailing line:
printf $'a\nb\nc' | while read -r line; do
	echo "[$line]"
done
# [a]
# [b]

# outputs correctly, including the trailing line:
printf $'a\nb\nc' | while read -r line || test -n "$line"; do
	echo "[$line]"
done
# [a]
# [b]
# [c]
```

## conditionals

> - [bash manual: conditionals](https://www.gnu.org/software/bash/manual/bash.html#Conditional-Constructs)
> - [bash manual: grouping](https://www.gnu.org/software/bash/manual/bash.html#Command-Grouping)
> - [bash manual: test](https://www.gnu.org/software/bash/manual/bash.html#index-test)
>   - [stack exchange](http://unix.stackexchange.com/a/306115/50703)
>   - `help test` and `man test` for help

Summary:

- `-z` is empty string: True if the length of string is zero.
- `-n` is string: True if the length of string is nonzero.
- `-e` is file or directory.
- `-d` is dir: True if file exists and is a directory.
- `-f` is file: True if file exists and is a regular file.
- `-s` is nonempty file: True if file exists and has a size greater than zero.
- `=` is equal: True if the strings s1 and s2 are identical.

### `[[` and `]]`

> - [stack exchange](http://unix.stackexchange.com/a/246320/50703)

Only useful if doing `[[ blah = *blah* ]]` or the like.

## variables

### special variables

> - [bash manual](https://www.gnu.org/software/bash/manual/bash.html#Special-Parameters)
>   - [stack exchange](https://stackoverflow.com/a/5163260/130638)
>   - `$@` vs `$*`
>     - [stack exchange](https://github.com/koalaman/shellcheck/wiki/SC2124)

### safe variables

> - https://wiki.bash-hackers.org/syntax/pe#use_a_default_value
> - https://stackoverflow.com/a/14152610/130638
> - https://stackoverflow.com/a/39621322
> - http://www.gnu.org/software/bash/manual/bash.html#Shell-Parameter-Expansion

- `${var:-value}`
  - if var is truthy, use `var`
  - if var is falsey, use `value`
- `${var-value}`
  - if var is bound, use `var`
  - if var is unbound, use `value`
- `test -n "${var-}"` and `test -n "${var-}"`
  - if var is truthy, pass
  - as both empty string values have 0 characters length
- `test -z "${var-}"` and `test -z "${var-}"`
  - if var is falsey, pass
  - as both empty string values have 0 characters length
- `test -v a`
  - if var is bound, pass
  - if var is unbound, fail
  - only works on: bash >= 4.2 && zsh
- `${var:?message}`
  - if var is truthy, use `var`
  - if var is falsey, stderr the message
- `${var?message}`
  - if var is bound, use `var`
  - if var is unbound, stderr the message
- `${var:=value}`
  - if var is truthy, use `var`
  - if var is falsey, set `var` to the `value`
- `${var=value}`
  - if var is bound, use `var`
  - if var is unbound, set `var` to the `value`

### string replacement

> - http://tldp.org/LDP/abs/html/string-manipulation.html

```bash
# get first line, via pipe, tried and tested
echo -e 'a\nb' | echo-first

# get first line, via variable
var=$'one\ntwo'; echo "${var%$'\n'*}" # one

# get everything before the first X
var="aXbXc"; echo "${var%%X*}" # a

# get everything after the first X
var="aXbXc"; echo "${var#*X}" # bXc

# get everything before the last X
var="aXbXc"; echo "${var%X*}" # aXb

# get everything after the last X
var="aXbXc"; echo "${var##*X}" # c


# replace first o with O
echo "${var/o/O}"

# replace all o with O
echo "${var//o/O}"
```

## arrays

> - [bash manual](https://www.gnu.org/software/bash/manual/bash.html#Arrays)
> - [tutorial](https://www.shell-tips.com/bash/arrays/)

Input:

```bash
a=(
	a
	b
	'c d'
	e
	f
)
a+=(
	g
	'h i'
	j
)

for r in "${a[@]}"; do
    echo "[$r]"
done

# args length
echo "$#"

# array length
echo "${#a[@]}"
# ^^^ this has issues
# you probably want to use `is-array-empty`, `is-array-full`, `get-array-count`, `is-array-count`
# see the note at the end of this chapter for details

# contains
if test "${a[@]}" = *"c"*; then
	echo 'with c'
else
	echo 'without c'
fi
if test "${a[@]}" = *"c d"*; then
	echo 'with c d'
else
	echo 'without c d'
fi

# subsets
echo "${a[@]:2:1}" # get one item, from the second index starting at 0
# 'c d'

echo "${a[@]:2:3}" # get three items, from the second index starting at 0
# 'c d', e, f

echo "${a[@]:1}"  # get all items, from the first index starting at 0
# b, 'c d', e, f, g, 'h i', j

echo ${a[@]::2}  # get all items until the second index, starting at 0
# a, b
```

### array lengths

```bash
source "$DOROTHY/sources/strict.bash"

# mapfile of an empty value will produce an array with 1 value which is empty
mapfile -t a < <(failure-because-this-method-does-not-exist | fail-on-empty-stdin 'empty stdin')
# bash: failure-because-this-method-does-not-exist: command not found
# empty stdin
echo $? # 0
echo "${#a[@]}" # 1
echo "${a[@]}" # empty

# when using <() the correct length is returned
# however even with strict, there is no hard fail
mapfile -t a < <(stderr echo 'error' | fail-on-empty-stdin 'empty stdin')
# error
# empty stdin
echo $?  # 0
echo "${#a[@]}" # 0

# in both cases this sanity check is necessary
if is-array-empty "${a[@]}"; then
	stderr echo 'failure'
	exit 1
fi

# depending on your use case, you may also find these useful
is-array-partial "${a[@]}"
is-array-empty "${a[@]}"
is-array-empty-or-partial "${a[@]}"
is-array-full "${a[@]}"
is-array-full-or-partial "${a[@]}"
is-array-count 1 "${a[@]}"
is-array-count-ge 1 "${a[@]}"
```

### strings to arrays

> - [bash manual: word splitting](https://www.gnu.org/software/bash/manual/bash.html#Word-Splitting)
>   - [explanation](https://unix.stackexchange.com/a/676876/50703)
> - [`readarray`](https://www.gnu.org/software/bash/manual/bash.html#index-readarray) is an alias for [`mapfile`](https://www.gnu.org/software/bash/manual/bash.html#index-mapfile)

#### newline deliminator

```bash
str=$'a b\nc d'

# these `read -ra` all fail to output the second line [c d]
read -ra a <<< "$str"; echo-verbose "${a[@]}"
# outputs:
# [0] = [a]
# [1] = [b]
read -ra a -d $'\n' <<< "$str"; echo-verbose "${a[@]}"
# outputs:
# [0] = [a]
# [1] = [b]
IFS=$'\n' read -ra a <<< "$str"; echo-verbose "${a[@]}"
# outputs:
# [0] = [a b]

# these `mapfile -t` solutions are equivalent, and work
mapfile -t a <<< "$str"; echo-verbose "${a[@]}"
mapfile -td $'\n' a <<< "$str"; echo-verbose "${a[@]}"
# both output:
# [0] = [a b]
# [1] = [c d]
```

#### custom deliminator

```bash
str=$'a b\nc d'

# these `read -ra` solutions are equivalent, and have issues, both skipping the second line
read -ra a -d ' ' <<< "$str"; echo-verbose "${a[@]}"
# outputs:
# [0] = [a]
IFS=' ' read -ra a <<< "$str"; echo-verbose "${a[@]}"
# outputs:
# [0] = [a]
# [1] = [b]

# these `mapfile -t` solutions are equivalent, and have issues
mapfile -td ' ' a <<< "$str"; echo-verbose "${a[@]}"
# outputs mangled newlines:
# [0] = [a]
# [1] = [b
# c]
# [2] = [d
# ]
mapfile -td ' ' a <<< 'a b'; echo-verbose "${a[@]}"
# outputs mangled trailing item:
# [0] = [a]
# [1] = [b
# ]
mapfile -td ' ' a <<< 'a b '; echo-verbose "${a[@]}"
# outputs trailing item, but adds a dummy item
# [0] = [a]
# [1] = [b]
# [2] = [
# ]
```

The peculiarities for `read -ra` are because `read` goes one line at a time, as it is intended for while loops over draining file descriptors, such as pipes.

The peculiarities for `mapfile -td` are just weird.

#### recommendations

```bash
str=$'a b\nc d'

# for a custom deliminator for input that may span multiple lines
fodder="$(echo-split ' ' -- "$str")"
mapfile -t a <<< "$fodder"; echo-verbose "${a[@]}"
# output correct:
# [0] = [a]
# [1] = [b]
# [2] = [c]
# [3] = [d]

# or even multiple arguments
fodder="$(echo-split ' ' -- "$str" "$str")"
mapfile -t a <<< "$fodder"; echo-verbose "${a[@]}"
# outputs correct:
# [0] = [a]
# [1] = [b]
# [2] = [c]
# [3] = [d]
# [4] = [a]
# [5] = [b]
# [6] = [c]
# [7] = [d]

# for a custom deliminator for input that is guaranteed to only span a single line
IFS=' ' read -ra a <<< 'a b'; echo-verbose "${a[@]}"
# output correct:
# [0] = [a]
# [1] = [b]

# for a newline deliminator that is not recursive between elements
mapfile -t a <<< "$str"; echo-verbose "${a[@]}"
# output correct:
# [0] = [a b]
# [1] = [c d]
mapfile -t a < <(echo-lines 'a b' 'c d'); echo-verbose "${a[@]}"
# output correct:
# [0] = [a b]
# [1] = [c d]

# be careful of arguments being jumbled into a single line when parsing to mapfile
list=('a b' 'c d')
mapfile -t a <<< "${list[@]}"; echo-verbose "${a[@]}"
# output incorrect:
# [0] = [a b c d]
mapfile -t a <<< "${list[*]}"; echo-verbose "${a[@]}"
# output incorrect:
# [0] = [a b c d]

# such jumbled compression is not a problem with echo-split
list=('a b' 'c d')
fodder="$(echo-split '' -- "${list[@]}")"
mapfile -t a <<< "$fodder"; echo-verbose "${a[@]}"
# output correct:
# [0] = [a b]
# [1] = [c d]

# you can even use echo-split to split on recursive newlines
list=($'a\nb' $'c\nd')
fodder="$(echo-split $'\n' -- "${list[@]}")"
mapfile -t a <<< "$fodder"; echo-verbose "${a[@]}"
# output correct:
# [0] = [a]
# [1] = [b]
# [2] = [c]
# [3] = [d]

# which the typical mapfile won't do
list=($'a\nb' $'c\nd')
mapfile -t a <<< "${list[@]}"; echo-verbose "${a[@]}"
# output incorrect:
# [0] = [a]
# [1] = [b c]
# [2] = [d]

# as such these will always work as expected
echo-lines ...  # for recursive and non-recursive newlines
echo-split ''    -- ...  # equivalent for recursive and non-recursive newlines
echo-split $'\n' -- ...  # equivalent for recursive and non-recursive newlines
echo-split ' '   -- ...  # for custom deliminator
```

If you don't meed the result as an array via `mapfile -t lines` which you would likely then use `for line in "${lines[@]}"; do` iterate though, then you can skip a lot of assignment and buffers and interpolation via the following:

```bash
# for newlines
list=('a b' $'c\nd' 'e f')
echo-lines "${list[@]}" | while read -r line; do
	echo "[$line]"
done
# output correct by arguments:
# [a b]
# [c]
# [d]
# [e f]

# for custom deliminator
list=('a b' $'c\nd' 'e f')
echo-split ' ' -- "${list[@]}" | while read -r line; do
	echo "[$line]"
done
# output correct by newline:
# [a]
# [b]
# [c]
# [d]
# [e]
# [f]
```

Which are superior to the `done < <(...)` and `done <<< "$...` options, as it maintains syntax highlighting and less interpolation.

You can even have the following benefits with `mapfile` too:

```bash
# same context throughout:
a=()
mapfile -t a < <(echo-split $'\n' -- $'a\nb' $'c\nd')
echo-verbose "${a[@]}"
# output correct:
# [0] = [a]
# [1] = [b]
# [2] = [c]
# [3] = [d]

# if you want a inherited variable context:
a=()
{
	mapfile -t a
	echo-verbose "${a[@]}"
} < <(echo-split $'\n' -- $'a\nb' $'c\nd')
echo-verbose "${a[@]}"
# output correct:
# [0] = [a]
# [1] = [b]
# [2] = [c]
# [3] = [d]
# [0] = [a]
# [1] = [b]
# [2] = [c]
# [3] = [d]

# this creates a pipe subshell, regardless of { } over ( ) usage:
a=()
echo-split $'\n' -- $'a\nb' $'c\nd' | {
	mapfile -t a
	echo-verbose "${a[@]}"
}
echo-verbose "${a[@]}"
# output correct:
# [0] = [a]
# [1] = [b]
# [2] = [c]
# [3] = [d]
# [ nothing provided ]
# ^ this is because the pipe does not transfer the variable
```

See the comparison between `github-release-file` and `get-volumes`.

# ecosystem tips and tricks

## run a command on each line

> - [stack exchange](https://stackoverflow.com/a/68310927/130638)

```bash
ls -1 | xargs -I %s -- echo %s
```
