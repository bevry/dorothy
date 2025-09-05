#!/usr/bin/env bash
# shellcheck disable=SC2034
# Used by `echo-style`, `ask`, `choose`, `confirm`
# Do not use `export` keyword in this file

# See <ansi-escape-codes.md>

# disable tracing of this while it loads as it is too large
# shared by `bash.bash` `styles.bash`
if [[ $- == *x* ]]; then
	set +x
	BASH_X=yes
fi
if [[ $- == *v* ]]; then
	set +v
	BASH_V=yes
fi

#######################################
# STYLE SUPPORT #######################

GITHUB_ACTIONS="${GITHUB_ACTIONS-}"
THEME="$(get-terminal-theme || :)"
USE_COLOR="$(get-terminal-color-support --fallback=yes)" # USE_COLOR is actually only used here, not in get-terminal-color-support
TERM_PROGRAM="${TERM_PROGRAM-}"
if [[ $TERM_PROGRAM =~ ^(Hyper|tmux|vscode)$ ]]; then
	ITALICS_SUPPORTED='yes'
else
	ITALICS_SUPPORTED='no'
fi
ALTERNATIVE_SCREEN_BUFFER_SUPPORTED="$(get-terminal-alternative-support)"

#######################################
# ANSI STYLES #########################

# terminal
style__clear_line=$'\e[G\e[2K'  # move cursor to beginning of current line and erase/clear/overwrite-with-whitespace the line, $'\e[G\e[J' is equivalent
style__delete_line=$'\e[F\e[J'  # move cursor to beginning of the prior line and erase/clear/overwrite-with-whitespace all lines from there
style__clear_screen=$'\e[H\e[J' # # \e[H\e[J moves cursor to the top and erases the screen (so no effect to the scroll buffer), unfortunately \e[2J moves the cursor to the bottom, then prints a screen worth of blank lines, then moves the cursor to the top (keeping what was on the screen in the scroll buffer, padded then by a screen of white space); tldr \e[H\e[J wipes the screen, \e[2J pads the screen
style__enable_cursor_blinking=$'\e[?12h'
style__disable_cursor_blinking=$'\e[?12l'
style__show_cursor=$'\e[?25h'
style__hide_cursor=$'\e[?25l'
style__reset_cursor=$'\e[0 q'
style__cursor_blinking_block=$'\e[1 q'
style__cursor_steady_block=$'\e[2 q'
style__cursor_blinking_underline=$'\e[3 q'
style__cursor_steady_underline=$'\e[4 q'
style__cursor_blinking_bar=$'\e[5 q'
style__cursor_steady_bar=$'\e[6 q'
if [[ $ALTERNATIVE_SCREEN_BUFFER_SUPPORTED == 'yes' ]]; then
	style__alternative_screen_buffer=$'\e[?1049h\e[H\e[J' # switch-to/enable/open alternative screen buffer (of which there is only one), the \e[H is necessary to put the cursor at the top on wsl ubuntu otherwise it stays in the same place, and unfortunately the clear is sometimes necessary for vscode
	style__default_screen_buffer=$'\e[?1049l'             # restore/enable/open/switch-to the default/primary/main/normal screen buffer
else
	# if unable to tap into alternative screen buffer, then output a newline (in case clear screen isn't supported) and clear the screen (which GitHub CI doesn't support, but it does not output the ansi escape code) - without this change, then following output will incorrectly be on the same line as the previous output
	# https://github.com/bevry/dorothy/actions/runs/11358242517/job/31592464176#step:2:3754
	# https://github.com/bevry/dorothy/actions/runs/11358441972/job/31592966478#step:2:2805
	# even though practically multiple calls to alternative screen buffer will clear the screen, the newline on the initial call is unintuitive — https://github.com/bevry/dorothy/actions/runs/11358588333/job/31593337760#step:2:2439 — so only do the newline
	style__alternative_screen_buffer="$style__clear_screen"
	style__default_screen_buffer=$'\n'"$style__clear_screen"
	# ensure clears are also moved to next line: https://github.com/bevry/dorothy/actions/runs/11358588333/job/31593337760#step:2:2449
	style__clear_screen=$'\n'"$style__clear_screen"
fi

style__ellipsis='…'
style__bell=$'\a'
style__newline=$'\n'
style__tab=$'\t'
style__space=' '   # for testing
style__all=$'\001' # for testing
style__backspace=$'\b'
style__carriage_return=$'\r'
style__escape=$'\e'
style__home=$'\e[H'

# terminal
style__terminal_title=$'\e]0;'
style__end__terminal_title=$'\a'

# echo-style --terminal-resize='100;80' # height and width
# echo-style --terminal-resize='100;'   # width only
# echo-style --terminal-resize=';80'    # width only
style__terminal_resize=$'\e[8;'
style__end__terminal_resize='t'

# echo-style --base64+terminal-clipboard='Hello World' # not yet implemented, but would be great, have a base64 style function
# echo-style --terminal-clipboard="$(printf '%s' 'Hello World' | base64)"
style__terminal_clipboard=$'\e]52;c;'
style__end__terminal_clipboard=$'\a'

# not yet implemented, add styles for meta keys, such as up, down, enter, escape, etc
# not yet implemented, but would dramatically simplify testing, could be done via a sleep style function
# echo-style --sleep+down --sleep+enter --sleep+escape --sleep+escape --sleep+escape --sleep+enter --sleep+enter | eval-tester ...
# echo-style --sleep+down+sleep+enter+sleep+escape+sleep+escape+sleep+escape+sleep+enter+sleep+enter | eval-tester ...
# echo-style --pre-print-delay=$delay --down --enter --escape --escape --escape --enter --enter | eval-tester ...
# echo-style --pre-print-delay=$delay --down+enter+escape+escape+escape+enter+enter | eval-tester ...

