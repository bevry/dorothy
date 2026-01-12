# Prompts

Dorothy provides tooling for advanced terminal interactions.

- For reading input:
    - `read-key` read keys from the keyboard
    - `choose` a selection prompt
    - `confirm` a yes/no or proceed prompt
    - `ask` a text prompt

- For managing the terminal cursor, screen, and lines:
    - `get-terminal-*` commands
    - the ANSI Escape Codes section of `styles.bash` used by `echo-style`

- For erasing only certain lines (which only works when the content to be "erased" is within the terminal window's height):
    - `echo-clear-lines` erase prior lines
    - `echo-revolving-door` only shows the revolving last line, erasing prior lines as output is being generated
    - `eval-helper` (which is used by `setup-util`) uses `echo-revolving-door` for the executing command, and `echo-clear-lines` for cleaning up headers for producing summary outputs
    - the ANSI Escape Codes section of `styles.bash` used by `echo-style`

- For styling, colors, etc:
    - `sources/styles.bash` which provides `__print_style` (automagically loaded by `bash.bash`), and exposed to other commands via `echo-style`. Refer to `echo-style --help` for assistance.

- For debugging:
    - `waiter` for specifying `stdout`, `stderr`, and `tty` output after a delay, etc.

For learning how these actually work, see the `ansi-escape-codes.md` document.
