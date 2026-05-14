# Mastering Arrays in Bash

## forms

Arrays in Bash have two forms.

1. The arguments form: accessed via `$@`, length via `$#`, first element via `$1` or `${@:0:1}` (from index 0 with size of 1)
2. The array variable form: access via `${var[@]}`, length via `${#var[@]}`, first element via `${var[@]:0:1}` (from index 0 with size of 1)


## joining

To join array elements into a string, you can use `$*` in argument form, and `${arr[*]}` in array variable form, however expected output is dependent on `IFS` being unaltered.

``` bash
source "$DOROTHY/sources/bash.bash" # source Dorothy's `bash.bash` helper for `__dump`
set +e # enable interactive shell usage, disabling exit on error

var=(a 'b b' 'c c c')
__dump {var}
# var[0] = a
# var[1] = b b
# var[2] = c c c
echo-verbose -- "${var[*]}"
echo-verbose -- "${var[*]:1}"

# via command
# using a multi-character deliminator only uses the first character
IFS='//' echo-verbose -- "${var[*]}" # result is `a b b c c c`
IFS='//'; echo-verbose -- "${var[*]}"; unset IFS # result is `a/b b/c c c`
# using no deliminator
IFS='' echo-verbose -- "${var[*]}" # result is `a b b c c c`
IFS=''; echo-verbose -- "${var[*]}"; unset IFS # result is `ab bc c c`
IFS= echo-verbose -- "${var[*]}" # result is `a b b c c c`
IFS=; echo-verbose -- "${var[*]}"; unset IFS # result is `ab bc c c`

# via assignment
# using a multi-character deliminator only uses the first character
IFS='//' str="${var[*]}"; __dump {str} # result is `a/b b/c c c`
IFS='//'; str="${var[*]}"; unset IFS; __dump {str} # result is `a/b b/c c c`
# using no deliminator
IFS='' str="${var[*]}"; __dump {str}  # result is `ab bc c c`
IFS=''; str="${var[*]}"; unset IFS; __dump {str}  # result is `ab bc c c`
IFS= str="${var[*]}"; __dump {str}  # result is `ab bc c c`
IFS=; str="${var[*]}"; unset IFS; __dump {str} # result is `ab bc c c`
```

So when using `*`, then:
- You must be aware of the value of `IFS`, as it will affect the outputs.
- If invoking a command, you must use `IFS=<value>; ...` then reset IFS back to its original value.
- If assigning a variable, you can use `IFS= <assignment>` which applies it only for that assignment.

For readability, or for complex situations, utilise Dorothy's `bash.bash:__join` function (also exposed via `echo-join` command) instead:

``` bash
__join --source={var} --between='//' # outputs `a//b b//c c c`
__join --source={var} --first='{' --last='}' --before='[' --after=']' --between='//' # outputs `{[a]//[b b]//[c c c]}`
```


## lengths

You can get the length of the argument form via `$#`, and the variable form via `${#var[@]}`.

You cannot get the length of an element by `${#@:0:1}` or `${#var[@]:0:1}`. You must do `str="${@:0:1}"` or `str="${var[@]:0:1}"` then `${#str}"`.

## indexes

You can get the index of the variable form via `${!var[@]}`.

You cannot get the indexes of the arguments form, Doing `${!@}` will look for the variable from the interpolation of `$*`.

## partial

Array variables can be partial, in that they can have missing elements:

``` bash
partial=()
partial[0]=a
partial[2]='c c c'
__dump {partial}
# partial[0] = a
# partial[2] = c c c
```

## iterating

To iterate the argument form:

``` bash
function fn {
    local item
    for item in "$@"; do
        __dump {item}
    done
}
fn "${arr[@]}"
```

To iterate the argument form with removal:

``` bash
function fn {
    local item
    while [[ $# -ne 0 ]]; do
        item="$1"
        shift
        __dump {item}
    done
}
fn "${arr[@]}"
```

To iterate the variable form:

``` bash
for item in "${arr[@]}"; do
    __dump {item}
done
```

## double quotes

The double quotes are important, as otherwise our spaces in `b b` and `c c c` will become separate elements:

``` bash
for item in ${arr[@]}; do
    __dump {item}
done

function fn {
    local item
    while [[ $# -ne 0 ]]; do
        item="$1"
        shift
        __dump {item}
    done
}
fn ${arr[@]}
```

## modifying

Arrays can be modified like so:

``` bash
new=("${arr[@]}")
new=(before elements "${new[@]}" after elements)
new+=(appended elements)
```

## checking if an element exists

Checking only for `b b` and dumping it:

``` bash
for item in "${arr[@]}"; do
    if [[ $item == 'b b' ]]; then
        __dump {item}
        break
    fi
done
```

