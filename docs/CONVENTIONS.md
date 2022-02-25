# Conventions

This document is for all the conventions that will benefit your contributions to your own dotfiles, as well as to the Dorothy core.

## Committing

Each pushed commit should be working, and only change what it needs to. Your commits can contain junk code (aka placeholders) locally, however such junk should be removed/resolved before being squashed, and then pushed. This ensures the commit history remains accurate, providing diffs only on productive changes.

## Formatting

All code should be formatted properly before it is pushed, which requires the implementation of automatic formatting.

You should run `setup-util-formatting` to the install dependencies for automatic formatting, then install the required plugins for your favorite editor.

## Editors

Visual Studio Code is recommended, as Visual Studio Code when working with Dorothy will automatically configure itself to Dorothy's recommendations.

### Plugins

Visual Studio Code:

- [shell-format](https://marketplace.visualstudio.com/items?itemName=foxundermoon.shell-format)
- [shellcheck](https://marketplace.visualstudio.com/items?itemName=timonwong.shellcheck)
- [editorconfig](https://marketplace.visualstudio.com/items?itemName=editorconfig.editorconfig)
- [prettier-vscode](https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode)

Others:

- [shfmt](https://github.com/mvdan/sh#shfmt)
- [shellcheck](https://github.com/koalaman/shellcheck)
- [prettier](https://prettier.io), [editor installation instructions](https://prettier.io/docs/en/editors.html)
- [editorconfig](https://editorconfig.org), [editor installation instructions](https://editorconfig.org/#download)

## Indentation

For leftmost indentation (i.e. initial code alignment) use tabs.

For rightmost indentation (i.e. whitespace significant alignment, e.g. `EOF` blocks), use spaces.

For example, in the below code example, tab indentation is used for code alignment, however 4 spaces are used to indent the description of options, this is because inside the `<<-EOF` block, the tabs will be stripped as insignificant and the spaces will be kept, allowing the correct formatting for the help text went outputted to the user.

```bash
# =====================================
# Arguments

# help
function help() {
	cat <<-EOF >/dev/stderr
		ABOUT:
		Prompt the user for an input value in a clean and robust way.

		USAGE:
		ask [...options]

		OPTIONS:
		--question=<string>
		    Specifies the question that the prompt will be answering.
	EOF
	if test "$#" -ne 0; then
		echo-style $'\n' --error="ERROR:" $'\n' --red="$(echo-lines -- "$@")" >/dev/stderr
	fi
	return 22 # Invalid argument
}
```
