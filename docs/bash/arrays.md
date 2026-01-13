# Mastering Arrays in Bash

> [!WARNING]
> This document is grossly out of date and incorrect or even invalid due to mass regexp replacements of old conventions with new conventions, which may function differently in these examples. Modern Dorothy conventions, which have yet to be documented, have done away with most of the tedium described here.
> Past history <https://github.com/bevry/dorothy/commits/master/docs/bash/arrays.md>

Sources:

- [Bash Manual](https://www.gnu.org/software/bash/manual/bash.html#Arrays)
- [Tutorial](https://www.shell-tips.com/bash/arrays/)

Advice:

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
    printf '%s\n' "[$r]"
done

# args length
printf '%s\n' "$#"

# array length
printf '%s\n' "${#a[@]}"
# ^ this is usually okay, but has a gotcha with `mapfile ... <<< ...` usage, see the later chapter about array lengths

# contains
if __has --source={a} --needle=' '; then
	printf '%s\n' 'with [ ]'
else
	printf '%s\n' 'without [ ]'
fi
if __has --source={a} --needle='c d'; then
	printf '%s\n' 'with [c d]'
else
	printf '%s\n' 'without [c d]'
fi

# subsets
echo-verbose "${a[@]:2:1}" # get one item, from the second index starting at 0
# [0] = [c d]

echo-verbose "${a[@]:2:3}" # get three items, from the second index starting at 0
# [0] = [c d]
# [1] = [e]
# [2] = [f]

echo-verbose "${a[@]:1}"  # get all items, from the first index starting at 0
# [0] = [b]
# [1] = [c d]
# [2] = [e]
# [3] = [f]
# [4] = [g]
# [5] = [h i]
# [6] = [j]

echo-verbose ${a[@]::2}  # get all items until the second index, starting at 0
# [0] = [a]
# [1] = [b]
```

## mapfile array length gotcha

```bash
source "$DOROTHY/sources/bash.bash"

# don't do this
__split --target={a} --no-zero-length -- "$(failure-because-this-method-does-not-exist | echo-or-fail --stdin)"
printf '%s\n' $? # 0 -- success exit code, despite failure
printf '%s\n' "${#a[@]}" # 1
echo-verbose "${a[@]}" # [0] = [] -- the <<< "$(...)" usage always provides a string to mapfile, so here the empty string becomes an array item

# do this instead
__split --target={a} --no-zero-length --stdin < <(failure-because-this-method-does-not-exist | echo-or-fail --stdin)
printf '%s\n' $? # 0 -- success exit code, despite failure
printf '%s\n' "${#a[@]}" # 0
echo-verbose "${a[@]}" # [ nothing provided ] -- the < <(...) usage successfully provides mapfile with zero input, creating an array with zero length

# you can use this to ensure that the array is not empty
if is-array-empty -- "${a[@]}"; then
	printf '%s\n' 'failure' >/dev/stderr
	exit 1
fi

# depending on your use case, you may also find these useful
is-array-partial -- "${a[@]}"
is-array-empty -- "${a[@]}"
is-array-empty-or-partial -- "${a[@]}"
is-array-full -- "${a[@]}"
is-array-full-or-partial -- "${a[@]}"
is-array-count -size=1 -- "${a[@]}"
is-array-count-ge --size=1 -- "${a[@]}"
```

## strings to arrays

- [Bash Manual: Word Splitting](https://www.gnu.org/software/bash/manual/bash.html#Word-Splitting)
- [Stack Exchange: In bash, what is the difference between IFS= and IFS=$'\n'](https://unix.stackexchange.com/a/676876/50703)
- [`readarray`](https://www.gnu.org/software/bash/manual/bash.html#index-readarray) is an alias for [`mapfile`](https://www.gnu.org/software/bash/manual/bash.html#index-mapfile)

### newline deliminator

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

### custom deliminator

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

### recommendations

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