For readability, or for complex situations, you can utilise Dorothy's `bash.bash:__has` function (also exposed via `is-needle` command) instead:

``` bash
__has --source={arr} -- 'b b'
__has --source={arr} --first -- 'z' 'b b' # exit on the first found item
__has --source={arr} --all -- 'z' 'b b' # ensure each item is found at least once
__has --source={arr} --ignore-case -- 'B B' # ignore case when comparing

# `__has` supports a lot more capabilities than those, read the `bash.bash` source for details
```

## fetching indices

Fetching the index of `b b` and dumping it:

``` bash
for index in "${!arr[@]}"; do
    item="${arr[index]}"
    if [[ $item == 'b b' ]]; then
        __dump {index} {item}
        break
    fi
done
```

For readability, or for complex situations, you can utilise Dorothy's `bash.bash:__index` function:

``` bash
__index --source={arr} -- 'b b'
__index --source={arr} --first -- 'z' 'b b' # exit on the first found item
__index --source={arr} --all -- 'z' 'b b' # ensure each item is found at least once
__index --source={arr} --ignore-case -- 'B B' # ignore case when comparing

indices=()
__index --source={arr} --target={indices} --ignore-case --each --any --overlap -- 'b b' 'z' 'B B'
__dump {indices}

# `__index` supports a lot more capabilities than those, read the `bash.bash` source for details
```


## strings to arrays

> [!WARNING]
> This following section has gone through several mass regexp replacements of old conventions with new conventions, which may or may not have resulted in correct examples. Modern Dorothy conventions, which have yet to be documented, have done away with most of the tedium described here.
> Past history <https://github.com/bevry/dorothy/commits/master/docs/bash/arrays.md>
> Earlier version before new conventions <https://github.com/bevry/dorothy/commits/16e34fd1f8a44be0a2a188144e046a73ebf678dc/docs/bash/arrays.md>

> There is also some duplication with `trailing-lines.md`

### reading into arrays

```bash
source "$DOROTHY/sources/bash.bash"

# don't do this
__split --target={a} --no-zero-length -- "$(failure-because-this-method-does-not-exist | echo-or-fail --stdin)"
printf '%s\n' $? # 0 -- success exit code, despite failure
printf '%s\n' "${#a[@]}" # 1
echo-verbose -- "${a[@]}" # [0] = [] -- the <<< "$(...)" usage always provides a string to mapfile, so here the empty string becomes an array item

# do this instead
__split --target={a} --no-zero-length --stdin < <(failure-because-this-method-does-not-exist | echo-or-fail --stdin)
printf '%s\n' $? # 0 -- success exit code, despite failure
printf '%s\n' "${#a[@]}" # 0
echo-verbose -- "${a[@]}" # [ nothing provided ] -- the < <(...) usage successfully provides mapfile with zero input, creating an array with zero length
```

#### newline deliminator

```bash
str=$'a b\nc d'

# these `read -ra` all fail to output the second line [c d]
read -ra a <<< "$str"; echo-verbose -- "${a[@]}"
# outputs:
# [0] = [a]
# [1] = [b]
read -ra a -d $'\n' <<< "$str"; echo-verbose -- "${a[@]}"
# outputs:
# [0] = [a]
# [1] = [b]
IFS=$'\n' read -ra a <<< "$str"; echo-verbose -- "${a[@]}"
# outputs:
# [0] = [a b]

# these `mapfile -t` solutions are equivalent, and work
__split --target={a} --no-zero-length -- "$str"; echo-verbose -- "${a[@]}"
mapfile -td $'\n' a <<< "$str"; echo-verbose -- "${a[@]}"
# both output:
# [0] = [a b]
# [1] = [c d]
```

#### custom deliminator

