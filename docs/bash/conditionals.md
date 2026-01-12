# Mastering Conditions in Bash

Sources:

- [Bash Manual: Conditionals](https://www.gnu.org/software/bash/manual/bash.html#Conditional-Constructs)
- [Bash Manual: Grouping](https://www.gnu.org/software/bash/manual/bash.html#Command-Grouping)
- [Bash Manual: Test](https://www.gnu.org/software/bash/manual/bash.html#index-test)
- [Stack Exchange: What is the difference between the Bash operators `[[` vs `[` vs `(` vs `((`](http://unix.stackexchange.com/a/306115/50703)
- `help test` for [bash test builtin](https://github.com/bevry/dorothy/discussions/126), as `man test` is generic POSIX

Advice:

- `-z` is empty string: True if the length of string is zero.
- `-n` is string: True if the length of string is nonzero.
- `-e` is file or directory.
- `-d` is dir: True if file exists and is a directory.
- `-f` is file: True if file exists and is a regular file.
- `-s` is nonempty file: True if file exists and has a size greater than zero.
- `=` is equal: True if the strings s1 and s2 are identical.

## `[[` and `]]`

- [Stack Exchange: Why does this bash conditional check work with `[[ -n .. ]]` but not `[ -n .. ]`?](http://unix.stackexchange.com/a/246320/50703)

Only useful if doing `[[ blah = *blah* ]]` or the like.