# modes
style__color_end__intensity=$'\e[22m'  #
style__color_end__foreground=$'\e[39m' #
style__color_end__background=$'\e[49m' #
# echo-style 'standard' --bold='bold' --dim='dim' --italic='italic' --underline='underline' --blink='blink' --invert='invert' --conceal='conceal' --strike='strike' --framed='framed' --circled='circled' --overlined='overlined'
style__color__reset=$'\e[0m' # tput sgr0
style__color__bold=$'\e[1m'  # tput bold [supported: Terminal, VSCode, Ghostty, Alacritty, Hyper, Wave, Warp, iTerm2, Tabby, Kitty] [buggy support: Rio] [unsupported: cool-retro-term, Wez, Extratern, Contour]
style__color_end__bold="$style__color_end__intensity"
style__color__dim=$'\e[2m' # tput dim [supported: Terminal, VSCode, Ghostty, Alacritty, Hyper, Wave, Warp, iTerm2, Tabby, Wez, Contour, Kitty] [unsupported: cool-retro-term, Extraterm, Rio]
style__color_end__dim="$style__color_end__intensity"
style__color__italic=$'\e[3m' # [supported: VScode, Hyper, Terminal] [colored support: Ghostty, Alacritty, Wave, iTerm2, Tabby, Wez, Extraterm, Contour, Kitty] [unsupported: Warp, cool-retro-term, Rio] - note that Monaspace fonts may appear to having working italic in macOS Terminal, however that is because it by default chooses italic for the generic style so everything is italic
style__color_end__italic=$'\e[23m'
style__color__underline=$'\e[4m' # tput sgr 0 1 [supported: Terminal, VSCode,Ghostty,  Alacritty, Hyper, cool-retro-term, Wave, Warp, iTerm2, Tabby, Wez, Extraterm, Rio, Contour, Kitty] [unsupported: -]
style__color_end__underline=$'\e[24m'
style__color__double_underline=$'\e[21m' # [supported: Tabby]
style__color_end__double_underline=$'\e[24m'
style__color__blink=$'\e[5m' # tput blink [supported: Terminal, VSCode, Alacritty, Hyper, Contour] [fade-in-out support: Wez, cool-retro-term] [unsupported: Ghostty, Wave, Warp, iTerm2, Tabby, Extraterm, Rio, Kitty]
style__color_end__blink=$'\e[25m'
style__color__invert=$'\e[7m' # tput rev [supported: Terminal, VSCode, Ghostty, Alacritty, Hyper, cool-retro-arm, Wave, Warp, iTerm2, Tabby, Wez, Extraterm, Rio, Contour, Kitty] [unsupported: -]
style__color_end__invert=$'\e[27m'
style__color__conceal=$'\e[8m' # [supported: Terminal, VSCode, Ghostty, Alacritty, Hyper, iTerm2, Tabby, Wez, Rio, Contour] [unsupported: cool-retro-term, Wave, Warp, Extraterm, Kitty]
style__color_end__conceal=$'\e[28m'
style__color__strike=$'\e[9m' # [supported: VSCode, Ghostty, Alacritty, Hyper, Wave, Warp, iTerm2, Tabby, Wez, Extraterm, Rio, Contour, Kitty] [unsupported: cool-retro-term]
style__color_end__strike=$'\e[29m'
style__color__framed=$'\e[51m' # [frames each character: Contour] [unsupported: everything else]
style__color_end__framed=$'\e[54m'
style__color__circled=$'\e[52m' # [supported: none known]
style__color_end__circled="$style__color_end__framed"
style__color__overlined=$'\e[53m' # [supported: Ghostty, Tabby, Wez, Extratern, Contour] [unsupported: everything else]
style__color_end__overlined=$'\e[55m'

# foreground
style__color__foreground_black=$'\e[30m' # tput setaf 0
style__color_end__foreground_black="$style__color_end__foreground"
style__color__foreground_red=$'\e[31m' # tput setaf 1
style__color_end__foreground_red="$style__color_end__foreground"
style__color__foreground_green=$'\e[32m' # tput setaf 2
style__color_end__foreground_green="$style__color_end__foreground"
style__color__foreground_yellow=$'\e[33m' # tput setaf 3
style__color_end__foreground_yellow="$style__color_end__foreground"
style__color__foreground_blue=$'\e[34m' # tput setaf 4
style__color_end__foreground_blue="$style__color_end__foreground"
style__color__foreground_magenta=$'\e[35m' # tput setaf 5
style__color_end__foreground_magenta="$style__color_end__foreground"
style__color__foreground_cyan=$'\e[36m' # tput setaf 6
style__color_end__foreground_cyan="$style__color_end__foreground"
style__color__foreground_white=$'\e[37m' # tput setaf 7
style__color_end__foreground_white="$style__color_end__foreground"
style__color__foreground_purple="$style__color__foreground_magenta"
style__color_end__foreground_purple="$style__color_end__foreground"
style__color__foreground_gray="$style__color__foreground_white"
style__color_end__foreground_gray="$style__color_end__foreground"
style__color__foreground_grey="$style__color__foreground_white"
style__color_end__foreground_grey="$style__color_end__foreground"

