#!/usr/bin/env bash

# -------------------------------------
# ANSI Toolkit

# Our own documentation: <ansi-escape-codes.md>
# Comprehensive concise summary: <https://learn.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences> <-- important to support everything in this
# GNU documentation: <https://www.gnu.org/software/screen/manual/html_node/Control-Sequences.html> <-- important to support everything in this
# Other partial summaries: <https://en.wikipedia.org/wiki/ANSI_escape_code> <-- probably a good idea to support everything in this
# Definitive compilation: <https://invisible-island.net/xterm/ctlseqs/ctlseqs.pdf> <-- impossible to support everything in this, as it is too exhaustive

# ASCII (American Standard Code for Information Interchange): 7-bit character encoding standard defining 128 characters (0-127), including printable characters and 32 control characters, e.g. newline `\n`, carriage return `\r`, escape (ESC) `\e`, end of transmission (EOT) `\4` (ASCII character 4)
# ANSI (American National Standards Institute) standards define escape sequences (using ASCII ESC as trigger) for terminal control, of which these are subsets:
# - ESC sequences (`\e` + single char) - simpler commands, e.g. `\e7` for save cursor position
# - CSI (Control Sequence Introducer) sequences (`\e[`…), e.g. colors `\e[31m` for red text, cursor movement `\e[A` for cursor up
# - OSC (Operating System Command): sequences (`\e]`…), e.g. operating system commands
# ANSI Escape Codes are the numeric values within these sequences, e.g. `31` in `\e[31m`

# Note that these are equivalent $'\004' (3-digit octal), $'\04' (2-digit octal), $'\4'  (1-digit octal), $'\x04' (2-digit hex), $'\x4' (1-digit hex)
# And these are equivalent in that they are both EOT then a 4: $'\0044' $'\x044' whereas 4 proceeding the other options is confused with another character; however that's pretty weird, just do $'\4''4' instead or something.

# Also note that despite what many specs say about CSI (Control Sequence Introducer) sequences, modern terminal emulators actually support `ESC [ <value> ; <modifier> <command>`, where the modifier codes are:
# 1 = no modifier
# 2 = Shift
# 3 = Alt
# 4 = Shift+Alt
# 5 = Ctrl
#
# This is why `\e[1;2D` is `⇧ ←` on macos. It is saying `\e[D` which is `←` (Left) plus modifier of `2` which is `⇧` (Shift); it is not saying Cursor Back.

# NOTE Bash does not support lazy/non-greedy regex matching, so you will see `[^\a]*` instead of `.*?`

# Workaround bugs in bash with $'\001'.
# Bash v3.2 turns arr=($'\001') (length 1) into arr=($'\001\001') (length 2):
# `arr=($'\001'); printf '%q' "${arr[0]}" "${#arr[0]}"` # outputs: $'\001\001'2
# Note that a string directly, it works fine:
# `str=$'\001'; printf '%q' "${str}" "${#str}"` # outputs: $'\001'1
# Fortunately, the combination works fine:
# str=$'\001'; arr=("$str"); printf '%q' "${arr[0]}" "${#arr[0]}" # outputs: $'\001'1
ANSI_ALL=$'\001'
# Bash below v4.2 crashes when $'\001' is used in a regular expression, as such pattern is optional than always required, resorting to globs on the keys instead always using patterns/escaped-keys.

