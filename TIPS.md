# Scripts

## tutorials

-   [Shell Scripts Matter](https://dev.to/thiht/shell-scripts-matter)

## function arguments

-   http://stackoverflow.com/a/6212408/130638

## dev/null

-   http://unix.stackexchange.com/q/70963/50703
-   http://fishshell.com/docs/current/tutorial.html#tut_pipes_and_redirections

## $@ vs $\*

-   https://github.com/koalaman/shellcheck/wiki/SC2124

## :- vs -

-   https://wiki.bash-hackers.org/syntax/pe#use_a_default_value

## test, man test

-   http://unix.stackexchange.com/a/306115/50703
-   http://unix.stackexchange.com/a/246320/50703
-   `-z` is empty string: True if the length of string is zero.
-   `-n` is string: True if the length of string is nonzero.
-   `-d` is dir: True if file exists and is a directory.
-   `-f` is file: True if file exists and is a regular file.
-   `-s` is nonempty file: True if file exists and has a size greater than zero.
-   `=` is equal: True if the strings s1 and s2 are identical.

## ignoring exit code

```bash
# using our `ok` command
ok the-error-command arg1 arg2
ok exit 1

# using `|| :` bash builtin
the-error-command arg1 arg2 || :
```

## safe variables

https://stackoverflow.com/a/14152610/130638
https://stackoverflow.com/a/39621322
http://www.gnu.org/software/bash/manual/bash.html#Shell-Parameter-Expansion

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

## cwd

```bash
# ensure cwd is the directory of the script, and not user's runtime location
cd "$(dirname "$0")"

# same as above, but supports when executable is symlinked
cd "$(dirname "$(rlink "$0")")"
```

## string replacement

-   http://tldp.org/LDP/abs/html/string-manipulation.html

```bash
var="$(echo -e "hello world\\nhello world")"

# get first line
echo "${var%$'\n'*}"

# trim everything after the colon
# aka, get everything before the colon
echo "${var%:*}" # "hello:world" to "hello

# trim everything before the colon
# aka, get everything after the colon
echo "${var#*:}" # "hello:world" to "world

# trim everything before "v"
echo "${var#*v}" # "Consul v1.0.6" to "1.0.6"

# replace first o with O
echo "${var/o/O}"

# replace all o with O
echo "${var//o/O}"

```

## arrays

```bash
a=(
	a
	b
	"c d"
	e
	f
)
a+=(
	g
	"h i"
	j
)

for r in "${a[@]}"; do
    echo "[$r]"
done

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