# foreground_intense
style__color__foreground_intense_black=$'\e[90m' # tput setaf 8
style__color_end__foreground_intense_black="$style__color_end__foreground"
style__color__foreground_intense_red=$'\e[91m' # tput setaf 9
style__color_end__foreground_intense_red="$style__color_end__foreground"
style__color__foreground_intense_green=$'\e[92m' # tput setaf 10
style__color_end__foreground_intense_green="$style__color_end__foreground"
style__color__foreground_intense_yellow=$'\e[93m' # tput setaf 11
style__color_end__foreground_intense_yellow="$style__color_end__foreground"
style__color__foreground_intense_blue=$'\e[94m' # tput setaf 12
style__color_end__foreground_intense_blue="$style__color_end__foreground"
style__color__foreground_intense_magenta=$'\e[95m' # tput setaf 13
style__color_end__foreground_intense_magenta="$style__color_end__foreground"
style__color__foreground_intense_cyan=$'\e[96m' # tput setaf 14
style__color_end__foreground_intense_cyan="$style__color_end__foreground"
style__color__foreground_intense_white=$'\e[97m' # tput setaf 15
style__color_end__foreground_intense_white="$style__color_end__foreground"
style__color__foreground_intense_purple="$style__color__foreground_intense_magenta"
style__color_end__foreground_intense_purple="$style__color_end__foreground"
style__color__foreground_intense_gray="$style__color__foreground_intense_white"
style__color_end__foreground_intense_gray="$style__color_end__foreground"
style__color__foreground_intense_grey="$style__color__foreground_intense_white"
style__color_end__foreground_intense_grey="$style__color_end__foreground"

# background
style__color__background_black=$'\e[40m' # tput setab 0
style__color_end__background_black="$style__color_end__background"
style__color__background_red=$'\e[41m' # tput setab 1
style__color_end__background_red="$style__color_end__background"
style__color__background_green=$'\e[42m' # tput setab 2
style__color_end__background_green="$style__color_end__background"
style__color__background_yellow=$'\e[43m' # tput setab 3
style__color_end__background_yellow="$style__color_end__background"
style__color__background_blue=$'\e[44m' # tput setab 4
style__color_end__background_blue="$style__color_end__background"
style__color__background_magenta=$'\e[45m' # tput setab 5
style__color_end__background_magenta="$style__color_end__background"
style__color__background_cyan=$'\e[46m' # tput setab 6
style__color_end__background_cyan="$style__color_end__background"
style__color__background_white=$'\e[47m' # tput setab 7
style__color_end__background_white="$style__color_end__background"
style__color__background_purple="$style__color__background_magenta"
style__color_end__background_purple="$style__color_end__background"
style__color__background_gray="$style__color__background_white"
style__color_end__background_gray="$style__color_end__background"
style__color__background_grey="$style__color__background_white"
style__color_end__background_grey="$style__color_end__background"

# background_intense
style__color__background_intense_black=$'\e[100m' # tput setab 8
style__color_end__background_intense_black="$style__color_end__background"
style__color__background_intense_red=$'\e[101m' # tput setab 9
style__color_end__background_intense_red="$style__color_end__background"
style__color__background_intense_green=$'\e[102m' # tput setab 10
style__color_end__background_intense_green="$style__color_end__background"
style__color__background_intense_yellow=$'\e[103m' # tput setab 11
style__color_end__background_intense_yellow="$style__color_end__background"
style__color__background_intense_blue=$'\e[104m' # tput setab 12
style__color_end__background_intense_blue="$style__color_end__background"
style__color__background_intense_magenta=$'\e[105m' # tput setab 13
style__color_end__background_intense_magenta="$style__color_end__background"
style__color__background_intense_cyan=$'\e[106m' # tput setab 14
style__color_end__background_intense_cyan="$style__color_end__background"
style__color__background_intense_white=$'\e[107m' # tput setab 15
style__color_end__background_intense_white="$style__color_end__background"
style__color__background_intense_purple="$style__color__background_intense_magenta"
style__color_end__background_intense_purple="$style__color_end__background"
style__color__background_intense_gray="$style__color__background_intense_white"
style__color_end__background_intense_gray="$style__color_end__background"
style__color__background_intense_grey="$style__color__background_intense_white"
style__color_end__background_intense_grey="$style__color_end__background"

# modes that aren't implemented by operating systems
# blink_fast=$'\e[6m'

#######################################
# CUSTOM STYLES #######################

# styles
style__color__header="${style__color__bold}${style__color__underline}"
style__color_end__header="${style__color_end__intensity}${style__color_end__underline}"
style__color__header1="${style__color__invert}"
style__color_end__header1="${style__color_end__invert}"
style__color__header2="${style__color__bold}${style__color__underline}"
style__color_end__header2="${style__color_end__intensity}${style__color_end__underline}"
style__color__header3="${style__color__bold}"
style__color_end__header3="${style__color_end__intensity}"

style__color__success="${style__color__foreground_green}${style__color__bold}"
style__color_end__success="${style__color_end__foreground}${style__color_end__intensity}"
style__color__positive="${style__color__foreground_green}${style__color__bold}"
style__color_end__positive="${style__color_end__foreground}${style__color_end__intensity}"

style__color__note="${style__color__bold}${style__color__foreground_intense_blue}" # on dark theme, this is your eyes that need help
style__color_end__note="${style__color_end__intensity}${style__color_end__foreground}"

style__color__good1="${style__color__background_intense_green}${style__color__foreground_black}"
style__color_end__good1="${style__color_end__background}${style__color_end__foreground}"
style__color__code_good1="${style__color__background_intense_green}${style__color__foreground_intense_blue}"
style__color_end__code_good1="${style__color_end__background}${style__color_end__foreground}"

style__color__good2="${style__color__bold}${style__color__underline}${style__color__foreground_green}"
style__color_end__good2="${style__color_end__intensity}${style__color_end__underline}${style__color_end__foreground}"
style__color__good3="${style__color__bold}${style__color__foreground_green}"
style__color_end__good3="${style__color_end__intensity}${style__color_end__foreground}"

