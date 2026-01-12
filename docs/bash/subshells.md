# Pipes, Subshells, and Failed Variable Assignments

Pipes will create accidental subshells, which will fail to apply changes to the parent scope.

Sources:

- [Explanation](https://mywiki.wooledge.org/BashFAQ/024)

Advice:

```bash
source "$DOROTHY/sources/bash.bash"

# never apply variables within pipes
printf '%s\n' foo bar | __split --target={lines} --no-zero-length --stdin
printf 'total number of lines: %s\n' "${#lines[@]}"
# outputs 0

# always have variable assignment, side effects, and mutations on the left-hand side
__split --target={lines} --no-zero-length -- 'foo' 'bar'
printf 'total number of lines: %s\n' "${#lines[@]}"
__split --target={lines} --no-zero-length -- $'foo\nbar'
printf 'total number of lines: %s\n' "${#lines[@]}"
__split --target={lines} --no-zero-length --invoke -- printf '%s\n' foo bar
printf 'total number of lines: %s\n' "${#lines[@]}"
__split --target={lines} --no-zero-length -- "$(printf '%s\n' foo bar)"  # avoid this, as if there is multiple command substitutions, only the latter one will have its exit status respected
printf 'total number of lines: %s\n' "${#lines[@]}"
__split --target={lines} --no-zero-length --stdin <<<"$(printf '%s\n' foo bar)"
printf 'total number of lines: %s\n' "${#lines[@]}"
__split --target={lines} --no-zero-length --stdin < <(printf '%s\n' foo bar) # avoid this, as it discards the exit status of the process substitution
printf 'total number of lines: %s\n' "${#lines[@]}"
# outputs 2
```