# this is beta, expect it to change later
ANSI=(
	# <KEY/EXAMPLE-KEY> <PATTERN:optional> <NAME> <TAGS>

	# app-specific hotkeys that should be interpreted by the caller instead
	# up: [k] vim
	# down: [j] vim
	# right: [l] vim
	# left: [h] vim

	# @todo add a third column, that contains any combination of `press` (pressable via keyboard), `print` (printable to paper), `place` (shapeshifter of cursor)

	# The below are shortcut combinations read or written by Dorothy
	# $'\e\[G\e\[2K' 'clear-line'  'TODO'
	# $'\e\[F\e\[J' 'delete-line'  'TODO'
	# $'\n\e[H\e[J' $'\n\e\[H\e\[J' 'clear-screen'  'TODO'
	# $'\e[H\e[J' $'\e\[H\e\[J' 'clear-screen'  'TODO'
	# $'\e\[H\e\[J' 'clear-screen'  'TODO'
	# $'\e\[[?]1049h\e\[H\e\[J' 'alternative-screen-buffer'  'TODO'

	# The below are pressable keys read or written by Dorothy
	# <https://learn.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences#input-sequences>

	# space
	# [0x20 = $'\x20 = ' '] is [ ] ubuntu, macos
	' ' '' 'space' '[read-key][echo-revolving-door]'

	# tab
	# [0x09 = $'\x09' = $'\t'] is [⇥] ubuntu, macos, [^ I] macos
	# <https://ghostty.org/docs/vt/control/tab> Tab (TAB)
	$'\t' '' 'tab' '[read-key][echo-revolving-door]'

	# enter / line-feed
	# [0x0A = $'\x0a' =  $'\n'] is ubuntu, macos,  [^ J] [^ M] macos
	# <https://ghostty.org/docs/vt/control/lf> Linefeed (LF)
	$'\n' '' 'enter' '[read-key][echo-revolving-door]'

	# carriage-return
	# [$'\e[G'] is [cursor to start of current line] ansi escape code
	$'\e[G' '' 'carriage-return' '[read-key][not-text][shapeshifter]'
	# [0x0D = $'\x0d' = $'\r'] is ansi escape code
	# <https://ghostty.org/docs/vt/control/cr> Carriage Return (CR)
	$'\r' '' 'carriage-return' '[read-key][echo-revolving-door][not-text][shapeshifter]'

	# left
	# unverified: [$'\eOD'] v100, screen, xterm
	# [$'\e[D'] is [←] ubuntu, macos, [cursor left one] ansi escape code
	$'\e[D' '' 'left' '[read-key][not-text][shapeshifter]'

	# right
	# unverified: [$'\eOC'] v100, screen, xterm
	# [$'\e[C'] is [→] ubuntu, macos, [cursor right one] ansi escape code
	$'\e[C' '' 'right' '[read-key][not-text][shapeshifter]'

	# up
	# unverified: [$'\eOA'] v100, screen, xterm
	# [$'\e[A'] is [↑] ubuntu, macos, [cursor up one] ansi escape code
	$'\e[A' '' 'up' '[read-key][not-text][shapeshifter]'
	# [$'\eM'] ansi escape code to cursor up a line and scroll if necessary, note that scrolling moves visible content down but content from above is empty/erased; note that this is also documented as: Reverse Index (RI is 0x8d); note $'\x8d' becomes a ? in Apple Terminal
	# <https://ghostty.org/docs/vt/esc/ri> Reverse Index (RI)
	$'\eM' '' 'up' '[read-key][not-text][shapeshifter]'

	# down
	# unverified: [$'\eOB'] v100, screen, xterm
	# [$'\e[B'] is [↓] ubuntu, macos, [cursor down one] ansi escape code
	$'\e[B' '' 'down' '[read-key][not-text][shapeshifter]'

	# home
	# unverified: [$'\eOH'] xterm
	# [$'\e[1~'] is [🌐 ←] screen/vt macos
	$'\e[1~' '' 'home' '[read-key][not-text]'
	# [$'\e[H'] is [⇱] ubuntu, macos, [numlock 7] ubuntu, [🌐 ⇧ ←] macos, [cursor to top left] ansi escape code
	$'\e[H' '' 'home' '[read-key][not-text][shapeshifter]'
	# [$'\e[1;2D'] is [⇧ ←] macos, [cursor left twice: the `1;` prefix is not supported on macos] ansi escape code
	$'\e[1;2D' '' 'home' '[read-key][not-text][shapeshifter]'

	# end
	# unverified: [$'\eOF'] xterm
	# [$'\e[4~'] is [🌐 →] screen/vt macos
	$'\e[4~' '' 'end' '[read-key][not-text]'
	# [$'\e[F'] is [⇲] ubuntu, macos, [numlock 1] ubuntu, [🌐 ⇧ →] macos, [cursor to start of prior line] ansi escape code
	$'\e[F' '' 'end' '[read-key][not-text][shapeshifter]'
	# [$'\e[1;2C'] is [⇧ ←] macos, [cursor right twice: the `1;` prefix is not supported on macos] ansi escape code
	$'\e[1;2C' '' 'end' '[read-key][not-text][shapeshifter]'

	# page up
	# unverified: [$'\006'] [⌃ f] vim
	# [$'\e[5~'] is [⇞] [numlock 9] ubuntu, [🌐 ⇧ ↑] macos, [🌐 ↑] screen/vt macos
	$'\e[5~' '' 'page-up' '[read-key][not-text]'
	# [$'\E[1;5D'] is [⌃ ←] macos
	$'\e[1;5D' '' 'page-up' '[read-key][not-text][shapeshifter]'
	# [$'\eb'] is [⌥ ←] macos
	$'\eb' '' 'page-up' '[read-key][not-text]'

	# page down
	# unverified: [$'\002'] [⌃ b] vim
	# [$'\e[6~'] is [⇟] [numlock 3] ubuntu, [🌐 ⇧ ↓] macos, [🌐 ↑] screen/vt macos
	$'\e[6~' '' 'page-down' '[read-key][not-text]'
	# [$'\e[1;5C'] is [⌃ →] macos
	$'\e[1;5C' '' 'page-down' '[read-key][not-text][shapeshifter]'
	# [$'\ef'] is [⌥ →] macos
	$'\ef' '' 'page-down' '[read-key][not-text]'

	# all / select all
	# [$'\x01' = $'\001'] is [^ A] macos
	"$ANSI_ALL" '' 'all' '[read-key][not-text]'

	# insert
	# [$'\e[2~'] is [INSERT] [numlock 0] ubuntu
	$'\e[2~' '' 'insert' '[read-key][not-text]'

	# delete
	# [$'\e[3~'] is [⌦] [numlock .] ubuntu, [🌐 ⌫] macos
	$'\e[3~' '' 'delete' '[read-key][not-text]'

	# backspace
	# [$'\x7f' = $'\177'] is [⌫] ubuntu, macos
	$'\177' '' 'backspace' '[read-key][not-text]'
	# [0x08 = $'\x08' = $'\b'] is [^ H] macos
	# <https://ghostty.org/docs/vt/control/bs> Backspace (BS)
	$'\b' '' 'backspace' '[read-key][echo-revolving-door][not-text][shapeshifter]'

	# backtab
	# [$'\e[Z'] is [⇤] [shift ⇥] macos
	$'\e[Z' '' 'backtab' '[read-key][not-text][shapeshifter]'

	# form feed / new page
	# [0x0C = $'\x0c' = $'\f] is [⌃ L] macos; same as newline but maintains horizontal cursor position
	$'\f' '' 'form-feed' '[read-key][not-text][shapeshifter]'

	# all pressable keys on macos bellow:
	# N/A `^ Q` macos
	# $'\027' `^ W` macos
	# $'\005' `^ E` macos
	# N/A `^ R` macos
	# $'\024' `^ T` macos
	# N/A `^ Y` macos
	# $'\025' `^ U` macos
	# $'\t' `^ I` macos <-- tab
	# N/A `^ O` macos
	# $'\020' `^ P` macos
	# $'\001' `^ A` macos <-- all
	# N/A `^ S` macos
	# $'\004' `^ D` macos
	# $'\006' `^ F` macos
	# $'\a' `^ G` macos <-- bell
	# $'\b' `^ H` macos <-- backspace
	# $'\n' `^ J` macos <-- enter
	# $'\v' `^ K` macos <-- cursor-up
	# $'\f' `^ L` macos <-- form-feed
	# N/A `^ Z` macos
	# $'\030' `^ X` macos
	# N/A `^ C` macos
	# $'\026' `^ V` macos (requires double tap)
	# $'\002' `^ B` macos
	# $'\016' `^ N` macos
	# $'\n' `^ M` macos <-- enter
	# $'\e' `^ [` macos
	# $'\035' `^ ]` macos
	# $'\037' `^ -` macos
	# bash cannot match the null character, \000, as it is immediately discarded

	# Text Formatting
	# <https://learn.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences#text-formatting>
	# Select Graphic Rendition
	# ESC [ <n> m	SGR	Set Graphics Rendition	Set the format of the screen and text as specified by <n>
	$'\e[1mBOLD\e[m' $'\e\[[0-9;]*m' 'style' '[not-text]'

	# Cursor Positioning
	# Must be below the up/down/etc and page-up/down pressable keys, as these are patterns, rather than specific keys
	# <https://learn.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences#simple-cursor-positioning>
	# ESC M	RI	Reverse Index – Performs the reverse operation of \n, moves cursor up one line, maintains horizontal position, scrolls buffer if necessary*
	#   ^ handled earlier in pressable keys
	# Save Cursor and Attributes
	# ESC 7	DECSC	Save Cursor Position in Memory**
	# <https://ghostty.org/docs/vt/esc/decsc> Save Cursor (DECSC)
	$'\e7' '' 'save-cursor' '[not-text]'
	# Restore Cursor and Attributes
	# ESC 8	DECSR	Restore Cursor Position from Memory**
	# <https://ghostty.org/docs/vt/esc/decrc> Restore Cursor (DECRC)
	$'\e8' '' 'restore-cursor' '[not-text][shapeshifter]'
	# <https://learn.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences#cursor-positioning>
	# Cursor Up
	# ESC [ <n> A	CUU	Cursor Up	Cursor up by <n>
	# <https://ghostty.org/docs/vt/csi/cuu> Cursor Up (CUU)
	$'\e[5A' $'\e\[[0-9]*A' 'cursor-up' '[not-text][shapeshifter]'
	# Cursor Down
	# ESC [ <n> B	CUD	Cursor Down	Cursor down by <n>
	# <https://ghostty.org/docs/vt/csi/cud> Cursor Down (CUD)
	$'\e[5B' $'\e\[[0-9]*B' 'cursor-down' '[not-text][shapeshifter]'
	# Cursor Right / Cursor Forward
	# ESC [ <n> C	CUF	Cursor Forward	Cursor forward (Right) by <n>
	# <https://ghostty.org/docs/vt/csi/cuf> Cursor Forward (CUF)
	$'\e[5C' $'\e\[[0-9]*C' 'cursor-forward' '[not-text][shapeshifter]'
	# Cursor Left / Cursor Back / Cursor Backward
	# ESC [ <n> D	CUB	Cursor Backward	Cursor backward (Left) by <n>
	# <https://ghostty.org/docs/vt/csi/cub> Cursor Backward (CUB)
	$'\e[5D' $'\e\[[0-9]*D' 'cursor-back' '[not-text][shapeshifter]'
	# Cursor Next Line / Cursor Down Line / Cursor Below Line
	# ESC [ <n> E	CNL	Cursor Next Line	Cursor down <n> lines from current position
	# <https://ghostty.org/docs/vt/csi/cnl> Cursor Next Line (CNL)
	$'\e[5E' $'\e\[[0-9]*E' 'cursor-next-line' '[not-text][shapeshifter]'
	# Cursor Previous Line / Cursor Up Line / Cursor Prior Line
	# ESC [ <n> F	CPL	Cursor Previous Line	Cursor up <n> lines from current position
	# <https://ghostty.org/docs/vt/csi/cpl> Cursor Previous Line (CPL)
	$'\e[5F' $'\e\[[0-9]*F' 'cursor-previous-line' '[not-text][shapeshifter]'
	# Cursor Horizontal Position / Cursor Horizontal Absolute
	# ESC [ <n> G	CHA	Cursor Horizontal Absolute	Cursor moves to <n>th position horizontally in the current line
	$'\e[5G' $'\e\[[0-9]*G' 'cursor-horizontal-position' '[not-text][shapeshifter]'
	# Cursor Vertical Position / Cursor Vertical Absolute / Vertical Position Absolute
	# ESC [ <n> d	VPA	Vertical Line Position Absolute	Cursor moves to the <n>th position vertically in the current column
	# <https://ghostty.org/docs/vt/csi/vpa> Vertical Position Absolute (VPA)
	$'\e[5d' $'\e\[[0-9]*d' 'cursor-vertical-position' '[not-text][shapeshifter]'
	# Cursor Position / Direct Cursor Addressing / Horizontal Vertical Position
	# ESC [ <y> ; <x> H	CUP	Cursor Position	*Cursor moves to <x>; <y> coordinate within the viewport, where <x> is the column of the <y> line
	# <https://ghostty.org/docs/vt/csi/cup> Cursor Position (CUP)
	$'\e[5;5H' $'\e\[[0-9;]*H' 'cursor-position' '[not-text][shapeshifter]'
	# Cursor Position / Horizontal Vertical Position /  Direct Cursor Addressing
	# ESC [ <y> ; <x> f	HVP	Horizontal Vertical Position	*Cursor moves to <x>; <y> coordinate within the viewport, where <x> is the column of the <y> line
	$'\e[5;5f' $'\e\[[0-9;]*f' 'cursor-position' '[not-text][shapeshifter]'
	# Save Cursor and Attributes
	# ESC [ s	ANSISYSSC	Save Cursor – Ansi.sys emulation	**With no parameters, performs a save cursor operation like DECSC
	$'\e[s' '' 'save-cursor' '[not-text]'
	# Restore Cursor and Attributes
	# ESC [ u	ANSISYSRC	Restore Cursor – Ansi.sys emulation	**With no parameters, performs a restore cursor operation like DECRC
	$'\e[u' '' 'restore-cursor' '[not-text][shapeshifter]'

	# Cursor Visibility
	# <https://learn.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences#cursor-visibility>
	# ESC [ ? 12 h	ATT160	Text Cursor Enable Blinking	Start the cursor blinking
	$'\e[?12h' '' 'enable-blinking-cursor' '[not-text]'
	# ESC [ ? 12 l	ATT160	Text Cursor Disable Blinking	Stop blinking the cursor
	$'\e[?12l' '' 'disable-blinking-cursor' '[not-text]'
	# ESC [ ? 25 h	DECTCEM	Text Cursor Enable Mode Show	Show the cursor
	$'\e[?25h' '' 'show-cursor' '[not-text]' # used by [styles.bash]
	# ESC [ ? 25 l	DECTCEM	Text Cursor Enable Mode Hide	Hide the cursor
	$'\e[?25l' '' 'hide-cursor' '[not-text]' # used by [styles.bash]

	# Cursor Shape
	# <https://learn.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences#cursor-shape>
	# ESC [ 0 SP q	DECSCUSR	User Shape	Default cursor shape configured by the user
	# ESC [ 1 SP q	DECSCUSR	Blinking Block	Blinking block cursor shape
	# ESC [ 2 SP q	DECSCUSR	Steady Block	Steady block cursor shape
	# ESC [ 3 SP q	DECSCUSR	Blinking Underline	Blinking underline cursor shape
	# ESC [ 4 SP q	DECSCUSR	Steady Underline	Steady underline cursor shape
	# ESC [ 5 SP q	DECSCUSR	Blinking Bar	Blinking bar cursor shape
	# ESC [ 6 SP q	DECSCUSR	Steady Bar	Steady bar cursor shape
	# <https://ghostty.org/docs/vt/csi/decscusr> Set Cursor Style (DECSCUSR)
	$'\e[5 q' $'\e\[[0-6] q' 'cursor-shape' '[not-text]'

	# Viewport Positioning
	# <https://learn.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences#viewport-positioning>
	# Scroll Up / Scroll Scrolling Region Up
	# ESC [ <n> S	SU	Scroll Up	Scroll text up by <n>. Also known as pan down, new lines fill in from the bottom of the screen
	# <https://ghostty.org/docs/vt/csi/su> Scroll Up (SU)
	$'\e[5S' $'\e\[[0-9]*S' 'scroll-up' '[not-text][shapeshifter]'
	# Scroll Down / Scroll Scrolling Region Down
	# ESC [ <n> T	SD	Scroll Down	Scroll down by <n>. Also known as pan up, new lines fill in from the top of the screen
	# <https://ghostty.org/docs/vt/csi/sd> Scroll Down (SD)
	$'\e[5T' $'\e\[[0-9]*T' 'scroll-down' '[not-text][shapeshifter]'

	# Text Modification
	# <https://learn.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences#text-modification>
	# ESC [ <n> @	ICH	Insert Character	Insert <n> spaces at the current cursor position, shifting all existing text to the right. Text exiting the screen to the right is removed.
	# <https://ghostty.org/docs/vt/csi/ich> Insert Character (ICH)
	$'\e[5@' $'\e\[[0-9]*@' 'insert-character' '[not-text][shapeshifter]'
	# ESC [ <n> P	DCH	Delete Character	Delete <n> characters at the current cursor position, shifting in space characters from the right edge of the screen.
	# <https://ghostty.org/docs/vt/csi/dch> Delete Character (DCH)
	$'\e[5P' $'\e\[[0-9]*P' 'delete-character' '[not-text][shapeshifter]' # printf 'asd\e[G'; sleep 1; printf '%s' $'\e[5P'; sleep 5
	# ESC [ <n> X	ECH	Erase Character	Erase <n> characters from the current cursor position by overwriting them with a space character.
	# <https://ghostty.org/docs/vt/csi/ech> Erase Character (ECH)
	$'\e[5X' $'\e\[[0-9]*X' 'erase-character' '[not-text][shapeshifter]'
	# ESC [ <n> L	IL	Insert Line	Inserts <n> lines into the buffer at the cursor position. The line the cursor is on, and lines below it, will be shifted downwards.
	# Apple Terminal, no matter the N value, it removes the current and lower lines maintaining horizontal cursor
	# <https://ghostty.org/docs/vt/csi/il> Insert Line (IL)
	$'\e[5L' $'\e\[[0-9]*L' 'insert-line' '[not-text][shapeshifter]'
	# ESC [ <n> M	DL	Delete Line	Deletes <n> lines from the buffer, starting with the row the cursor is on.
	# Apple Terminal: no matter the N value, it removes the current and lower lines maintaining horizontal cursor
	# <https://ghostty.org/docs/vt/csi/dl> Delete Line (DL)
	$'\e[5M' $'\e\[[0-9]*M' 'delete-line' '[not-text][shapeshifter]'
	# ESC [ <n> J	ED	Erase in Display	Replace all text in the current viewport/screen specified by <n> with space characters
	# ESC [ Pn J           Erase in Display
	# Pn = None or 0       From Cursor to End of Screen
	# 1                    From Beginning of Screen to Cursor
	# 2                    Entire Screen
	# <https://ghostty.org/docs/vt/csi/ed> Erase Display (ED)
	$'\e[2J' $'\e\[[0-2]*J' 'erase-in-display' '[not-text][shapeshifter]'
	# ESC [ <n> K	EL	Erase in Line	Replace all text on the line with the cursor specified by <n> with space characters
	# ESC [ Pn K           Erase in Line
	# Pn = None or 0       From Cursor to End of Line
	# 1                    From Beginning of Line to Cursor
	# 2                    Entire Line
	# <https://ghostty.org/docs/vt/csi/el> Erase Line (EL)
	$'\e[2K' $'\e\[[0-2]*K' 'erase-in-line' '[not-text][shapeshifter]'
	# <https://ghostty.org/docs/vt/csi/rep> Repeat Previous Character (REP)
	$'\e[5b' $'\e\[[0-9]*b' 'repeat-character' '[not-text][shapeshifter]'

	# Screen Colors
	# <https://learn.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences#screen-colors>
	# ESC ] 4 ; <i> ; rgb : <r> / <g> / <b> <ST>	Modify Screen Colors	Sets the screen color palette index <i> to the RGB values specified in <r>, <g>, <b>
	$'\e]4;1;rgb:55/55/55\a' $'\e]4;[0-9]*;rgb:[0-9a-fA-F]{2}/[0-9a-fA-F]{2}/[0-9a-fA-F]{2}\a' 'modify-screen-color' '[not-text]'

	# Mode Changes
	# <https://learn.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences#mode-changes>
	# ESC =	DECKPAM	Enable Keypad Application Mode	Keypad keys will emit their Application Mode sequences.
	# <https://ghostty.org/docs/vt/esc/deckpam> Keypad Application Mode (DECKPAM)
	$'\e=' '' 'keypad-application-mode' '[not-text]'
	# ESC >	DECKPNM	Enable Keypad Numeric Mode	Keypad keys will emit their Numeric Mode sequences.
	# <https://ghostty.org/docs/vt/esc/deckpnm> Keypad Numeric Mode (DECKPNM)
	$'\e>' '' 'keypad-numeric-mode' '[not-text]'
	# ESC [ ? 1 h	DECCKM	Enable Cursor Keys Application Mode	Keypad keys will emit their Application Mode sequences.
	$'\e[?1h' '' 'enable-cursor-keys-application-mode' '[not-text]'
	# ESC [ ? 1 l	DECCKM	Disable Cursor Keys Application Mode (use Normal Mode)	Keypad keys will emit their Numeric Mode sequences.
	$'\e[?1l' '' 'disable-cursor-keys-application-mode' '[not-text]'

	# Query State
	# <https://learn.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences#query-state>
	# Report Cursor Position / Send Cursor Position Report
	# ESC [ 6 n	DECXCPR	Report Cursor Position	Emit the cursor position as: ESC [ <r> ; <c> R Where <r> = cursor row and <c> = cursor column
	# Device Status Report; Reports the cursor position (CPR) by transmitting `ESC[n;mR`, where n is the row and m is the column; `ESC [ 6 n` Send Cursor Position Report; DECXCPR; Report Cursor Position; Emit the cursor position as: ESC [ <r> ; <c> R Where <r> = cursor row and <c> = cursor column
	$'\e[6n' '' 'report-cursor-position' '[not-text][shapeshifter]' # used by [get-terminal-cursor-line-and-column]; shapeshifter as can inject data into terminal if no proper active read
	# <https://ghostty.org/docs/vt/csi/dsr> Device Status Report (DSR)
	$'\e[5n' '' 'report-operating-status' '[not-text][shapeshifter]'
	# ESC [ 0 c	DA	Device Attributes	Report the terminal identity. Will emit “\x1b[?1;0c”, indicating "VT101 with No Options".
	$'\e[0c' '' 'report-terminal-identity' '[not-text][shapeshifter]' # shapeshifter as can inject data into terminal if no proper active read

	# Tabs
	# <https://learn.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences#tabs>
	# ESC H	HTS	Horizontal Tab Set	Sets a tab stop in the current column the cursor is in.
	$'\eH' '' 'horizontal-tab-set' '[not-text]'
	# ESC [ <n> I	CHT	Cursor Horizontal (Forward) Tab	Advance the cursor to the next column (in the same row) with a tab stop. If there are no more tab stops, move to the last column in the row. If the cursor is in the last column, move to the first column of the next row.
	# Horizontal Tab / Cursor Horizontal Tab
	# <https://ghostty.org/docs/vt/csi/cht> Cursor Horizontal Tabulation (CHT)
	$'\e[5I' $'\e\[[0-9]*I' 'horizontal-tab' '[not-text][shapeshifter]'
	# ESC [ <n> Z	CBT	Cursor Backwards Tab	Move the cursor to the previous column (in the same row) with a tab stop. If there are no more tab stops, moves the cursor to the first column. If the cursor is in the first column, doesn’t move the cursor.
	# Backward Tab; in Apple Terminal, no matter the N value, it goes back to the start of the line
	# <https://ghostty.org/docs/vt/csi/cbt> Cursor Backward Tabulation (CBT)
	$'\e[5Z' $'\e\[[0-9]*Z' 'backward-tab' '[not-text][shapeshifter]'
	# Tab Clear / Clear Tab at Current Position / Clear All Tabs
	# ESC [ 0 g	TBC	Tab Clear (current column)	Clears the tab stop in the current column, if there is one. Otherwise does nothing.
	# ESC [ 3 g	TBC	Tab Clear (all columns)	Clears all currently set tab stops.
	# Tab Clear; Pn = None or 0 Clear Tab at Current Position; 3 Clear All Tabs
	# <https://ghostty.org/docs/vt/csi/tbc> Tab Clear (TBC)
	$'\e[3g' $'\e\[[03]*g' 'tab-clear' '[not-text]'

	# Designate Character Set
	# <https://learn.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences#designate-character-set>
	# ESC ( 0	Designate Character Set – DEC Line Drawing	Enables DEC Line Drawing Mode
	$'\e(0' '' 'drawing-mode' '[not-text][shapeshifter]'
	# ESC ( B	Designate Character Set – US ASCII	Enables ASCII Mode (Default)
	$'\e(B' '' 'ascii-mode' '[not-text][shapeshifter]'

	# Scrolling Margins
	# <https://learn.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences#scrolling-margins>
	# ESC [ <t> ; <b> r	DECSTBM	Set Scrolling Region	Sets the VT scrolling margins of the viewport.
	# <https://ghostty.org/docs/vt/csi/decstbm> Set Top and Bottom Margins (DECSTBM)
	$'\e[5;5r' $'\e\[[0-9;]*r' 'set-top-and-bottom-margins' '[not-text][shapeshifter]'
	# <https://ghostty.org/docs/vt/csi/decslrm> Set Left and Right Margins (DECSLRM)
	$'\e[5;5s' $'\e\[[0-9;]*s' 'set-left-and-right-margins' '[not-text][shapeshifter]'

	# Window Title
	# <https://learn.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences#window-title>
	# ESC ] 0 ; <string> <ST>	Set Window Title	Sets the console window’s title to <string>.
	# ESC ] 2 ; <string> <ST>	Set Window Title	Sets the console window’s title to <string>.
	$'\e]0;TITLE\a' $'\e\][02];[^\a]*\a' 'terminal-title' '[not-text]' # used by [styles.bash]

	# Alternate Screen Buffer
	# <https://learn.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences#alternate-screen-buffer>
	# ESC [ ? 1 0 4 9 h	Use Alternate Screen Buffer	Switches to a new alternate screen buffer.
	$'\e[?1049h' '' 'alternative-screen-buffer' '[not-text][shapeshifter]' # used by [styles.bash]
	# ESC [ ? 1 0 4 9 l	Use Main Screen Buffer	Switches to the main buffer.
	$'\e[?1049l' '' 'default-screen-buffer' '[not-text][shapeshifter]' # used by [styles.bash]

	# Window Width
	# <https://learn.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences#window-width>
	# ESC [ ? 3 h	DECCOLM	Set Number of Columns to 132	Sets the console width to 132 columns wide.
	$'\e[?3h' '' 'set-number-of-columns-132' '[not-text][shapeshifter]' # this doesn't appear to shapeshift in Apple Terminal, but surely it should
	# ESC [ ? 3 l	DECCOLM	Set Number of Columns to 80	Sets the console width to 80 columns wide.
	$'\e[?3l' '' 'set-number-of-columns-80' '[not-text][shapeshifter]' # this doesn't appear to shapeshift in Apple Terminal, but surely it should

	# Soft Reset
	# <https://learn.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences#soft-reset>
	# ESC [ ! p	DECSTR	Soft Reset	Reset certain terminal settings to their defaults.
	$'\e[!p' '' 'soft-reset' '[not-text][shapeshifter]' # this doesn't appear to shapeshift in Apple Terminal, but it probably does if settings were altered before the reset

	# Other Control Sequence Introducer Commands (CSI)
	# <https://en.wikipedia.org/wiki/ANSI_escape_code#Control_Sequence_Introducer_commands>
	$'\e[?1004h' '' 'enable-reporting-focus' '[not-text]'
	$'\e[?1004l' '' 'disable-reporting-focus' '[not-text]'
	$'\e[?2004h' '' 'enable-bracketed-paste-mode' '[not-text]'
	$'\e[?2004l' '' 'disable-bracketed-paste-mode' '[not-text]'

	# Other Operating System Commands (OSC)
	$'\e]11;?\a' '' 'report-colors' '[not-text][shapeshifter]'           # used by [get-terminal-theme]; shapeshifter as can inject data into terminal if no proper active read
	$'\e]52;c;CLIPBOARD\a' $'\e\]52;c;[^\a]*\a' 'clipboard' '[not-text]' # used by [styles.bash]

	# Other ANSI Sequences
	# <https://www.gnu.org/software/screen/manual/html_node/Control-Sequences.html>
	# ESC E                           Next Line
	$'\eE' '' 'next-line' '[not-text][shapeshifter]'
	# ESC D                           Index
	# <https://ghostty.org/docs/vt/esc/ind> Index (IND)
	$'\eD' '' 'index' '[not-text][shapeshifter]'
	# ESC M                           Reverse Index
	#   ^ handled earlier in pressable keys
	# ESC H                           Horizontal Tab Set
	#   ^ handled earlier in microsoft section
	# ESC Z                           Send VT100 Identification String
	$'\eZ' '' 'send-vt100-identification-string' '[not-text]'
	# ESC 8                   (V)     Restore Cursor and Attributes
	#   ^ handled earlier in microsoft section
	# ESC [s                  (A)     Save Cursor and Attributes
	#   ^ handled earlier in microsoft section
	# ESC [u                  (A)     Restore Cursor and Attributes
	#   ^ handled earlier in microsoft section
	# ESC c                           Reset to Initial State
	# <https://ghostty.org/docs/vt/esc/ris> Full Reset (RIS)
	$'\ec' '' 'reset' '[not-text][shapeshifter]'
	# ESC g                           Visual Bell
	$'\eg' '' 'visual-bell' '[not-text]'
	# ESC Pn p                        Cursor Visibility (97801)
	#     Pn = 6                      Invisible
	#          7                      Visible
	$'\e[6p' '' 'hide-cursor' '[not-text]' # Cursor Visibility (97801) Invisible
	$'\e[7p' '' 'show-cursor' '[not-text]' # Cursor Visibility (97801) Visible
	# ESC =                   (V)     Application Keypad Mode
	#   ^ handled earlier in microsoft section
	# ESC >                   (V)     Numeric Keypad Mode
	#   ^ handled earlier in microsoft section
	# ESC # 8                 (V)     Fill Screen with E's
	# <https://ghostty.org/docs/vt/esc/decaln> Screen Alignment Test (DECALN)
	$'\e#8' '' 'test-card' '[not-text][shapeshifter]'
	# ESC \                   (A)     String Terminator
	$'\e\\' '' 'string-terminator' '[not-text]'
	# ESC ^                   (A)     Privacy Message String (Message Line)
	$'\e^' '' 'privacy-message-string' '[not-text]'
	# ESC !                           Global Message String (Message Line)
	$'\e!' '' 'global-message-string' '[not-text]'
	# ESC k                           Title Definition String
	$'\ek' '' 'title-definition-string' '[not-text]'
	# ESC P                   (A)     Device Control String. Outputs a string directly to the host terminal without interpretation.
	$'\eP' '' 'device-control-string' '[not-text]'
	# ESC _                   (A)     Application Program Command (Hardstatus)
	$'\e_' '' 'application-program-command' '[not-text]'
	# ESC ] 0 ; string ^G     (A)     Operating System Command (Hardstatus, xterm title hack)
	#   ^ handled earlier in microsoft section
	# ESC ] 83 ; cmd ^G       (A)     Execute screen command. This only works if multi-user support is compiled into screen.
	$'\e]83;\a' $'\e\]83;[^\a]*\a' 'screen-command' '[not-text]'
	# '\e]83;' $'\e\]83;' 'begin-screen-command' '[not-text]'
	# Control-N               (A)     Lock Shift G1 (SO)
	#   ^ need more docs
	# Control-O               (A)     Lock Shift G0 (SI)
	#   ^ need more docs
	# ESC n                   (A)     Lock Shift G2
	$'\en' '' 'lock-shift-g2' '[not-text]'
	# ESC o                   (A)     Lock Shift G3
	$'\eo' '' 'lock-shift-g3' '[not-text]'
	# ESC N                   (A)     Single Shift G2
	$'\eN' '' 'single-shift-g2' '[not-text]'
	# ESC O                   (A)     Single Shift G3
	# Single Shift G3; Single Shift Select of G3 Character Set (SS3 is 0x8f), VT220. This affects next character only; note $'\x8f' becomes a ? in Apple Terminal
	$'\eO' '' 'single-shift-g3' '[not-text]'
	# ESC ( Pcs               (A)     Designate character set as G0
	#   ^ handled earlier in microsoft section
	# ESC ) Pcs               (A)     Designate character set as G1
	#   ^ handled earlier in microsoft section
	# ESC * Pcs               (A)     Designate character set as G2
	#   ^ need more docs
	# ESC + Pcs               (A)     Designate character set as G3
	#   ^ need more docs
	# ESC [ Pn ; Pn H                 Direct Cursor Addressing
	#   ^ handled earlier in microsoft section
	# ESC [ Pn ; Pn f                 same as above
	#   ^ handled earlier in microsoft section
	# ESC [ Pn J                      Erase in Display
	#       Pn = None or 0            From Cursor to End of Screen
	#            1                    From Beginning of Screen to Cursor
	#            2                    Entire Screen
	#   ^ handled earlier in microsoft section
	# ESC [ Pn K                      Erase in Line
	#       Pn = None or 0            From Cursor to End of Line
	#            1                    From Beginning of Line to Cursor
	#            2                    Entire Line
	#   ^ handled earlier in microsoft section
	# ESC [ Pn X                      Erase character
	#   ^ handled earlier in microsoft section
	# ESC [ Pn A                      Cursor Up
	#   ^ handled earlier in microsoft section
	# ESC [ Pn B                      Cursor Down
	#   ^ handled earlier in microsoft section
	# ESC [ Pn C                      Cursor Right
	#   ^ handled earlier in microsoft section
	# ESC [ Pn D                      Cursor Left
	#   ^ handled earlier in microsoft section
	# ESC [ Pn E                      Cursor next line
	#   ^ handled earlier in microsoft section
	# ESC [ Pn F                      Cursor previous line
	#   ^ handled earlier in microsoft section
	# ESC [ Pn G                      Cursor horizontal position
	#   ^ handled earlier in microsoft section
	# ESC [ Pn `                      same as above
	# <https://ghostty.org/docs/vt/csi/hpa> Horizontal Position Absolute (HPA)
	$'\e[5`' $'\e\[[0-9]*`' 'horizontal-position-absolute' '[not-text][shapeshifter]'
	# <https://ghostty.org/docs/vt/csi/hpr> Horizontal Position Relative (HPR)
	$'\e[5a' $'\e\[[0-9]*a' 'horizontal-position-relative' '[not-text][shapeshifter]'
	# <https://ghostty.org/docs/vt/csi/vpr> Vertical Position Relative (VPR)
	$'\e[5e' $'\e\[[0-9]*e' 'vertical-position-relative' '[not-text][shapeshifter]'
	# ESC [ Pn d                      Cursor vertical position
	#   ^ handled earlier in microsoft section
	# ESC [ Ps ;...; Ps m             Select Graphic Rendition
	#       Ps = None or 0            Default Rendition
	#            1                    Bold
	#            2            (A)     Faint
	#            3            (A)     Standout Mode (ANSI: Italicized)
	#            4                    Underlined
	#            5                    Blinking
	#            7                    Negative Image
	#            22           (A)     Normal Intensity
	#            23           (A)     Standout Mode off (ANSI: Italicized off)
	#            24           (A)     Not Underlined
	#            25           (A)     Not Blinking
	#            27           (A)     Positive Image
	#            30           (A)     Foreground Black
	#            31           (A)     Foreground Red
	#            32           (A)     Foreground Green
	#            33           (A)     Foreground Yellow
	#            34           (A)     Foreground Blue
	#            35           (A)     Foreground Magenta
	#            36           (A)     Foreground Cyan
	#            37           (A)     Foreground White
	#            39           (A)     Foreground Default
	#            40           (A)     Background Black
	#            ...                  ...
	#            49           (A)     Background Default
	#   ^ handled earlier in microsoft section
	# ESC [ Pn g                      Tab Clear
	#       Pn = None or 0            Clear Tab at Current Position
	#            3                    Clear All Tabs
	#   ^ handled earlier in microsoft section
	# ESC [ Pn ; Pn r         (V)     Set Scrolling Region
	#   ^ handled earlier in microsoft section
	# ESC [ Pn I              (A)     Horizontal Tab
	#   ^ handled earlier in microsoft section
	# ESC [ Pn Z              (A)     Backward Tab
	#   ^ handled earlier in microsoft section
	# ESC [ Pn L              (A)     Insert Line
	#   ^ handled earlier in microsoft section
	# ESC [ Pn M              (A)     Delete Line
	#   ^ handled earlier in microsoft section
	# ESC [ Pn @              (A)     Insert Character
	#   ^ handled earlier in microsoft section
	# ESC [ Pn P              (A)     Delete Character
	#   ^ handled earlier in microsoft section
	# ESC [ Pn S                      Scroll Scrolling Region Up
	#   ^ handled earlier in microsoft section
	# ESC [ Pn T                      Scroll Scrolling Region Down
	#   ^ handled earlier in microsoft section
	# ESC [ Pn ^                      same as above
	$'\e[5^' $'\e\[[0-9]*\^' 'scroll-down' '[not-text]'
	# ESC [ Ps ;...; Ps h             Set Mode
	# ESC [ Ps ;...; Ps l             Reset Mode
	#       Ps = 4            (A)     Insert Mode
	#            20           (A)     ‘Automatic Linefeed’ Mode.
	#            34                   Normal Cursor Visibility
	#            ?1           (V)     Application Cursor Keys
	#   ^ handled earlier in microsoft section
	#            ?3           (V)     Change Terminal Width to 132 columns
	#   ^ handled earlier in microsoft section
	#            ?5           (V)     Reverse Video
	#            ?6           (V)     ‘Origin’ Mode
	#            ?7           (V)     ‘Wrap’ Mode
	#            ?9                   X10 mouse tracking
	#            ?25          (V)     Visible Cursor
	#   ^ handled earlier in microsoft section
	#            ?47                  Alternate Screen (old xterm code)
	#            ?1000        (V)     VT200 mouse tracking
	#            ?1047                Alternate Screen (new xterm code)
	#            ?1049                Alternate Screen (new xterm code)
	#   ^ handled earlier in microsoft section
	$'\e[?5h' $'\e\[[0-9?]*h' 'set-mode' '[not-text][shapeshifter]'
	$'\e[?5l' $'\e\[[0-9?]*l' 'reset-mode' '[not-text][shapeshifter]'
	# ESC [ 5 i               (A)     Start relay to printer (ANSI Media Copy)
	$'\e[5i' '' 'start-relay-to-printer' '[not-text]'
	# ESC [ 4 i               (A)     Stop relay to printer (ANSI Media Copy)
	$'\e[4i' '' 'stop-relay-to-printer' '[not-text]'
	# ESC [ 8 ; Ph ; Pw t             Resize the window to ‘Ph’ lines and ‘Pw’ columns (SunView special)
	$'\e[8;10;100t' $'\e\[8;[0-9;]*t' 'terminal-resize' '[not-text][shapeshifter]' # used by [styles.bash]
	# ESC [ c                         Send VT100 Identification String
	$'\e[c' '' 'send-vt100-identification-string' '[not-text]'
	# ESC [ x                 (V)     Send Terminal Parameter Report
	$'\e[x' '' 'send-terminal-parameter-report' '[not-text]'
	# ESC [ > c                       Send Secondary Device Attributes String
	$'\e[>c' '' 'send-secondary-device-attributes-string' '[not-text]'
	# ESC [ 6 n                       Send Cursor Position Report
	#   ^ handled earlier in microsoft section
	# <https://ghostty.org/docs/vt/csi/xtshiftescape> Set Shift-Escape (XTSHIFTESCAPE)
	$'\e[>s' $'\e\[>[01]*s' 'shift-escape' '[not-text][shapeshifter]'

	# The below need to be at the end, as they begin or end other sequences
	# <https://en.wikipedia.org/wiki/ANSI_escape_code#C0_control_codes>
	# ^G	0x07	BEL	Bell	Makes an audible noise.
	# [0x07 = $'\x07' = $'\007' = $'\a'] is `^ G` macos
	# <https://ghostty.org/docs/vt/control/bel> Bell (BEL)
	$'\a' '' 'bell' '[read-key][not-text]' # besides bell, this is also used to end clipboard and terminal title sequences
	# ^[	0x1B	ESC	Escape	Starts all the escape sequences
	# [0x1B = $'\x1B' = $'\033' = $'\e'] is `^ [` on macos
	$'\e' '' 'escape' '[not-text][shapeshifter]' # remain shapeshifter as it could be any of the unlisted sequences which could be a shapeshifter
)
ANSI_SIZE=${#ANSI[@]}

# these were written before pattern became optional
# function __ansi_has_any {
# 	local input="$1" filter_with="${2-}" filter_without="${3-}" pattern tags
# 	local -i index
# 	for ((index = 0; index < ANSI_SIZE; index += 4)); do
# 		# 0=<KEY> 1=<PATTERN> 2=<NAME> 3=<TAGS>
# 		tags="${ANSI[index + 3]}"
# 		if [[ -n $filter_with && $tags != *"[$filter_with]"* ]]; then
# 			continue # does not have the with filter
# 		elif [[ -n $filter_without && $tags == *"[$filter_without]"* ]]; then
# 			continue # does have the without filter
# 		fi
# 		pattern="${ANSI[index + 1]}"
# 		if [[ $input =~ $pattern ]]; then
# 			return 0 # is a shapeshifter
# 		fi
# 	done
# 	return 1
# }
# function __ansi_replace_with_name {
# 	local input="$1" filter="$2" pattern match tail
# 	tail="$input"
# 	local -i input_size input_index match_size ansi_index
# 	for (( input_index = 0, input_size = ${#input}; input_index < input_size; input_index++ )); do
# 		for (( ansi_index = 0; ansi_index < ANSI_SIZE; ansi_index += 4 )); do
# 			# 0=<KEY> 1=<PATTERN> 2=<NAME> 3=<TAGS>
# 			tags="${ANSI[ansi_index + 3]}"
# 			if [[ $tags != *"[$filter]"* ]]; then
# 				continue
# 			fi
# 			pattern="${ANSI[ansi_index + 1]}"
# 			if [[ ${input:input_index} =~ ^$pattern ]]; then
# 				match="${BASH_REMATCH[0]}"
# 				match_size="${#match}"
# 				input_index="$((input_index + match_size - 1))"
# 				tail="${input:input_index}"
# 			fi
# 		done
# 	done
# 	printf '%s' "$tail" || return
# }

function __ansi_trim {
	local input="$1" filter="$2" tags pattern key match results=()
	local -i input_size input_index match_size ansi_index last_index=0 key_size
	for ((input_index = 0, input_size = ${#input}; input_index < input_size; input_index++)); do
		# this little case statement turns [echo-trim-special --test] from 7s to 1s
		case "${input:input_index:1}" in
		$'\e' | $'\r' | $'\b' | $'\177' | $'\a' | $'\f' | "$ANSI_ALL") : ;;
		*) continue ;;
		esac
		for ((ansi_index = 0; ansi_index < ANSI_SIZE; ansi_index += 4)); do
			# 0=<KEY> 1=<PATTERN> 2=<NAME> 3=<TAGS>
			tags="${ANSI[ansi_index + 3]}"
			if [[ $tags != *"[$filter]"* ]]; then
				continue
			fi
			pattern="${ANSI[ansi_index + 1]}"
			if [[ -z $pattern ]]; then
				key="${ANSI[ansi_index]}"
				key_size="${#key}"
				# if [[ ${input:input_index} == "$key"* ]]; then <-- slower on [echo-trim-special --test] by about 500ms
				if [[ ${input:input_index:key_size} == "$key" ]]; then
					match_size="${#key}"
				else
					match_size=0
				fi
			elif [[ ${input:input_index} =~ ^$pattern ]]; then
				match="${BASH_REMATCH[0]}"
				match_size="${#match}" # note that earlier bash versions could pass the regex, but match will be empty and match_size will result in 0
			else
				match_size=0
			fi
			if [[ $match_size -gt 0 ]]; then
				results+=("${input:last_index:input_index-last_index}")
				last_index="$((input_index + match_size))"
				input_index="$((input_index + match_size - 1))" # -1 to account for the next increment
				break
			fi
		done
	done
	results+=("${input:last_index}")
	printf '%s' "${results[@]}" || return
}

# this is the original and more performant variation of `__ansi_keep_right`, used by `echo-revolving-door`
function __split_shapeshifting {
	# trim -- prefix
	if [[ ${1-} == '--' ]]; then
		shift
	fi
	# https://www.gnu.org/software/bash/manual/bash.html#Pattern-Matching
	local input
	for input in "$@"; do
		input="${input//[[:cntrl:]]\[*([\;\?0-9])[\][\^\`\~\\ABCDEFGHIJKLMNOPQSTUVWXYZabcdefghijklnosu]/$'\n'}" # cursor movement
		input="${input//[[:cntrl:]][\]\`\^\\78M]/$'\n'}"                                                        # save and restore cursor
		input="${input//[[:cntrl:]][bf]/$'\n'}"                                                                 # page-up, page-down
		input="${input//[$'\r'$'\177'$'\b']/$'\n'}"                                                             # carriage return, backspace
		__print_lines "$input" || return
	done
}

# keep right of everything that does not match the filter
# redo this as __ansi_truncate_complex_shapeshifting
function __ansi_keep_right {
	local input="$1" filter="$2" tags pattern key match
	local -i input_size input_index match_size ansi_index last_index=0 key_size
	for ((input_index = 0, input_size = ${#input}; input_index < input_size; input_index++)); do
		for ((ansi_index = 0; ansi_index < ANSI_SIZE; ansi_index += 4)); do
			# 0=<KEY> 1=<PATTERN> 2=<NAME> 3=<TAGS>
			tags="${ANSI[ansi_index + 3]}"
			if [[ $tags == *"[$filter]"* ]]; then
				continue
			fi
			pattern="${ANSI[ansi_index + 1]}"
			if [[ -z $pattern ]]; then
				key="${ANSI[ansi_index]}"
				key_size="${#key}"
				if [[ ${input:input_index:key_size} == "$key" ]]; then
					match_size="${#key}"
				else
					match_size=0
				fi
			elif [[ ${input:input_index} =~ ^$pattern ]]; then
				match="${BASH_REMATCH[0]}"
				match_size="${#match}" # note that earlier bash versions could pass the regex, but match will be empty and match_size will result in 0
			else
				match_size=0
			fi
			if [[ $match_size -gt 0 ]]; then
				last_index="$((input_index + match_size))"
				input_index="$((input_index + match_size - 1))"
				break
			fi
		done
	done
	printf '%s' "${input:last_index}" || return
}

# determine if the input contains shapeshifting ANSI Escape Codes
# this is beta, and may change later
function __is_shapeshifter {
	# trim -- prefix
	if [[ ${1-} == '--' ]]; then
		shift
	fi
	local input="$1" tags pattern key match
	local -i input_size input_index match_size ansi_index key_size
	for ((input_index = 0, input_size = ${#input}; input_index < input_size; input_index++)); do
		for ((ansi_index = 0; ansi_index < ANSI_SIZE; ansi_index += 4)); do
			# 0=<KEY> 1=<PATTERN> 2=<NAME> 3=<TAGS>
			pattern="${ANSI[ansi_index + 1]}"
			if [[ -z $pattern ]]; then
				key="${ANSI[ansi_index]}"
				key_size="${#key}"
				if [[ ${input:input_index:key_size} == "$key" ]]; then
					match_size="${#key}"
				else
					match_size=0
				fi
			elif [[ ${input:input_index} =~ ^$pattern ]]; then
				match="${BASH_REMATCH[0]}"
				match_size="${#match}" # note that earlier bash versions could pass the regex, but match will be empty and match_size will result in 0
			else
				match_size=0
			fi
			if [[ $match_size -gt 0 ]]; then
				tags="${ANSI[ansi_index + 3]}"
				if [[ $tags == *"[shapeshifter]"* ]]; then
					return 0
				fi
				input_index="$((input_index + match_size - 1))"
				break
			fi
		done
	done
	return 1
}

function __read_key {
	# process
	# do not use a subsequent_timeout smaller than 0.01, as that is still 100 keys a second, which is faster than any human can press and reasonable enough for automated key presses, and more importantly, anything smaller introduces issues where only a portion of the ansi escape combination is read, and in which re-attempting to read the remaining portion results in discarded characters of the ansi escape sequence, see alternative failed implementations at: https://gist.github.com/balupton/d8ee5f5d6022d3988f148df26909d638
	local item option_quiet='yes' option_timeout='' option_continue='no' subsequent_timeout='0.01' option_keep_line_buffer_newlines='no'
	while [[ $# -ne 0 ]]; do
		item="$1"
		shift
		case "$item" in
		--help | -h) read-key --help || return ;;
		--no-verbose* | --verbose*) __flag --source={item} --target={option_quiet} --non-affirmative --coerce || return ;;
		--no-quiet* | --quiet*) __flag --source={item} --target={option_quiet} --affirmative --coerce || return ;;
		--no-continue* | --continue*) __flag --source={item} --target={option_continue} --affirmative --coerce || return ;;
		--timeout=*) option_timeout="${item#*=}" ;;
		--no-keep-line-buffer-newlines* | --keep-line-buffer-newlines*) __flag --source={item} --target={option_keep_line_buffer_newlines} --affirmative --coerce || return ;;
		--*) __unrecognised_flag "$item" || return ;;
		*) __unrecognised_argument "$item" || return ;;
		esac
	done

	# timeout
	if ! __is_number "$option_timeout"; then
		option_timeout=600 # ten minutes
	fi

	# bash v3 compat
	option_timeout="$(__get_read_decimal_timeout "$option_timeout")" || return
	subsequent_timeout="$(__get_read_decimal_timeout "$subsequent_timeout")" || return

	# =====================================
	# Action

	local inputs='' input='' last_key=''
	if [[ $IS_STDIN_LINE_BUFFERED == 'no' ]]; then
		function __discard_key_if_line_buffer_enter { return 1; }
	else
		function __discard_key_if_line_buffer_enter {
			[[ $input == $'\n' && -n $last_key && $last_key != $'\n' ]] || return
		}
	fi
	function __add {
		local input="$1"
		if [[ -z $input ]]; then
			input=$'\n'
		fi
		if [[ $input == $'\e' || $input == $'\n' ]]; then
			__flush || return
		fi
		if __discard_key_if_line_buffer_enter; then
			if [[ $option_keep_line_buffer_newlines == 'yes' ]]; then
				printf '%s\n' 'line-buffer' || return
			fi
			last_key="$input"
			input=''
		fi
		#printf 'input: %q\tinputs: %q\n' "$input" "$inputs"
		inputs+="$input"
	}
	function __read_and_flush {
		# read
		local -i status=0
		local readings=() reading
		# read rapidly then add
		IFS= read -rsn1 -t "$option_timeout" input || status=$?
		if [[ $status -eq 0 ]]; then
			readings+=("$input")
			while :; do
				# IFS= allows the space character [ ] to be indentation
				# -r allows backslash key [\] to be kept
				# -s prevents the input from being echoed
				# -n1 reads only one character, which is necessary surprisingly to read non-printable characters
				if ! IFS= read -rsn1 -t "$subsequent_timeout" input; then
					break
				fi
				readings+=("$input")
			done
		fi
		for reading in "${readings[@]}"; do
			__add "$reading" || return
		done

		# handle errors
		# in practice, timeouts are only ever 148, however docs say >=128 should be considered timeout
		if [[ $status -ge 128 ]]; then
			return 60 # ETIMEDOUT 60 Operation timed out
		elif [[ $status -eq 1 ]] && ([[ ! -t 0 ]] || ! read -t 0); then
			# this can happen on CI environments, and other environments with stdin and TTY trickery
			return 60 # ETIMEDOUT 60 Operation timed out
		elif [[ $status -ne 0 ]]; then
			return "$status" # some other issue, let the caller figure it out
		fi

		# got key
		__flush || return
	}
	function __print_and_trim_key {
		local name="$1" key="$2"
		local -i size="${#key}"
		last_key="$key"
		inputs="${inputs:size}"
		if [[ $option_quiet == 'no' ]]; then
			printf '%s %q\n' "$name" "$key" || return
		else
			printf '%s\n' "$name" || return
		fi
	}
	function __match_pattern_and_trim_once {
		local tags pattern key name match
		local -i ansi_index
		for ((ansi_index = 0; ansi_index < ANSI_SIZE; ansi_index += 4)); do
			# 0=<KEY> 1=<PATTERN> 2=<NAME> 3=<TAGS>
			tags="${ANSI[ansi_index + 3]}"
			if [[ $tags != *"[read-key]"* ]]; then
				continue
			fi
			pattern="${ANSI[ansi_index + 1]}"
			if [[ -z $pattern ]]; then
				key="${ANSI[ansi_index]}"
				if [[ $inputs == $key* ]]; then
					match="$key"
				else
					match=''
				fi
			elif [[ $inputs =~ ^$pattern ]]; then
				match="${BASH_REMATCH[0]}"
			else
				match=''
			fi
			if [[ -n $match ]]; then
				name="${ANSI[ansi_index + 2]}"
				__print_and_trim_key "$name" "$match" || return
				return 0
			fi
		done
		return 1
	}
	function __match_key_and_trim_once {
		local name="$1" key
		for key in "$@"; do
			if [[ $inputs == "$key"* ]]; then
				__print_and_trim_key "$name" "$key" || return
				return 0
			fi
		done
		return 1
	}
	function __match_print_and_trim_once {
		local key
		if [[ $inputs =~ ^[[:print:]] ]]; then
			key="${BASH_REMATCH[0]}" # bash 3.2 does not support multiple calls to BASH_REMATCH so it must be cached
			__print_and_trim_key "$key" "$key" || return
			# __print_and_trim_key "${BASH_REMATCH[0]}" "${BASH_REMATCH[0]}" <-- bash 3.2 does not like this
			return 0
		fi
		return 1
	}
	function __flush {
		while [[ -n $inputs ]]; do
			case "$inputs" in

			# escape
			# [0x1B = $'\x1b' = $'\033' = $'\u001B' = $'\e'] is [⎋] ubuntu, macos
			$'\e' | $'\e\n'* | $'\e\e'*) __match_key_and_trim_once 'escape' $'\e' || return ;;

			# standard key or unknown special key
			*)
				if ! __match_pattern_and_trim_once && ! __match_print_and_trim_once; then
					if [[ $option_quiet == 'no' ]]; then
						printf '%s %q\n' 'unknown' "$inputs" >&2 || return # should be the same as __print_and_trim_key but go to stderr instead
					fi
					return 94 # EBADMSG 94 Bad message
				fi
				;;
			esac
		done
	}

	# act
	if [[ $option_continue == 'no' ]]; then
		__read_and_flush || return
	else
		while :; do
			__read_and_flush || return
		done
	fi
}

function __should_wrap {
	local item option_width='' option_content=''
	while [[ $# -ne 0 ]]; do
		item="$1"
		shift
		case "$item" in
		--width=*) option_width="${item#*=}" ;;
		--content=*) option_content="${item#*=}" ;;
		--*) __unrecognised_flag "$item" || return ;;
		*) __unrecognised_argument "$item" || return ;;
		esac
	done
	__affirm_value_is_positive_integer "$option_width" '<width>' || return
	__affirm_value_is_defined "$option_content" '<content>' || return
	if [[ $option_width -eq 0 ]]; then
		return 1 # don't wrap
	fi
	if [[ ${#option_content} -gt $option_width || $option_content =~ [^a-zA-Z0-9\ \n] ]]; then
		return 0 # do wrap
	fi
	return 1 # don't wrap
}