style__color__negative="${style__color__foreground_red}${style__color__bold}"
style__color_end__negative="${style__color_end__foreground}${style__color_end__intensity}"
style__color__error="${style__color__background_intense_red}${style__color__foreground_intense_white}"
style__color_end__error="${style__color_end__background}${style__color_end__foreground}"

style__color__error1="${style__color__background_red}${style__color__foreground_intense_white}"
style__color_end__error1="${style__color_end__background}${style__color_end__foreground}"
style__color__code_error1="${style__color__background_red}${style__color__foreground_intense_yellow}"
style__color_end__code_error1="${style__color_end__background}${style__color_end__foreground}"

style__color__error2="${style__color__bold}${style__color__underline}${style__color__foreground_red}"
style__color_end__error2="${style__color_end__intensity}${style__color_end__underline}${style__color_end__foreground}"
style__color__error3="${style__color__bold}${style__color__foreground_red}"
style__color_end__error3="${style__color_end__intensity}${style__color_end__foreground}"

style__color__notice="${style__color__bold}${style__color__underline}${style__color__foreground_intense_yellow}" # on dark theme, this is your eyes that need help
style__color_end__notice="${style__color_end__intensity}${style__color_end__underline}${style__color_end__foreground}"
style__color__warning="${style__color__bold}${style__color__underline}${style__color__foreground_yellow}"
style__color_end__warning="${style__color_end__intensity}${style__color_end__underline}${style__color_end__foreground}"
style__color__info="${style__color__bold}${style__color__underline}${style__color__foreground_intense_blue}" # on dark theme, this is your eyes that need help
style__color_end__info="${style__color_end__intensity}${style__color_end__underline}${style__color_end__foreground}"

style__color__notice1="${style__color__background_intense_yellow}${style__color__foreground_black}"
style__color_end__notice1="${style__color_end__background}${style__color_end__foreground}"
style__color__code_notice1="${style__color__background_intense_yellow}${style__color__foreground_blue}"
style__color_end__code_notice1="${style__color_end__background}${style__color_end__foreground}"

style__color__notice2="${style__color__bold}${style__color__underline}${style__color__foreground_yellow}"
style__color_end__notice2="${style__color_end__intensity}${style__color_end__underline}${style__color_end__foreground}"
style__color__notice3="${style__color__bold}${style__color__foreground_yellow}"
style__color_end__notice3="${style__color_end__intensity}${style__color_end__foreground}"

style__color__info1="${style__color__background_blue}${style__color__foreground_intense_white}"
style__color_end__info1="${style__color_end__background}${style__color_end__foreground}"
style__color__code_info1="${style__color__background_blue}${style__color__foreground_intense_green}"
style__color_end__code_info1="${style__color_end__background}${style__color_end__foreground}"

style__color__info2="${style__color__bold}${style__color__underline}${style__color__foreground_blue}"
style__color_end__info2="${style__color_end__intensity}${style__color_end__underline}${style__color_end__foreground}"
style__color__info3="${style__color__bold}${style__color__foreground_blue}"
style__color_end__info3="${style__color_end__intensity}${style__color_end__foreground}"

style__color__redacted="${style__color__background_black}${style__color__foreground_black}" # alternative to conceal, which respects color themes
style__color_end__redacted="${style__color_end__background}${style__color_end__foreground}"
style__color__elevate="${style__color__foreground_intense_yellow}"
style__color_end__elevate="${style__color_end__foreground}"
style__color__code="${style__color__foreground_intense_black}"
style__color_end__code="${style__color_end__foreground}"
style__color__link="${style__color__foreground_blue}"
style__color_end__link="${style__color_end__foreground}"
style__color__path="${style__color__foreground_yellow}"
style__color_end__path="${style__color_end__foreground}"
# do not add a code-notice style that is just yellow text, as it is not better than just a standard code style as it doesn't distinguish itself enough, instead do a notice1 and code-notice1 style
if [[ -n $GITHUB_ACTIONS ]]; then
	style__color__header1="${style__color__background_intense_white}${style__color__foreground_black}"
	style__color_end__header1="${style__color_end__background}${style__color_end__foreground}"
	style__color__error1="${style__color__background_red}${style__color__foreground_black}"
	style__color_end__error1="${style__color_end__background}${style__color_end__foreground}"
	style__color__error="${style__color__background_red}${style__color__foreground_black}"
	style__color_end__error="${style__color_end__background}${style__color_end__foreground}"
elif [[ $THEME == 'light' ]]; then
	# trim style__color__foreground_intense_yellow as it is unreadable on light theme
	style__color__notice="${style__color__bold}${style__color__underline}${style__color__foreground_yellow}"
	style__color_end__notice="${style__color_end__intensity}${style__color_end__underline}${style__color_end__foreground}"
	style__color__elevate="${style__color__foreground_yellow}"
	style__color_end__elevate="${style__color_end__foreground}"

	# If italics is not supported, swap it with something else...
	# Values of TERM_PROGRAM that are known to not support italics:
	# - Apple_Terminal
	# As italics support is rare, do the swap if not in a known terminal that supports italics....
	if [[ $ITALICS_SUPPORTED == 'no' ]]; then
		# do not use underline, as it makes a mess, an underlined | or , or space is not pretty
		# style__color__italic="$style__color__dim"
		# style__color_end__italic="$style__color_end__dim"
		style__color__italic="$style__color__foreground_intense_black"
		style__color_end__italic="$style__color_end__foreground"
	fi
