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

There are two variants of the ${var-value} notation, one without a colon, as shown, and one with a colon: ${var:-value}.

The first version, without colon, means 'if \$var is set to any value (including an empty string), use it; otherwise, use value instead'.

The second version, with colon, means 'if \$var is set to any value except the empty string, use it; otherwise, use value instead'.

This pattern holds for other variable substitutions too, notably:

-   ${var:=value}`
    if $var is set to any non-empty string, leave it unchanged; otherwise, set \$var to value.

-   `${var=value}`
    if $var is set to any value (including an empty string), leave it unchanged; otherwise, set $var to value.

-   `${var:?message}`
    if \$var is set to any non-empty string, do nothing; otherwise, complain using the given message' (where a default message is supplied if message is itself empty).

-   `${var?message}`
    if \$var is set to any value (including an empty string), do nothing; otherwise, complain using the given message'.

These notations all apply to any POSIX-compatible shell (Bourne, Korn, Bash, and others). You can find the manual for the bash version online — in the section Shell Parameter Expansion. Bash also has a number of non-standard notations, many of which are extremely useful but not necessarily shared with other shells.

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
echo "${var%:*}" # "hello:world" to "hello

# trim evrything before the colon
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
