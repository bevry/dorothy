# Mastering Trailing Lines in Bash

```bash
# fails to output trailing line:
printf $'a\nb\nc' | while read -r line; do
	printf '%s\n' "[$line]"
done
# [a]
# [b]

# outputs correctly, including the trailing line:
printf $'a\nb\nc' | while read -r line || [[ -n "$line" ]]; do
	printf '%s\n' "[$line]"
done
# [a]
# [b]
# [c]

# note that
value=$'a\n'
echo-verbose -- "$(printf "$value")" # `$(...)` strips trailing lines
echo-verbose --stdin <<<"$value" # `<<<` injects a trailing line
echo-verbose --stdin < <(printf "$value") # `<(...)` maintains lines
printf "$value" | echo-verbose --stdin # | maintains lines
```

Past References:

- [Stack Exchange: Read a line-oriented file which may not end with a newline](https://unix.stackexchange.com/a/418067/50703)
