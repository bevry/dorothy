# Scripts

## Help

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
ok the-error-command arg1 arg2
ok exit 1
```

`ok` is one of our commands


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
# get first line
echo "${var%$'\n'*}"

# trim everything after the space
echo "${var% *}" # "hello world" to "hello

# trim evrything before the space
echo "${var#* }" # "hello world" to "world

# trim everything before "v"
echo "${var#*v}" # "Consul v1.0.6" to "1.0.6"
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
