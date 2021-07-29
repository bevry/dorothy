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

associative/indexed/mapped arrays:

> https://www.shell-tips.com/bash/arrays/

# loops

https://www.cyberciti.biz/faq/bash-for-loop/
