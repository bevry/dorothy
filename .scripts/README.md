# Scripts

## tutotials

- [Shell Scripts Matter](https://dev.to/thiht/shell-scripts-matter)


## opts

Run `help set` to get more details. Use `set -Eeuo pipefail` as safe mode.

``` text
-E  If set, the ERR trap is inherited by shell functions.
    https://stackoverflow.com/q/25378845/130638
-e  Exit immediately if a command exits with a non-zero status.
-u  Treat unset variables as an error when substituting.
-o  option-name
    Set the variable corresponding to option-name:
    errtrace    same as -E
    errexit     same as -e
    nounset     same as -u
    pipefail    the return value of a pipeline is the status of
                the last command to exit with a non-zero status,
                or zero if no command exited with a non-zero status
```


## function arguments

- http://stackoverflow.com/a/6212408/130638


## dev/null

- http://unix.stackexchange.com/q/70963/50703
- http://fishshell.com/docs/current/tutorial.html#tut_pipes_and_redirections


## $@ vs $*

- https://github.com/koalaman/shellcheck/wiki/SC2124


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

``` bash
# using our `ok` command
ok the-error-command arg1 arg2
ok exit 1

# using `|| :` bash builtin
the-error-command arg1 arg2 || :
```


## cwd

``` bash
# ensure cwd is the directory of the script, and not user's runtime location
cd "$(dirname "$0")"

# same as above, but supports when executable is symlinked
cd "$(dirname "$(rlink "$0")")"
```


## string replacement

- http://tldp.org/LDP/abs/html/string-manipulation.html

``` bash
var="$(echo -e "hello world\\nhello world")"

# get first line
echo "${var%$'\n'*}"

# trim everything after the space
echo "${var% *}" # "hello world" to "hello

# trim evrything before the space
echo "${var#* }" # "hello world" to "world

# trim everything before "v"
echo "${var#*v}" # "Consul v1.0.6" to "1.0.6"

# replace first o with O
echo "${var/o/O}"

# replace all o with O
echo "${var//o/O}"

```


## arrays

``` bash
a=(
    a
    b
    "c d"
    e
    f
)

for r in "${a[@]}"; do
    echo "[$r]"
done
```

```
[a]
[b]
[c d]
[e]
[f]
```