```bash
str=$'a b\nc d'

# these `read -ra` solutions are equivalent, and have issues, both skipping the second line
read -ra a -d ' ' <<< "$str"; echo-verbose -- "${a[@]}"
# outputs:
# [0] = [a]
IFS=' ' read -ra a <<< "$str"; echo-verbose -- "${a[@]}"
# outputs:
# [0] = [a]
# [1] = [b]

# these `mapfile -t` solutions are equivalent, and have issues
mapfile -td ' ' a <<< "$str"; echo-verbose -- "${a[@]}"
# outputs mangled newlines:
# [0] = [a]
# [1] = [b
# c]
# [2] = [d
# ]
mapfile -td ' ' a <<< 'a b'; echo-verbose -- "${a[@]}"
# outputs mangled trailing item:
# [0] = [a]
# [1] = [b
# ]
mapfile -td ' ' a <<< 'a b '; echo-verbose -- "${a[@]}"
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
__split --target={a} --no-zero-length -- "$fodder"; echo-verbose -- "${a[@]}"
# output correct:
# [0] = [a]
# [1] = [b]
# [2] = [c]
# [3] = [d]

# or even multiple arguments
fodder="$(echo-split ' ' -- "$str" "$str")"
__split --target={a} --no-zero-length -- "$fodder"; echo-verbose -- "${a[@]}"
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
IFS=' ' read -ra a <<< 'a b'; echo-verbose -- "${a[@]}"
# output correct:
# [0] = [a]
# [1] = [b]

# for a newline deliminator that is not recursive between elements
__split --target={a} --no-zero-length -- "$str"; echo-verbose -- "${a[@]}"
# output correct:
# [0] = [a b]
# [1] = [c d]
__split --target={a} --no-zero-length --stdin < <(echo-lines -- 'a b' 'c d'); echo-verbose -- "${a[@]}"
# output correct:
# [0] = [a b]
# [1] = [c d]

# be careful of arguments being jumbled into a single line when parsing to mapfile
list=('a b' 'c d')
__split --target={a} --no-zero-length -- "${list[@]}"; echo-verbose -- "${a[@]}"
# output incorrect:
# [0] = [a b c d]
__split --target={a} --no-zero-length -- "${list[*]}"; echo-verbose -- "${a[@]}"
# output incorrect:
# [0] = [a b c d]

# such jumbled compression is not a problem with echo-split
list=('a b' 'c d')
fodder="$(echo-split '' -- "${list[@]}")"
__split --target={a} --no-zero-length -- "$fodder"; echo-verbose -- "${a[@]}"
# output correct:
# [0] = [a b]
# [1] = [c d]

# you can even use echo-split to split on recursive newlines
list=($'a\nb' $'c\nd')
fodder="$(echo-split $'\n' -- "${list[@]}")"
__split --target={a} --no-zero-length -- "$fodder"; echo-verbose -- "${a[@]}"
# output correct:
# [0] = [a]
# [1] = [b]
# [2] = [c]
# [3] = [d]

# which the typical mapfile won't do
list=($'a\nb' $'c\nd')
__split --target={a} --no-zero-length -- "${list[@]}"; echo-verbose -- "${a[@]}"
# output incorrect:
# [0] = [a]
# [1] = [b c]
# [2] = [d]

# as such these will always work as expected
echo-lines -- ...  # for recursive and non-recursive newlines
echo-split ''    -- ...  # equivalent for recursive and non-recursive newlines
echo-split $'\n' -- ...  # equivalent for recursive and non-recursive newlines
echo-split ' '   -- ...  # for custom deliminator
```

If you don't meed the result as an array via `mapfile -t lines` which you would likely then use `for line in "${lines[@]}"; do` iterate though, then you can skip a lot of assignment and buffers and interpolation via the following:

```bash
# for newlines
list=('a b' $'c\nd' 'e f')
echo-lines -- "${list[@]}" | while read -r line; do
	printf '%s\n' "[$line]"
done
# output correct by arguments:
# [a b]
# [c]
# [d]
# [e f]

# for custom deliminator
list=('a b' $'c\nd' 'e f')
echo-split ' ' -- "${list[@]}" | while read -r line; do
	printf '%s\n' "[$line]"
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
__split --target={a} --no-zero-length --stdin < <(echo-split $'\n' -- $'a\nb' $'c\nd')
echo-verbose -- "${a[@]}"
# output correct:
# [0] = [a]
# [1] = [b]
# [2] = [c]
# [3] = [d]

# if you want a inherited variable context:
a=()
{
	mapfile -t a
	echo-verbose -- "${a[@]}"
} < <(echo-split $'\n' -- $'a\nb' $'c\nd')
echo-verbose -- "${a[@]}"
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
	echo-verbose -- "${a[@]}"
}
echo-verbose -- "${a[@]}"
# output correct:
# [0] = [a]
# [1] = [b]
# [2] = [c]
# [3] = [d]
# [ nothing provided ]
# ^ this is because the pipe does not transfer the variable
```

See the comparison between `github-release-file` and `get-volumes`.


## other reading

- [`readarray`](https://www.gnu.org/software/bash/manual/bash.html#index-readarray) is an alias for [`mapfile`](https://www.gnu.org/software/bash/manual/bash.html#index-mapfile)
- [Bash Manual: arrays](https://www.gnu.org/software/bash/manual/bash.html#Arrays)
- [Bash Manual: Word Splitting](https://www.gnu.org/software/bash/manual/bash.html#Word-Splitting)
- [Stack Exchange: In bash, what is the difference between IFS= and IFS=$'\n'](https://unix.stackexchange.com/a/676876/50703)
- [Arrays Tutorial](https://www.shell-tips.com/bash/arrays/)
