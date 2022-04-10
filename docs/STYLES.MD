# Styling

Dorothy provides the following commands for styling your command's output:

## [echo-style](https://github.com/bevry/dorothy/blob/master/commands/echo-style)

Use `echo-style` to style the lines of your output.

```bash
echo-style \
	--error='This is an error message, use it for when things went poorly.' $'\n' \
	--success='This is a success message, use it for when things went well.' $'\n' \
	--notice='This is a notice/warning message, use it for say instructions.' $'\n' \
	--code='This is is a code message, use it for say variable values.' $'\n' \
	--blue+bold+bg-yellow='You can also combine styles, such as this.'
```

For complete details, refer to `echo-style --help`.

## [echo-segment](https://github.com/bevry/dorothy/blob/master/commands/echo-segment)

Use `echo-segment` to segment your output, such that sections of output are clearly visible, with their result clearly identified.

```bash
echo-segment --h1='Birth of the human spirit'
echo-style --success='Woohoo, the human spirit was born!' ' ' --notice='Although... it was at the cost of the eviction, or rather the liberation, from eden.'
echo-segment --g1='Birth of the human spirit'
echo-segment --h1='Meaning of life calculator'
echo-style --error='Uh, oh, 42 was rejected by the people.'
echo-segment --e1='Meaning of life calculator'
```

For complete details, refer to `echo-segment --help`.

## [echo-element](https://github.com/bevry/dorothy/blob/master/commands/echo-element)

Use `echo-element` as an alternative to `echo-segment`, when you wish to output a segment for say a command output, or a file's contents.

```bash
file="$(fs-temp --file)"

# self closing element
echo-element --openclose="$file" --status=2

# write the file data
cat <<-EOF > "$file"
Lorem ipsum.
EOF

# open the element
echo-element --open="$file"
# output its contents
echo-style --code="$(echo-trim <"$file")"
# close the element
echo-element --close="$file"

# note that this example is contrived,
# when outputting file content, use:
echo-file "$file"
```

For complete details, refer to `echo-element --help`.

## [echo-quote](https://github.com/bevry/dorothy/blob/master/commands/echo-quote)

Use `echo-quote` to wrap the arguments in the appropriate quotation.

```bash
arguments=(
	'This string has no quotes.'
	"This string has 'single quotes', but no double quotes."
	'This string has "double quotes", but no single quotes.'
	"This string has 'single quotes', and \"double quotes\"."
)
echo-quote "${arguments[@]}"
```

For complete details, refer to `echo-quote --help`.

## [echo-eval](https://github.com/bevry/dorothy/blob/master/commands/echo-eval)

Use `echo-eval` to execute the passed command.

If `--confirm` is provided, the user will be prompted to confirm execution of the command beforehand.

If `--collapse` is provided, then the output of the command will be cleared after successful completion.

If `--no-wrap` is provided, the output will not be wrapped in the command itself and its exit code.

If `--no-color` is provided, the command will be executed with the best attempt at ensuring no colours are outputted by the command.

You can also use `--{pending,success,failure}=<message>` flags to output messages at different command states, which is especially useful when combined with `--collapse`.