else
	# on dark theme on vscode
	# style__color__background_intense_red forces black foreground, which black on red is unreadable, so adjust
	if [[ $TERM_PROGRAM == vscode ]]; then
		style__color__error="${style__color__background_red}${style__color__foreground_intense_white}"
		style__color_end__error="${style__color_end__background}${style__color_end__foreground}"
	fi

	# If italics is not supported, swap it with something else...
	# Values of TERM_PROGRAM that are known to not support italics:
	# - Apple_Terminal
	# As italics support is rare, do the swap if not in a known terminal that supports italics....
	if [[ $ITALICS_SUPPORTED == 'no' ]]; then
		# do not use underline, as it makes a mess, an underlined | or , or space is not pretty
		# style__color__italic="$style__color__dim"
		# style__color_end__italic="$style__color_end__dim"
		style__color__italic="$style__color__foreground_intense_white"
		style__color_end__italic="$style__color_end__foreground"
	fi
fi

# aliases
style__color__sudo="$style__color__elevate"
style__color_end__sudo="$style__color_end__elevate"

# don't use these in segments, as it prohibits alternative usage
# instead, when things take a long time,
# output a long time message after the segment
# ⏲
# ✅
# ❌

# useful symbols:
# ⁇	⁈ ⁉ ‼ ‽ ℹ ⓘ ¡ ¿ ⚠
# ⏰ ⏱ ⏲ ⏳
# ⎷ ☐ ☑ ☉ ☒ ⚀ ☓ ⛌ ⛝
# ☹ ☺ ☻ ☝ ☞ ☟ ☠ ☢ ☣ ☮
# ⚠️ 🛑 ⛔ ✅ ✊ ✋ 👍 🏆 ❌ ❓ ❔ ❕ ❗
# ✓ ✔ ✕ ✖ ✗ ✘ ★ ☆
# ❢ ❣ ♡ ❤ ❥ ♥
style__icon_good='☺'
style__icon_error='!'

# level 1 wrappers
# hN = header level N
# gN = good level N (use to close a header element)
# eN = error level N (use to close a header element)
# nN = notice level N (use to close a header element)
style__nocolor__h1=$'\n┌  '
style__nocolor_end__h1='  ┐'
style__color__h1=$'\n'"${style__color__header1}┌  "
style__color_end__h1="  ┐${style__color_end__header1}"

style__nocolor__g1="└${style__icon_good} "
style__nocolor_end__g1=" ${style__icon_good}┘"
style__color__g1="${style__color__good1}└  "
style__color_end__g1="  ┘${style__color_end__good1}"

style__nocolor__e1="└${style__icon_error} "
style__nocolor_end__e1=" ${style__icon_error}┘"
style__color__e1="${style__color__error1}└  "
style__color_end__e1="  ┘${style__color_end__error1}"

style__nocolor__n1='└  '
style__nocolor_end__n1='  ┘'
style__color__n1="${style__color__notice1}└  "
style__color_end__n1="  ┘${style__color_end__notice1}"

# level 2 wrappers
style__nocolor__h2='┌  '
style__nocolor_end__h2='  ┐'
style__color__h2="${style__color__reset}${style__color__bold}┌  "
style__color_end__h2="  ┐${style__color__reset}"
# style__color__h2="${style__color__reset}┌  ${style__color__invert}"
# style__color_end__h2="${style__color_end__invert}  ┐${style__color__reset}"

style__nocolor__g2="└${style__icon_good} "
style__nocolor_end__g2=" ${style__icon_good}┘"
style__color__g2="${style__color__reset}${style__color__bold}${style__color__foreground_green}└  "
style__color_end__g2="  ┘${style__color__reset}"

style__nocolor__e2="└${style__icon_error} "
style__nocolor_end__e2=" ${style__icon_error}┘"
style__color__e2="${style__color__reset}${style__color__bold}${style__color__foreground_red}└  "
style__color_end__e2="  ┘${style__color__reset}"

style__nocolor__n2='└  '
style__nocolor_end__n2='  ┘'
style__color__n2="${style__color__reset}${style__color__bold}${style__color__foreground_yellow}└  "
style__color_end__n2="  ┘${style__color__reset}"

# level 3 wrappers
style__nocolor__h3='┌  '
style__nocolor_end__h3='  ┐'
style__color__h3="${style__color__reset}┌  "
style__color_end__h3="  ┐${style__color__reset}"

style__nocolor__g3="└${style__icon_good} "
style__nocolor_end__g3=" ${style__icon_good}┘"
style__color__g3="${style__color__reset}${style__color__foreground_green}└  "
style__color_end__g3="  ┘${style__color__reset}"

style__nocolor__e3="└${style__icon_error} "
style__nocolor_end__e3=" ${style__icon_error}┘"
style__color__e3="${style__color__reset}${style__color__foreground_red}└  "
style__color_end__e3="  ┘${style__color__reset}"

style__nocolor__n3='└  '
style__nocolor_end__n3='  ┘'
style__color__n3="${style__color__reset}${style__color__foreground_yellow}└  "
style__color_end__n3="  ┘${style__color__reset}"

# element
style__nocolor__element='< '
style__nocolor_end__element=' >'
style__color__element="${style__color__dim}${style__color__bold}< ${style__color_end__intensity}"
style__color_end__element="${style__color__dim}${style__color__bold} >${style__color_end__intensity}"

style__nocolor__slash_element='</ '
style__nocolor_end__slash_element=' >'
style__color__slash_element="${style__color__dim}${style__color__bold}</ ${style__color_end__intensity}"
style__color_end__slash_element="${style__color__dim}${style__color__bold} >${style__color_end__intensity}"

style__nocolor__element_slash='< '
style__nocolor_end__element_slash=' />'
style__color__element_slash="${style__color__dim}${style__color__bold}< ${style__color_end__intensity}"
style__color_end__element_slash="${style__color__dim}${style__color__bold} />${style__color_end__intensity}"

# fragment
style__nocolor__fragment='<>'
style__color__fragment="${style__color__dim}${style__color__bold}<>${style__color_end__intensity}"

