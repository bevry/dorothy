# ANSI Escape Codes

## Documentation on ANSI Escape Codes

-   <https://learn.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences>
-   <https://www.gnu.org/software/screen/manual/html_node/Control-Sequences.html>
-   <https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797> and <https://gist.github.com/ConnerWill/d4b6c776b509add763e17f9f113fd25b> they look the ame but have different commit histories
-   <https://en.wikipedia.org/wiki/ANSI_escape_code#CSI_(Control_Sequence_Introducer)_sequences>
-   <https://tldp.org/HOWTO/Bash-Prompt-HOWTO/bash-prompt-escape-sequences.html>
-   <https://en.wikipedia.org/wiki/ANSI_escape_code#Terminal_input_sequences> mentions screen/vt codes, which can be verified by entering `screen` then entering `read-key` then entering the key
-   <https://invisible-island.net/xterm/ctlseqs/ctlseqs.pdf>
-   <https://unix.stackexchange.com/a/668615/50703>

## Documentation on ANSI Escape Codes for colors

-   <https://en.wikipedia.org/wiki/ANSI_escape_code#Colors>
-   <https://en.wikipedia.org/wiki/ANSI_escape_code#SGR_(Select_Graphic_Rendition)_parameters>
-   <https://gist.github.com/Prakasaka/219fe5695beeb4d6311583e79933a009>
-   <https://mywiki.wooledge.org/BashFAQ/037>

## Documentation on ANSI Escape Codes for cursor and screen manipulation

```text
ESC [ = 0x9B = CSI (Control Sequence Introducer)
Starts most of the useful sequences, terminated by a byte in the range 0x40 through 0x7E.[5]: 5.4
```

```text
CSI n A = CUU (Cursor Up)
Moves the cursor n (default 1) cells in the given direction. If the cursor is already at the edge of the screen, this has no effect.
```

```text
CSI n J = ED (Erase in Display
Clears part of the screen. If n is 0 (or missing), clear from cursor to end of screen. If n is 1, clear from cursor to beginning of the screen. If n is 2, clear entire screen (and moves cursor to upper left on DOS ANSI.SYS). If n is 3, clear entire screen and delete all lines saved in the scrollback buffer (this feature was added for xterm and is supported by other terminal applications).
```

```text
CSI n K = EL (Erase in Line)
Erases part of the line. If n is 0 (or missing), clear from cursor to the end of the line. If n is 1, clear from cursor to beginning of the line. If n is 2, clear entire line. Cursor position does not change.
```

```text
CSI n F = CPL (Cursor Previous Line)
Moves cursor to beginning of the line n (default 1) lines up. (not ANSI.SYS)
```

```text
CSI n G = CHA (Cursor Horizontal Absolute)
Moves the cursor to column n (default 1). (not ANSI.SYS)
```

-   `\e[A` = move the cursor up 1 line
-   `\e[1K` = clear from cursor to beginning of the line
-   `\e[2K` = clear entire line
-   `\e[G` = moves the cursor to column 1
-   `\e[F` = Moves cursor to beginning of 1 lines up
-   `\e[J` = clear from cursor to end of screen
-   `$'\e[?47h'` = save screen but not cursor
-   `$'\e[?47l'` = restore screen but not cursor
-   `tput sc` = `$'\e7'` = save cursor, `$'\e[s'` is meant to work but from testing it doesn't
-   `tput rc` = `$'\e8'` = restore cursor, `$'\e[u'` is meant to work but from testing it doesn't
-   `tput smcup` = `$'\e[?1049h'` = save screen and cursor
-   `tput rmcup` = `$'\e[?1049l'` = restore screen and cursor
-   `tput clear` = `$'\e[H\e[2J'` = put cursor at top left and clear the screen
-   `tput cup 0 0` = `$'\e[1;1H'` = put cursor at top left, functionally same as `$'\e[H'`

## Documentations on keys

-   <https://en.wikipedia.org/wiki/Alt_key>
-   <https://en.wikipedia.org/wiki/Caps_Lock>
-   <https://en.wikipedia.org/wiki/Control_key>
-   <https://en.wikipedia.org/wiki/Command_key>
-   <https://en.wikipedia.org/wiki/Backspace>
-   <https://en.wikipedia.org/wiki/Delete_key>
-   <https://en.wikipedia.org/wiki/End_key>
-   <https://en.wikipedia.org/wiki/Enter_key>
-   <https://en.wikipedia.org/wiki/Esc_key>
-   <https://en.wikipedia.org/wiki/Home_key>
-   <https://en.wikipedia.org/wiki/Insert_key>
-   <https://en.wikipedia.org/wiki/List_of_Unicode_characters>
-   <https://en.wikipedia.org/wiki/Option_key>
-   <https://en.wikipedia.org/wiki/Page_Up_and_Page_Down_keys>
-   <https://en.wikipedia.org/wiki/Shift_key>
-   <https://en.wikipedia.org/wiki/Super_key_(keyboard_button)>
-   <https://en.wikipedia.org/wiki/Tab_key>
-   <https://stackoverflow.com/a/29243081/130638>
-   <https://www.acrobatfaq.com/atbref95/index/Keyboard_Shortcuts/Unicode_Codes_for_Keyboard_symbols.html>

## Documentation on Unicode characters and symbols

-   <https://en.wikipedia.org/wiki/List_of_Unicode_characters>
-   <https://en.wikipedia.org/wiki/List_of_Unicode_characters#Unicode_symbols>

## Symbols and labels for keys

-   `⌅`, `⌤` = enter key: `return enter` old MacOS keyboards, `return` new MacOS keyboards, `Enter ↵` Raspberry keyboards
-   `↵` = return key, alias for enter
-   `↑` = up arrow key
-   `↓` = down arrow key
-   `→` = right arrow key
-   `⎋` = escape key: `esc` MacOS keyboards, `Esc` Raspberry keyboard
-   `⌦` = delete key, aka delete forward key: `not present` MacOS keyboards, `Delete` Raspberry keyboard
-   `⌫` = backspace key, aka delete backward key: `Backspace ⬸` Raspberry keyboard
-   `←` = left arrow key
-   `⇧` = shift key
-   `⎇` = alt key: `not present` MacOS keyboards, `Alt` Raspberry keyboards
-   `⌥` = option key: `option alt` old MacOS keyboards, `option ⌥` new MacOS keyboards, `not present` Raspberry keyboard
-   `⌃`, `⎈` = control key: `control` old MacOS keyboards, `control ⌃` new MacOS keyboards, `Ctrl` Raspberry keyboards, `⎈` rarely used official symbol
-   `⌘` = command key: `command ⌘` MacOS keyboards, `Raspberry symbol` Raspberry keyboards
-   `❖` = super key, alias for command key
-   `🌐` = function key: `fn` old MacOS keyboards, `🌐 fn` new MacOS keyboards, `Fn` Raspberry keyboards
-   `⇪` = caps lock key: `caps lock` MacOS and Raspberry keyboards
-   `⇥` = tab key: `tab` on MacOS keyboard, `tab ⇤ ⇥` Raspberry keyboards
-   `⇤` = backtab key: `visible as the alt` Raspberry keyboards
-   `⇱` = home key: `Home` Raspberry keyboards
-   `⇲` = end key: `End` Raspberry keyboards
-   `⇞` = page up key: `PgUp` Raspberry keyboards
-   `⇟` = page down key: `PgDn` Raspberry keyboards
-   Insert key does not have an official symbol: Not present on MacOS keyboards, `Ins` Raspberry keyboards
