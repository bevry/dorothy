# Comparison between Shells

## pipe redirections

-   <https://unix.stackexchange.com/q/70963/50703>
-   <https://www.gnu.org/software/bash/manual/bash.html#Redirections>
-   <https://fishshell.com/docs/current/tutorial.html#pipes-and-redirections>

### silencing stdout

```plain
# sh, bash, zsh, fish
cmd > /dev/null

# nu
cmd out> /dev/null
cmd | ignore
```

### silencing stderr

```plain
# sh, bash, zsh
cmd 2>/dev/null

# fish
cmd ^ /dev/null

# nu
cmd err> /dev/null
```

### silencing output

```plain
# sh, bash, zsh, fish
cmd >/dev/null 2>&1

# bash, zsh, fish
cmd &> /dev/null

# fish
cmd > /dev/null ^ /dev/null

# nu
cmd out+err> /dev/null
```