style__nocolor__slash_fragment='</>'
style__color__slash_fragment="${style__color__dim}${style__color__bold}</>${style__color_end__intensity}"

# the style__color__resets allow these to work:
# echo-style --h1_begin --h1='Setup Python' --h1_end $'\n' --g1_begin --g1='Setup Python' --g1_end
# echo-style --element_slash_begin --h3="this should not be dim" --element_slash_end "$status"
# echo-style a --h1 --element c --red=d e

# choose
# one hollow circle: ⚬ ○ ◯ ❍
# two hollow circles: ◎ ⦾ ⊚
# one hollow, one full: ☉ ⦿ ◉
# one full: ●
# ▣ ▢ □ ⊡
# ☑ ☒ ⌧
# ✓ ✔ ✖  ✗  ✘
#
# conclusions for cursor:
# doesn't space correctly in Terminal: ⸻
# too small: → ☞ ➡
# too unclear: ►
# gets turned into an emoji: ➡️
# other options: ▶▷▸▹⏵⯈, '▶  ', ' ⏵  ', '‒⏵  ', '‒▶  '

# [ 5 above: 1 selected, 3 preferences]
# ...  5 above: 1 selected, 3 preferences ...
# └┘┌┐  5 above: 1 selected, 3 preferences ...
# └  5 above, 1 selected, 3 preferences ┘
# ┌  5 above | 1 selected | 3 preferences ┐
# …
# [ no above ]
###
# ┌ BELOW: 376 below ∙ 45 selected ∙ 8 unselected defaults ┐
# ..
# ├ ABOVE: 5 items ∙ 22 selected ┤
# ├ SHOWN: 30 items ∙ 24 selected ∙ 8 unselected defaults ┤
# ...
# ├ BELOW: 283 items ┤
# ...
# └ ABOVE: 376 below ∙ 45 selected ∙ 8 unselected defaults ┘
# ⏺ = too big
# ∶
# ⌜	⌝	⌞	⌟
# ⌌	⌍	⌎	⌏
# ╭	╮	╯ ╰

# confirm/choose/ask questions
style__color__question_title_prompt="${style__color__bold}${style__color__underline}"
style__color_end__question_title_prompt="${style__color_end__bold}${style__color_end__underline}"

style__color__question_title_result="${style__color__bold}"
style__color_end__question_title_result="${style__color_end__bold}"

style__color__question_body="${style__color__dim}"
style__color_end__question_body="${style__color_end__dim}"

# ask icons
style__icon_prompt='> '

# for input result indentation, it doesn't sense:
# https://en.wikipedia.org/wiki/List_of_Unicode_characters#Box_Drawing
# │ seamless, but too much of a gap on the left. cam look like an I if only single line result
# ┃ seamless, good option
# ║ seamless, confusing
# ▏ not seamless, but better spacing on the left
# not seamless on macos terminal with varying fonts: ┊ ┆ ╎ ╏ ▏ █
# > looks like an input
# after a lot of experimentation, it does not make sense to prefix it: https://gist.github.com/balupton/5160f1ee8581ffe9d1d67963824f86d0

# lines
style__icon_multi_selected='▣ '
style__icon_multi_default='⊡ '
style__icon_multi_active='⊡ '
style__icon_multi_standard='□ '
style__icon_single_selected='⦿ ' # only used in confirmation and linger
style__icon_single_default='⦾ '
style__icon_single_active_required='◉ '
style__icon_single_active_optional='⦿ '
style__icon_single_standard='○ '
style__color__result_line="$style__color__dim"
style__color_end__result_line="$style__color_end__intensity"
style__color__active_line="$style__color__invert"
style__color_end__active_line="$style__color_end__invert"
style__color__selected_line="$style__color__foreground_intense_green"
style__color_end__selected_line="$style__color_end__foreground"
style__color__default_line="$style__color__foreground_intense_yellow"
style__color_end__default_line="$style__color_end__foreground"
style__color__empty_line="${style__color__foreground_magenta}${style__color__background_intense_white}" # this is inverted
style__color_end__empty_line="${style__color_end__foreground}${style__color_end__background}"
style__color__inactive_line=''
style__color_end__inactive_line=''

# notice and warning too much emphasis on something with fallback
# confirm/choose/ask failures
style__color__input_warning="${style__color__bold}${style__color__foreground_yellow}"
style__color_end__input_warning="${style__color_end__bold}${style__color_end__foreground_yellow}"
style__color__input_error="${style__color__error1}"
style__color_end__input_error="${style__color_end__error1}"

