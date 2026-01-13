# Mastering Parameter Expansion in Bash

## special variables

Past References:

- [Bash Manual](https://www.gnu.org/software/bash/manual/bash.html#Special-Parameters)
- [Stack Exchange: What are the special dollar sign shell variables?](https://stackoverflow.com/a/5163260/130638)
- `$@` vs `$*` - [SC2124](https://github.com/koalaman/shellcheck/wiki/SC2124)
- See our [`versions.md`](https://github.com/bevry/dorothy/blob/master/docs/bash/versions.md) for descriptions of how the special variables change over versions.

## safe variables

- `${var:-value}` and `${var:-"value"}`
    - if `var` is truthy, use `var`
    - if `var` is falsey, use `value`
- `${var-value}` and `${var-"value"}`
    - if `var` is bound, use `var`
    - if `var` is unbound, use `value`
- `[[ -n "${var-}" ]]` and `[[ -n "${var-}" ]]`
    - if `var` is truthy, pass
    - as both empty string values have 0 characters length
- `[[ -z "${var-}" ]]` and `[[ -z "${var-}" ]]`
    - if `var` is falsey, pass
    - as both empty string values have 0 characters length
- `test -v var`
    - if `var` is bound, pass
    - if `var` is unbound, fail
    - **only works on: bash >= 4.2 && zsh**
    - **use `bash.bash:(__is_var_declared|__is_var_defined)` instead**
- `${var:?is falsey}` and `${var:?"is falsey"}`
    - if `var` is truthy, use `var`
    - if `var` is falsey, send `is falsey` to STDERR, like so: `bash: var: is falsey`
- `${var?is unbound}` and `${var?"is unbound"}`
    - if `var` is bound, use `var`
    - if `var` is unbound, send `is unbound` to STDERR, like so: `bash: var: is unbound`
- `${var:=value}` and `${var:="value"}`
    - if `var` is truthy, use `var`
    - if `var` is falsey, set `var` to the `value`
- `${var=value}` and `${var="value"}`
    - if `var` is bound, use `var`
    - if `var` is unbound, set `var` to the `value`

Past References:

- https://wiki.bash-hackers.org/syntax/pe#use_a_default_value
- https://stackoverflow.com/a/14152610/130638
- https://stackoverflow.com/a/39621322
- http://www.gnu.org/software/bash/manual/bash.html#Shell-Parameter-Expansion

## string replacement

```bash
# get first line, via pipe, tried and tested
printf '%s\n' $'a\nb' | echo-first-line

# get first line, via variable
var=$'a\nb\nc'
printf '%s\n' "${var%%$'\n'*}" # a
__replace --source={var} --keep-before-first=$'\n' # a

# get everything before the first X
var='aXbXc'
printf '%s\n' "${var%%X*}" # a
__replace --source={var} --keep-before-first='X' # a

# get everything after the first X
var='aXbXc'
printf '%s\n' "${var#*X}" # bXc
__replace --source={var} --keep-after-first='X' # bXc

# get everything before the last X
var='aXbXc'
printf '%s\n' "${var%X*}" # aXb
__replace --source={var} --keep-before-last='X' # aXb

# get everything after the last X
var='aXbXc'
printf '%s\n' "${var##*X}" # c
__replace --source={var} --keep-after-last='X' # c


# replace first o with O
var='oXoXo'
printf '%s\n' "${var/o/O}"
__replace --source={var} --value='o' --replace='O'

# replace all o with O
var='oXoXo'
printf '%s\n' "${var//o/O}"
__replace --source={var} --value-all='o' --replace='O'
```

Past References:

- http://tldp.org/LDP/abs/html/string-manipulation.html

## get backslash escapes

```bash
var=$'$5 is five dollars\n'
printf '%q' "$var"
echo-escape-special -- "$var"
printf '%s' "$var" | echo-escape-special --stdin
```
