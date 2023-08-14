# Mastering Arrays in Bash

Sources:

-   [Bash Manual](https://www.gnu.org/software/bash/manual/bash.html#Arrays)
-   [Tutorial](https://www.shell-tips.com/bash/arrays/)

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

## array lengths

```bash
source "$DOROTHY/sources/strict.bash"

# mapfile of an empty value will produce an array with 1 value which is empty
mapfile -t a < <(failure-because-this-method-does-not-exist | echo-or-fail)
# bash: failure-because-this-method-does-not-exist: command not found
# empty stdin
echo $? # 0
echo "${#a[@]}" # 1
echo "${a[@]}" # empty

# when using <() the correct length is returned
# however even with strict, there is no hard fail
mapfile -t a < <(stderr echo 'error' | echo-or-fail)
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

## strings to arrays

-   [Bash Manual: Word Splitting](https://www.gnu.org/software/bash/manual/bash.html#Word-Splitting)
-   [Stack Exchange: In bash, what is the difference between IFS= and IFS=$'\n'](https://unix.stackexchange.com/a/676876/50703)
-   [`readarray`](https://www.gnu.org/software/bash/manual/bash.html#index-readarray) is an alias for [`mapfile`](https://www.gnu.org/software/bash/manual/bash.html#index-mapfile)

### newline deliminator

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

### custom deliminator

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

### recommendations

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
mapfile -t a < <(echo-lines -- 'a b' 'c d'); echo-verbose "${a[@]}"
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
