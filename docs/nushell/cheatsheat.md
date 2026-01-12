# Nushell Cheatsheet

- `$0` => `$env.FILE_PWD`, `$env.CURRENT_FILE` (however login shell does not have these defined)

- `let-env FOO = ...` is deprecated, use `$env.FOO = ...` instead.
  https://www.nushell.sh/commands/docs/let-env.html#frontmatter-title-for-deprecated

- `function foo { ... }` => `def greet [name] { ['hello' $name] }`
  https://www.nushell.sh/book/custom_commands.html

- `if ! something; then ... fi` => `if not something { ... }`

- `if command; then ... fi` => `command | complete; if $env.LAST_EXIT_CODE == 0 { ... }` - don't use `(command | complete).LAST_EXIT_CODE` as that isn't supported across nu versions