# confirm/choose/ask/debugging text
style__commentary='[ '
style__commentary_end=' ]'
style__icon_nothing_provided="${style__commentary}nothing provided${style__commentary_end}"
style__icon_undeclared="${style__commentary}undeclared${style__commentary_end}"
style__icon_undefined="${style__commentary}undefined${style__commentary_end}"
style__icon_empty="${style__commentary}empty${style__commentary_end}"
style__icon_no_selection="${style__commentary}no selection${style__commentary_end}"
style__icon_nothing_selected="${style__commentary}nothing selected${style__commentary_end}"
style__icon_using_password="${style__commentary}using the entered password${style__commentary_end}"
style__icon_timeout_default="${style__commentary}timed out: used default${style__commentary_end}"
style__icon_timeout_optional="${style__commentary}timed out: not required${style__commentary_end}"
style__icon_timeout_required="${style__commentary}input failure: timed out: required${style__commentary_end}"
style__icon_input_failure="${style__commentary}input failure: %s${style__commentary_end}"
style__nocolor__commentary_nothing_provided="${style__icon_nothing_provided}"
style__nocolor__commentary_undeclared="${style__icon_undeclared}"
style__nocolor__commentary_undefined="${style__icon_undefined}"
style__nocolor__commentary_empty="${style__icon_empty}"
style__nocolor__commentary_no_selection="${style__icon_no_selection}"
style__nocolor__commentary_nothing_selected="${style__icon_nothing_selected}"
style__nocolor__commentary_using_password="${style__icon_using_password}"
style__nocolor__commentary_timeout_default="${style__icon_timeout_default}"
style__nocolor__commentary_timeout_optional="${style__icon_timeout_optional}"
style__nocolor__commentary_timeout_required="${style__icon_timeout_required}"
style__nocolor__commentary_input_failure="${style__icon_input_failure}"
style__color__commentary_nothing_provided="${style__color__empty_line}${style__icon_nothing_provided}${style__color_end__empty_line}"
style__color__commentary_undeclared="${style__color__empty_line}${style__icon_undeclared}${style__color_end__empty_line}"
style__color__commentary_undefined="${style__color__empty_line}${style__icon_undefined}${style__color_end__empty_line}"
style__color__commentary_empty="${style__color__empty_line}${style__icon_empty}${style__color_end__empty_line}"
style__color__commentary_no_selection="${style__color__empty_line}${style__icon_no_selection}${style__color_end__empty_line}"
style__color__commentary_nothing_selected="${style__color__empty_line}${style__icon_nothing_selected}${style__color_end__empty_line}"
style__color__commentary_using_password="${style__color__empty_line}${style__icon_using_password}${style__color_end__empty_line}"
style__color__commentary_timeout_default="${style__color__input_warning}${style__icon_timeout_default}${style__color_end__input_warning}"
style__color__commentary_timeout_optional="${style__color__input_warning}${style__icon_timeout_optional}${style__color_end__input_warning}"
style__color__commentary_timeout_required="${style__color__input_error}${style__icon_timeout_required}${style__color_end__input_error}"
style__color__commentary_input_failure="${style__color__input_error}${style__icon_input_failure}${style__color_end__input_error}"

# spacers
style__result_commentary_spacer=' '
style__legend_legend_spacer='  '
style__legend_key_spacer=' '
style__key_key_spacer=' '
style__indent_bar='   '
style__indent_active='⏵  '
style__indent_inactive='   '
style__indent_blockquote='│ '

# style__count_spacer=' ∙ '
style__nocolor__count_spacer=' ∙ '
style__color__count_spacer=" ${style__color__foreground_intense_black}∙${style__color_end__foreground} "

style__color_end__legend="$style__color_end__intensity"
style__color__key="${style__color__foreground_black}${style__color__background_white} "
style__color_end__key=" ${style__color_end__foreground}${style__color_end__background}"
style__color__key_active="${style__color__foreground_black}${style__color__background_intense_white} "
style__color_end__key_active=" ${style__color_end__foreground}${style__color_end__background}"
style__nocolor__key='['
style__nocolor_end__key=']'
style__nocolor__key_active='['
style__nocolor_end__key_active=']'

# paging counts
# style__count_more=''
style__color__count_more="$style__color__dim"
style__color_end__count_more="$style__color_end__dim"
style__color__count_selected="$style__color__foreground_green"
style__color_end__count_selected="$style__color_end__foreground"
style__color__count_defaults="$style__color__foreground_yellow"
style__color_end__count_defaults="$style__color_end__foreground"
style__color__count_empty="$style__color__foreground_magenta"
style__color_end__count_empty="$style__color_end__foreground"

# paging headers
# style__bar_top='┌ '
# style__end__bar_top=' ┐'
# style__bar_middle='├ '
# style__end__bar_middle=' ┤'
# style__bar_bottom='└ '
# style__end__bar_bottom=' ┘'
# style__bar_line='│ '
style__nocolor__bar_top='┌ '
style__nocolor_end__bar_top=' ┐'
style__nocolor__bar_middle='├ '
style__nocolor_end__bar_middle=' ┤'
style__nocolor__bar_bottom='└ '
style__nocolor_end__bar_bottom=' ┘'
style__nocolor__bar_line='│ '
style__color__bar_top="${style__color__dim}┌${style__color_end__dim} "
style__color_end__bar_top=" ${style__color__dim}┐${style__color_end__dim}"
style__color__bar_middle="${style__color__dim}├${style__color_end__dim} "
style__color_end__bar_middle=" ${style__color__dim}┤${style__color_end__dim}"
style__color__bar_bottom="${style__color__dim}└${style__color_end__dim} "
style__color_end__bar_bottom=" ${style__color__dim}┘${style__color_end__dim}"
style__color__bar_line="${style__color__dim}│${style__color_end__dim} "

# if confirm appears dim, it is because your terminal theme has changed and you haven't opened a new terminal tab

# ${style__color__background_intense_white}: ⏴⏵
# confirm color
style__color__confirm_positive_active="${style__color__bold}${style__color__invert}${style__color__foreground_green}⏵YES${style__color_end__underline}  ${style__color_end__invert}${style__color_end__bold}${style__color__key_active} Y ${style__color_end__key_active}"
style__color__confirm_negative_active="${style__color__bold}${style__color__invert}${style__color__foreground_red}⏵NO${style__color_end__underline}  ${style__color_end__invert}${style__color_end__bold}${style__color__key_active} N ${style__color_end__key_active}"
style__color__confirm_proceed_active="${style__color__bold}${style__color__invert}${style__color__foreground_green}⏵PROCEED${style__color_end__underline}  ${style__color_end__invert}${style__color_end__bold}${style__color__key_active} ENTER ${style__color_end__key_active} ${style__color__key_active} SPACE ${style__color_end__key_active} ${style__color__key_active} Y ${style__color_end__key_active}"

