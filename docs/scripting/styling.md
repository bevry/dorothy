# Styling your Command Output

Dorothy provides the following commands for styling your command's output:

## [echo-style](https://github.com/bevry/dorothy/blob/master/commands/echo-style)

Use `echo-style` to style your output, for complete details, refer to `echo-style --help`.

Generic styles:

```bash
echo-style \
	--error='This is an error message, use it for when things went poorly.' $'\n' \
	--success='This is a success message, use it for when things went well.' $'\n' \
	--warning='This is a warning message, use it when acceptable failures occurred.' $'\n' \
	--notice='This is a notice message, use it for say instructions.' $'\n' \
	--code='This is is a code message, use it for say variable values.' $'\n' \
	--blue+bold+bg-yellow='You can also combine styles, such as this.'
```

Header styles, for outputting content in clearly defined blocks:

```bash
echo-style --h1='Birth of the human spirit' --newline \
    --success='Woohoo, the human spirit was born!' ' ' --notice='Although... it was at the cost of the eviction, or rather the liberation, from eden.' --newline \
    --g1='Birth of the human spirit' # close h1 with a success style

echo-style --h2='Meaning of life calculator' --newline \
    --error='Uh, oh, 42 was rejected by the people.' --newline \
    --e2='Meaning of life calculator' # close h1 with an error style
```

Element styles, for outputting say command output, or a file's contents.

```bash
file="$(fs-temp --file)"

# self closing element
echo-style --element/="$file" --status=2

# write the file data
cat <<-EOF > "$file"
Lorem ipsum.
EOF

# open the element
echo-style --element="$file"
# output its contents
echo-style --code="$(echo-trim-padding --stdin <"$file")"
# close the element
echo-style --/element="$file"

# note that this example is contrived,
# when outputting file content, use:
echo-file -- "$file"
```

## [echo-quote](https://github.com/bevry/dorothy/blob/master/commands/echo-quote)

Use `echo-quote` to wrap the arguments in the appropriate quotation.

```bash
arguments=(
	'This string has no quotes.'
	"This string has 'single quotes', but no double quotes."
	'This string has "double quotes", but no single quotes.'
	"This string has 'single quotes', and \"double quotes\"."
)
echo-quote -- "${arguments[@]}"
```

For complete details, refer to `echo-quote --help`.

## [eval-helper](https://github.com/bevry/dorothy/blob/master/commands/eval-helper)

Use `eval-helper` to execute the passed command.

If `--quiet` is provided, the command output will collapse if it is not needed.

If `--no-wrap` is provided, the command's output will not be wrapped by the command itself.

If `--confirm` is provided, the user will be prompted to confirm execution of the command.

If `--{pending,success,failure}=<message>` is provided, the various `pending`, `success`, and `failure` messages will show at their appropriate times.
