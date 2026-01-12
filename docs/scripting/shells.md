# Comparison between Shells

## test

### get the path of a command

includes builtins, echo => echo

```plain
# bash, zsh
command -v CMD

# zsh
whence CMD

# fish
# no equivalent

# nu
which -a echo | first | get path
```

## get the path of an executable (excludes builtins, echo => /bin/echo)

```plain
# bash, fish
type -P CMD

# zsh
whence -p CMD

# nu
which -a echo | where type == 'external' | first | get path
```

### check if an executable exists

```plain
# bash, fish
type -P CMD &>/dev/null

# fish
type -qf CMD

# zsh
whence -p CMD &>/dev/null
```

## pipe redirections

- <https://unix.stackexchange.com/q/70963/50703>
- <https://www.gnu.org/software/bash/manual/bash.html#Redirections>
- <https://fishshell.com/docs/current/tutorial.html#pipes-and-redirections>

### silencing stdout

```plain
# sh, bash, zsh, fish
CMD > /dev/null

# nu
CMD out> /dev/null
CMD | ignore
```

### silencing stderr

```plain
# sh, bash, zsh
CMD 2>/dev/null

# fish
CMD ^ /dev/null

# nu
CMD err> /dev/null
```

### silencing output

```plain
# sh, bash, zsh, fish
CMD >/dev/null 2>&1

# bash, zsh, fish
CMD &> /dev/null

# fish
CMD > /dev/null ^ /dev/null

# nu
CMD out+err> /dev/null
```
