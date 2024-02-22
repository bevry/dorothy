# Replacing File Content

```bash
if rg --multiline --quiet "$pattern" "$file"; then
	# it was found, do the replacement
	sd --flags m \
		"$pattern" "$replace" \
		"$file"
else
	# it wasn't found, so add manually if it's not empty
	if test -n "$replace"; then
		echo "$replace" >>"$file"
	fi
fi
```

is the same as:

```bash
if ! rg --multiline --passthru --regexp="$pattern" --replace="$replace" "$file" | echo-wait "$file"; then
	# it wasn't found, so add manually if it's not empty
	if test -n "$replace"; then
		echo "$replace" >>"$file"
	fi
fi
```

However, due to https://github.com/BurntSushi/ripgrep/issues/2094 and other bugs, --passthru is unreliable.