style__color__confirm_positive_inactive="${style__color__foreground_green} YES  ${style__color__key} Y ${style__color_end__key}"
style__color__confirm_negative_inactive="${style__color__foreground_red} NO  ${style__color__key} N ${style__color_end__key}"
style__color__confirm_abort_inactive="${style__color__foreground_red}${style__color__dim} ABORT  ${style__color__key} ESC ${style__color_end__key}${style__color_end__dim}"

style__color__confirm_positive_result="${style__color__bold}${style__color__invert}${style__color__foreground_green} YES ${style__color_end__foreground}${style__color_end__invert}${style__color_end__bold}"
style__color__confirm_negative_result="${style__color__bold}${style__color__invert}${style__color__foreground_red} NO ${style__color_end__foreground}${style__color_end__invert}${style__color_end__bold}"
style__color__confirm_abort_result="${style__color__bold}${style__color__invert}${style__color__foreground_red} ABORT ${style__color_end__foreground}${style__color_end__invert}${style__color_end__bold}"
style__color__confirm_proceed_result="${style__color__bold}${style__color__invert}${style__color__foreground_green} PROCEED ${style__color_end__foreground}${style__color_end__invert}${style__color_end__bold}"

# confirm nocolor
style__nocolor__confirm_positive_active='*YES* [Y]'
style__nocolor__confirm_negative_active='*NO* [N]'
style__nocolor__confirm_proceed_active='*PROCEED* [ENTER] [SPACE] [Y]'

style__nocolor__confirm_positive_inactive=' YES  [Y]'
style__nocolor__confirm_negative_inactive=' NO  [N]'
style__nocolor__confirm_abort_inactive=' ABORT  [ESC] [Q]'

style__nocolor__confirm_positive_result='[YES]'
style__nocolor__confirm_negative_result='[NO]'
style__nocolor__confirm_abort_result='[ABORT]'
style__nocolor__confirm_proceed_result='[PROCEED]'

# adjustments
if [[ $THEME == 'light' ]]; then
	# keys
	style__color__legend="$style__color__foreground_intense_black"
	style__color_end__legend="$style__color_end__foreground"
	style__color__key="$style__color__background_intense_white "
	style__color_end__key=" $style__color_end__background"
	# lines
	style__color__selected_line="$style__color__foreground_green"
	style__color_end__selected_line="$style__color_end__foreground"
	style__color__default_line="$style__color__foreground_yellow"
	style__color_end__default_line="$style__color_end__foreground"
fi

# helpers
function refresh_style_cache {
	# this should be similar to append_style in echo-style
	# side effect: USE_COLOR
	local item use_color=''
	while [[ $# -ne 0 ]]; do
		item="$1"
		shift
		case "$item" in
		--color=yes | --color) use_color='yes' ;;
		--color=no | --nocolor) use_color='no' ;;
		--) break ;;
		esac
	done
	if [[ -z $use_color ]]; then
		if [[ -n ${USE_COLOR-} ]]; then
			use_color="$USE_COLOR"
		elif get-terminal-color-support --quiet --fallback=yes; then
			USE_COLOR='yes'
			use_color='yes'
		else
			USE_COLOR='no'
			use_color='no'
		fi
	fi
	local style var
	for style in "$@"; do
		found='no'
		if [[ $use_color == 'yes' ]]; then
			# begin
			var="style__color__${style}"
			if __is_var_defined "$var"; then
				eval "style__${style}=\"\${!var}\""
				found='yes'
			else
				var="style__${style}"
				if __is_var_defined "$var"; then
					# no need to update it
					found='yes'
				else
					var="style__nocolor__${style}"
					eval "style__${style}=''" # set to nothing regardless
					if __is_var_defined "$var"; then
						found='yes'
					fi
				fi
			fi

			# end
			var="style__color_end__${style}"
			if __is_var_defined "$var"; then
				eval "style__end__${style}=\"\${!var}\""
				found='yes'
			else
				var="style__end__${style}"
				if __is_var_defined "$var"; then
					# no need to update it
					found='yes'
				else
					var="style__nocolor_end__${style}"
					eval "style__end__${style}=''" # set to nothing regardless
					if __is_var_defined "$var"; then
						found='yes'
					fi
				fi
			fi
		else
			# begin
			var="style__nocolor__${style}"
			if __is_var_defined "$var"; then
				eval "style__${style}=\"\${!var}\""
				found='yes'
			else
				var="style__${style}"
				if __is_var_defined "$var"; then
					# no need to update it
					found='yes'
				else
					var="style__color__${style}"
					eval "style__${style}=''" # set to nothing regardless
					if __is_var_defined "$var"; then
						found='yes'
					fi
				fi
			fi

			# end
			var="style__nocolor_end__${style}"
			if __is_var_defined "$var"; then
				eval "style__end__${style}=\"\${!var}\""
				found='yes'
			else
				var="style__end__${style}"
				if __is_var_defined "$var"; then
					# no need to update it
					found='yes'
				else
					var="style__color_end__${style}"
					eval "style__end__${style}=''" # set to nothing regardless
					if __is_var_defined "$var"; then
						found='yes'
					fi
				fi
			fi
		fi
		# only respect found on versions of bash that can detect accurately detect it, as otherwise empty values will be confused as not found
		if [[ $found == 'no' && $IS_BASH_VERSION_OUTDATED == 'no' ]]; then
			echo-error "Style not found: $style"
			return 1
		fi
	done
}

# restore tracing
# shared by `bash.bash` `styles.bash`
if [[ -n ${BASH_X-} ]]; then
	unset BASH_X
	set -x
fi
if [[ -n ${BASH_V-} ]]; then
	unset BASH_V
	set -v
fi
