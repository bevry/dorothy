# Scripts

## tutorials

- [Shell Scripts Matter](https://dev.to/thiht/shell-scripts-matter)

## run a command on each line

```bash
ls -1 | xargs -I %s -- echo %s
```

https://stackoverflow.com/a/68310927/130638

## function arguments

- http://stackoverflow.com/a/6212408/130638

## dev/null

- http://unix.stackexchange.com/q/70963/50703
- http://fishshell.com/docs/current/tutorial.html#tut_pipes_and_redirections

## $@ vs $\*

- https://github.com/koalaman/shellcheck/wiki/SC2124

## :- vs -

- https://wiki.bash-hackers.org/syntax/pe#use_a_default_value

## test, man test

- http://unix.stackexchange.com/a/306115/50703
- http://unix.stackexchange.com/a/246320/50703
- `-z` is empty string: True if the length of string is zero.
- `-n` is string: True if the length of string is nonzero.
- `-d` is dir: True if file exists and is a directory.
- `-f` is file: True if file exists and is a regular file.
- `-s` is nonempty file: True if file exists and has a size greater than zero.
- `=` is equal: True if the strings s1 and s2 are identical.

## ignoring exit code

```bash
# using our `ok` command
ok the-error-command arg1 arg2
ok exit 1

# using `|| :` bash builtin, note that this makes exit code always 0
the-error-command arg1 arg2 || :
echo $?  # 0

# using `|| true` for cross-shell, note that this makes exit code always 0
the-error-command arg1 arg2 || true
echo $?  # 0
```

## safe variables

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

## string replacement

> - http://tldp.org/LDP/abs/html/string-manipulation.html

```bash
# get first line, via pipe
# sed 1q: quit after first line
# sed -n 1p: only print first line, but read everything
# awk 'FNR == 1': only print first line, but read everything
# head -n 1: fails if pipe closes prematurely
echo -e 'a\nb' | sed 1q

# get first line
echo "${var%$'\n'*}" # "one\ntwo" to "one"

# trim everything after the X
# aka, return everything before the X
var="helloXworld"
echo "${var%X*}" # "helloXworld" to "hello

# trim everything before the X
# aka, return everything after the X
var="helloXworld"
echo "${var#*X}" # "helloXworld" to "world

# replace first o with O
echo "${var/o/O}"

# replace all o with O
echo "${var//o/O}"
```

## cwd

```bash
# ensure cwd is the directory of the script, and not user's runtime location
cd "$(dirname "$0")"

# same as above, but supports when executable is symlinked
cd "$(dirname "$(rlink "$0")")"
```

## arrays

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

Result:

```
[a]
[b]
[c d]
[e]
[f]
[g]
[h i]
[j]
```

## A note on array lengths

```bash
source "$DOROTHY/sources/strict.bash"

# mapfile of an empty value will produce an array with 1 value which is empty
mapfile -t a <<<"$(failure-because-this-method-does-not-exist | fail-on-empty-stdin 'empty stdin')"
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

# associative/indexed/mapped arrays:

> https://www.shell-tips.com/bash/arrays/

# strings to arrays

`readarray` is an alias for `mapfile`

For newlines:

```bash
# these `read -ra` solutions are equivalent, and have issues
read -ra a <<< $'a\nb'; echo-verbose "${a[@]}"
# fails to output b
IFS=$'\n' read -ra a <<< $'a\nb'; echo-verbose "${a[@]}"
# fails to output b
read -ra a -d $'\n' <<< $'a\nb'; echo-verbose "${a[@]}"
# fails to output b

# these `mapfile -t` solutions are equivalent, and work
mapfile -t a <<< $'a\nb'; echo-verbose "${a[@]}"
mapfile -td $'\n' a <<< $'a\nb'; echo-verbose "${a[@]}"
```

For a custom deliminator:

```bash
str=$'a b\nc d'

# these `read -ra` solutions are equivalent, and have issues
read -ra a -d ' ' <<< "$str"; echo-verbose "${a[@]}"
# outputs only [a]
IFS=' ' read -ra a <<< "$str"; echo-verbose "${a[@]}"
# outputs only [a] and [b], skips the second line

# these `mapfile -t` solutions are equivalent, and have issues
mapfile -td ' ' a <<< "$str"; echo-verbose "${a[@]}"
# outputs [a] [b\nc] [d\n] which mangles newlines
mapfile -td ' ' a <<< 'a b'; echo-verbose "${a[@]}"
# outputs [a] [b\n] which mangles trailing item
mapfile -td ' ' a <<< 'a b '; echo-verbose "${a[@]}"
# outputs [a] [b] [\n] which adds a problem item
```

The peculiarities for `read -ra` are because `read` goes one line at a time, as it is intended for while loops over draining file descriptors, such as pipes.

The peculiarities for `mapfile -td` are just weird.

As such, our recommendations are:

```bash
str=$'a b\nc d'

# for a custom deliminator for input that may span multiple lines
fodder="$(echo-split ' ' -- "$str")"
mapfile -t a <<< "$fodder"; echo-verbose "${a[@]}"
# outputs [a] [b] [c] [d]

# or even multiple arguments
fodder="$(echo-split ' ' -- "$str" "$str")"
mapfile -t a <<< "$fodder"; echo-verbose "${a[@]}"
# outputs [a] [b] [c] [d] [a] [b] [c] [d]

# for a custom deliminator for input that is guaranteed to only span a single line
IFS=' ' read -ra a <<< 'a b'; echo-verbose "${a[@]}"
# outputs [a] [b]

# for a newline deliminator that is not recursive between elements
mapfile -t a <<< "$str"; echo-verbose "${a[@]}"
# outputs [a b] [c d]
mapfile -t a < <(echo-lines 'a b' 'c d'); echo-verbose "${a[@]}"
# outputs [a b] [c d]

# be careful of arguments being compressed to a single line when parsing to mapfile
list=('a b' 'c d')
mapfile -t a <<< "${list[@]}"; echo-verbose "${a[@]}"
# outputs [a b c d]
mapfile -t a <<< "${list[*]}"; echo-verbose "${a[@]}"
# outputs [a b c d]

# such compression is not a problem with echo-split
list=('a b' 'c d')
fodder="$(echo-split '' -- "${list[@]}")"
mapfile -t a <<< "$fodder"; echo-verbose "${a[@]}"
# outputs [a b] [c d]

# you can even use echo-split to split on recursive newlines
list=($'a\nb' $'c\nd')
fodder="$(echo-split $'\n' -- "${list[@]}")"
mapfile -t a <<< "$fodder"; echo-verbose "${a[@]}"
# outputs [a] [b] [c] [d]

# which the typical mapfile won't do
list=($'a\nb' $'c\nd')
mapfile -t a <<< "${list[@]}"; echo-verbose "${a[@]}"
# outputs [a] [b c] [d]

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
# outputs [a b] [c] [d] [e f]

# for custom deliminator
list=('a b' $'c\nd' 'e f')
echo-split ' ' -- "${list[@]}" | while read -r line; do
	echo "[$line]"
done
# outputs [a] [b] [c] [d] [e] [f]
```

Which are superior to the `done < <(...)` and `done <<< "$...` options, as it maintains syntax highlighting and less interpolation.

You can even have the following benefits with `mapfile too:

```bash
echo-split $'\n' -- $'a\nb' $'c\nd' | {
	mapfile -t a
	# ...
}
```

See the comparison between `github-release-file` and `get-volumes`.

# piping mapfile assignment

> https://mywiki.wooledge.org/BashFAQ/024

# loops

https://www.cyberciti.biz/faq/bash-for-loop/

# builtins

```bash
bash -c help
```
