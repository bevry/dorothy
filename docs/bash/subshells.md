# Pipes, Subshells, and Failed Variable Assignments

Pipes will create accidental subshells, which will fail to apply changes to the parent scope.

Sources:

- [Explanation](https://mywiki.wooledge.org/BashFAQ/024)

Advice:

```bash
# never apply variables within pipes
printf '%s\n' foo bar | __split lines --no-zero-length
printf 'total number of lines: %s\n' "${#lines[@]}"
# outputs 0

# always use <, <<<, or <( instead
__split lines --no-zero-length < <(printf '%s\n' foo bar)
printf 'total number of lines: %s\n' "${#lines[@]}"
# outputs 2
```
