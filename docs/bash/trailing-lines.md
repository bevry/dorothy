# Mastering Trailing Lines in Bash

Sources:

- [Stack Exchange: Read a line-oriented file which may not end with a newline](https://unix.stackexchange.com/a/418067/50703)

Advice:

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

# note that <<< works as expected
while read -r line; do
	printf '%s\n' "[$line]"
done <<< $'a\nb\nc'
# [a]
# [b]
# [c]

# but < <( does not
while read -r line; do
	printf '%s\n' "[$line]"
done < <(printf $'a\nb\nc')
# [a]
# [b]
```
