# Mastering Parameter Expansion in Bash

## special variables

Sources:

- [Bash Manual](https://www.gnu.org/software/bash/manual/bash.html#Special-Parameters)
- [Stack Exchange: What are the special dollar sign shell variables?](https://stackoverflow.com/a/5163260/130638)
- `$@` vs `$*` - [SC2124](https://github.com/koalaman/shellcheck/wiki/SC2124)

## safe variables

Sources:

- https://wiki.bash-hackers.org/syntax/pe#use_a_default_value
- https://stackoverflow.com/a/14152610/130638
- https://stackoverflow.com/a/39621322
- http://www.gnu.org/software/bash/manual/bash.html#Shell-Parameter-Expansion

Advice:

- `${var:-value}`
    - if var is truthy, use `var`
    - if var is falsey, use `value`
- `${var-value}`
    - if var is bound, use `var`
    - if var is unbound, use `value`
- `[[ -n "${var-}" ]]` and `[[ -n "${var-}" ]]`
    - if var is truthy, pass
    - as both empty string values have 0 characters length
- `[[ -z "${var-}" ]]` and `[[ -z "${var-}" ]]`
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

Sources:

- http://tldp.org/LDP/abs/html/string-manipulation.html

Advice:

```bash
# get first line, via pipe, tried and tested
printf '%s\n' $'a\nb' | echo-first-line

# get first line, via variable
var=$'one\ntwo'; printf '%s\n' "${var%$'\n'*}" # one

# get everything before the first X
var="aXbXc"; printf '%s\n' "${var%%X*}" # a

# get everything after the first X
var="aXbXc"; printf '%s\n' "${var#*X}" # bXc

# get everything before the last X
var="aXbXc"; printf '%s\n' "${var%X*}" # aXb

# get everything after the last X
var="aXbXc"; printf '%s\n' "${var##*X}" # c


# replace first o with O
printf '%s\n' "${var/o/O}"

# replace all o with O
printf '%s\n' "${var//o/O}"
```

## get backslash escapes

Advice:

```bash
printf '%q' "$value"
```
