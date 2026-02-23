# Mastering Conditions in Bash

- `-z` is empty string / zero-length string
- `-n` is non-zero-length string
- `-e` is file or directory or symlink to present file or directory?
- `-d` is directory or symlink to directory
- `-f` is file or symlink to file
- `-L` is symlink, even to missing target
- `-s` is nonempty file
- `-N` has changes since last access
- `=` (sh) and `==` (bash) are both identical values check, use `==` in bash
- `=~ pattern` is pattern match
- `== *string*` is glob match
- `[` is the external POSIX `test` which is a process call which is slow
- `[[` is bash's builtin `test` and is fast, use `[[` in bash

## other reading

- [Bash Manual: Conditionals](https://www.gnu.org/software/bash/manual/bash.html#Conditional-Constructs)
- [Bash Manual: Grouping](https://www.gnu.org/software/bash/manual/bash.html#Command-Grouping)
- [Bash Manual: Test](https://www.gnu.org/software/bash/manual/bash.html#index-test)
- [Stack Exchange: What is the difference between the Bash operators `[[` vs `[` vs `(` vs `((`](http://unix.stackexchange.com/a/306115/50703)
- `help test` for [bash test builtin](https://github.com/bevry/dorothy/discussions/126), as `man test` is generic POSIX
- [Stack Exchange: Why does this bash conditional check work with `[[ -n .. ]]` but not `[ -n .. ]`?](http://unix.stackexchange.com/a/246320/50703)
