# Prompts

Dorothy provides tooling for advanced terminal interactions.

-   For managing alternative TTYs (which is necessary for when the content to be "erased" may span the terminal window's height):

    -   `sources/tty.bash` which is what `ask` and `choose` uses

-   For erasing only certain lines (which only works when the content to be "erased" is within the terminal widow's height):

    -   `echo-revolving-door` only shows the revolving last line, erasing prior lines as output is being generated
    -   `echo-clear-line`, `echo-clear-lines` erase prior lines
    -   `eval-collapse` (which is used by `setup-util`) uses `echo-revolving-door` for the executing command, and `echo-clear-lines` for cleaning up headers for producing summary outputs

-   For custom cursor magic:

    -   `confirm` uses the TTY ANSI codes directly to move the cursor to first line of the prompt, then to erase and clean up afterwards and during

-   For colors:

    -   `echo-style` does the magic

For learning how these actually work behind the scenes:

-   For the cursor movement: https://en.wikipedia.org/wiki/ANSI_escape_code#CSI_(Control_Sequence_Introducer)_sequences
-   For the alt TTY stuff in `tty.bash`: https://unix.stackexchange.com/a/668615/50703
-   For colors: https://en.wikipedia.org/wiki/ANSI_escape_code#SGR_(Select_Graphic_Rendition)_parameters
