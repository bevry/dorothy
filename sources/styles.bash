#!/usr/bin/env bash
# shellcheck disable=SC2034
# Used by `echo-style`, `ask`, `choose`, `confirm`

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
# CAPABILITY DETECTION ################

export THEME COLOR
GITHUB_ACTIONS="${GITHUB_ACTIONS-}"
THEME="${THEME-}" # (get-terminal-theme || :)"
COLOR="${COLOR-}"
TERM_PROGRAM="${TERM_PROGRAM-}"
if [[ $TERM_PROGRAM =~ ^(Hyper|tmux|vscode)$ ]]; then
	ITALICS_SUPPORTED='yes'
else
	ITALICS_SUPPORTED='no'
fi

# ensures COLOR is correct when applicable
function __get_terminal_color_support {
	# arguments
	local GET_TERMINAL_COLOR_SUPPORT__item GET_TERMINAL_COLOR_SUPPORT__fallback='' GET_TERMINAL_COLOR_SUPPORT__quiet='' GET_TERMINAL_COLOR_SUPPORT__color='' # option_env='yes'
	while [[ $# -ne 0 ]]; do
		GET_TERMINAL_COLOR_SUPPORT__item="$1"
		shift
		case "$GET_TERMINAL_COLOR_SUPPORT__item" in
		--fallback=*) GET_TERMINAL_COLOR_SUPPORT__fallback="${GET_TERMINAL_COLOR_SUPPORT__item#*=}" ;;
		--no-verbose* | --verbose*) __flag --source={GET_TERMINAL_COLOR_SUPPORT__item} --target={GET_TERMINAL_COLOR_SUPPORT__quiet} --non-affirmative --coerce || return $? ;;
		--no-quiet* | --quiet*) __flag --source={GET_TERMINAL_COLOR_SUPPORT__item} --target={GET_TERMINAL_COLOR_SUPPORT__quiet} --affirmative --coerce || return $? ;;
		# --no-env* | --env*) __flag --source={GET_TERMINAL_COLOR_SUPPORT__item} --target={option_env} --affirmative ;;
		--)
			# now that we have the forwarded arguments, see if anything matches color
			while [[ $# -ne 0 ]]; do
				GET_TERMINAL_COLOR_SUPPORT__item="$1"
				shift
				case "$GET_TERMINAL_COLOR_SUPPORT__item" in
				--no-color* | --color*) __flag --source={GET_TERMINAL_COLOR_SUPPORT__item} --target={GET_TERMINAL_COLOR_SUPPORT__color} --affirmative --coerce || return $? ;;
				esac
			done
			break
			;;
		--*) __unrecognised_flag "$GET_TERMINAL_COLOR_SUPPORT__item" || return $? ;;
		*)
			if [[ -z $GET_TERMINAL_COLOR_SUPPORT__fallback ]]; then
				GET_TERMINAL_COLOR_SUPPORT__fallback="$GET_TERMINAL_COLOR_SUPPORT__item"
			else
				__unrecognised_argument "$GET_TERMINAL_COLOR_SUPPORT__item" || return $?
			fi
			;;
		esac
	done

	# handle status
	local -i GET_TERMINAL_COLOR_SUPPORT__status=0
	local GET_TERMINAL_COLOR_SUPPORT__exit_result='' GET_TERMINAL_COLOR_SUPPORT__exit_status='' GET_TERMINAL_COLOR_SUPPORT__error_status=''
	if [[ $GET_TERMINAL_COLOR_SUPPORT__quiet == 'yes' ]]; then
		# quiet
		function __process_status {
			if [[ $GET_TERMINAL_COLOR_SUPPORT__status -eq 0 || $GET_TERMINAL_COLOR_SUPPORT__status -eq 1 ]]; then
				GET_TERMINAL_COLOR_SUPPORT__exit_status="$GET_TERMINAL_COLOR_SUPPORT__status"
				# don't output anything as quiet
				# but keep the status as that is how quiet determines the result
			fi
		}
	else
		# verbose, output instead
		function __process_status {
			if [[ $GET_TERMINAL_COLOR_SUPPORT__status -eq 0 ]]; then
				GET_TERMINAL_COLOR_SUPPORT__exit_status=0
				GET_TERMINAL_COLOR_SUPPORT__exit_result='yes'
				__print_lines "$GET_TERMINAL_COLOR_SUPPORT__exit_result" || return $?
			elif [[ $GET_TERMINAL_COLOR_SUPPORT__status -eq 1 ]]; then
				GET_TERMINAL_COLOR_SUPPORT__exit_status=0 # as we are not quiet, we determine the result via the output
				GET_TERMINAL_COLOR_SUPPORT__exit_result='no'
				__print_lines "$GET_TERMINAL_COLOR_SUPPORT__exit_result" || return $?
			else
				GET_TERMINAL_COLOR_SUPPORT__error_status="$GET_TERMINAL_COLOR_SUPPORT__status" # not this failure if all other fallbacks failed or are not present
			fi
		}
	fi

	# process arguments against env
	if [[ -n $GET_TERMINAL_COLOR_SUPPORT__color ]]; then
		GET_TERMINAL_COLOR_SUPPORT__status=0
		__is_affirmative -- "$GET_TERMINAL_COLOR_SUPPORT__color" || GET_TERMINAL_COLOR_SUPPORT__status=$?
		__process_status || return $?
		if [[ -n $GET_TERMINAL_COLOR_SUPPORT__exit_status ]]; then
			# don't modify COLOR, as this is just argument handling, not env
			return "$GET_TERMINAL_COLOR_SUPPORT__exit_status"
		fi
	fi
	if [[ -n ${COLOR-} ]]; then
		GET_TERMINAL_COLOR_SUPPORT__status=0
		__is_affirmative -- "$COLOR" || GET_TERMINAL_COLOR_SUPPORT__status=$?
		__process_status || return $?
		if [[ -n $GET_TERMINAL_COLOR_SUPPORT__exit_status ]]; then
			COLOR="$GET_TERMINAL_COLOR_SUPPORT__exit_result"
			return "$GET_TERMINAL_COLOR_SUPPORT__exit_status"
		fi
	fi
	if [[ -n ${NO_COLOR-} ]]; then
		GET_TERMINAL_COLOR_SUPPORT__status=0
		__is_non_affirmative -- "$NO_COLOR" || GET_TERMINAL_COLOR_SUPPORT__status=$?
		__process_status || return $?
		if [[ -n $GET_TERMINAL_COLOR_SUPPORT__exit_status ]]; then
			COLOR="$GET_TERMINAL_COLOR_SUPPORT__exit_result"
			return "$GET_TERMINAL_COLOR_SUPPORT__exit_status"
		fi
	fi
	if [[ -n ${NOCOLOR-} ]]; then
		GET_TERMINAL_COLOR_SUPPORT__status=0
		__is_non_affirmative -- "$NOCOLOR" || GET_TERMINAL_COLOR_SUPPORT__status=$?
		__process_status || return $?
		if [[ -n $GET_TERMINAL_COLOR_SUPPORT__exit_status ]]; then
			COLOR="$GET_TERMINAL_COLOR_SUPPORT__exit_result"
			return "$GET_TERMINAL_COLOR_SUPPORT__exit_status"
		fi
	fi
	if [[ -n ${CRON-} || -n ${CRONITOR_EXEC-} ]]; then
		# cron strips nearly all env vars, these must be defined manually in [crontab -e]
		GET_TERMINAL_COLOR_SUPPORT__status=1
		__process_status || return $?
		if [[ -n $GET_TERMINAL_COLOR_SUPPORT__exit_status ]]; then
			COLOR="$GET_TERMINAL_COLOR_SUPPORT__exit_result"
			return "$GET_TERMINAL_COLOR_SUPPORT__exit_status"
		fi
	fi
	if [[ -n ${TERM-} ]]; then
		# cron strips TERM, however bash resets it to TERM=dumb
		# https://unix.stackexchange.com/a/411097
		if [[ $TERM == 'xterm-256color' ]]; then
			# Visual Studio Code's integrated terminal reports TERM=xterm-256color
			GET_TERMINAL_COLOR_SUPPORT__status=0
			__process_status || return $?
			if [[ -n $GET_TERMINAL_COLOR_SUPPORT__exit_status ]]; then
				COLOR="$GET_TERMINAL_COLOR_SUPPORT__exit_result"
				return "$GET_TERMINAL_COLOR_SUPPORT__exit_status"
			fi
		elif [[ $TERM == 'dumb' ]]; then
			if [[ -n ${GITHUB_ACTIONS-} ]]; then
				: # continue to fallback
			elif [[ -n $CI ]]; then
				# if there are other CIs that support colors, they should be added to the prior check
				GET_TERMINAL_COLOR_SUPPORT__status=1
				__process_status || return $?
				if [[ -n $GET_TERMINAL_COLOR_SUPPORT__exit_status ]]; then
					COLOR="$GET_TERMINAL_COLOR_SUPPORT__exit_result"
					return "$GET_TERMINAL_COLOR_SUPPORT__exit_status"
				fi
			else
				# [ssh -T ...] would be an example of this
				: # continue to fallback
			fi
		fi
		# continue to fallback
	fi

	# fallback
	if [[ -n $GET_TERMINAL_COLOR_SUPPORT__fallback ]]; then
		GET_TERMINAL_COLOR_SUPPORT__status=0
		__is_affirmative -- "$GET_TERMINAL_COLOR_SUPPORT__fallback" || GET_TERMINAL_COLOR_SUPPORT__status=$?
		__process_status || return $?
		if [[ -n $GET_TERMINAL_COLOR_SUPPORT__exit_status ]]; then
			# don't modify COLOR, as this is just fallback handling, not env
			return "$GET_TERMINAL_COLOR_SUPPORT__exit_status"
		fi
	fi

	# nothing
	GET_TERMINAL_COLOR_SUPPORT__error_status="${GET_TERMINAL_COLOR_SUPPORT__error_status:-"91"}" # ENOMSG 91 No message of desired type
	return "$GET_TERMINAL_COLOR_SUPPORT__error_status"
}

#######################################
# ANSI STYLES #########################

# terminal
STYLE__clear_line=$'\e[G\e[2K'  # move cursor to beginning of current line and erase/clear/overwrite-with-whitespace the line, $'\e[G\e[J' is equivalent
STYLE__delete_line=$'\e[F\e[J'  # move cursor to beginning of the prior line and erase/clear/overwrite-with-whitespace all lines from there
STYLE__clear_screen=$'\e[H\e[J' # # \e[H\e[J moves cursor to the top and erases the screen (so no effect to the scroll buffer), unfortunately \e[2J moves the cursor to the bottom, then prints a screen worth of blank lines, then moves the cursor to the top (keeping what was on the screen in the scroll buffer, padded then by a screen of white space); tldr \e[H\e[J wipes the screen, \e[2J pads the screen
STYLE__enable_cursor_blinking=$'\e[?12h'
STYLE__disable_cursor_blinking=$'\e[?12l'
STYLE__show_cursor=$'\e[?25h'
STYLE__hide_cursor=$'\e[?25l'
STYLE__reset_cursor=$'\e[0 q'
STYLE__cursor_blinking_block=$'\e[1 q'
STYLE__cursor_steady_block=$'\e[2 q'
STYLE__cursor_blinking_underline=$'\e[3 q'
STYLE__cursor_steady_underline=$'\e[4 q'
STYLE__cursor_blinking_bar=$'\e[5 q'
STYLE__cursor_steady_bar=$'\e[6 q'
if [[ $ALTERNATIVE_SCREEN_BUFFER_SUPPORTED == 'yes' ]]; then
	STYLE__alternative_screen_buffer=$'\e[?1049h\e[H\e[J' # switch-to/enable/open alternative screen buffer (of which there is only one), the \e[H is necessary to put the cursor at the top on wsl ubuntu otherwise it stays in the same place, and unfortunately the clear is sometimes necessary for vscode
	STYLE__default_screen_buffer=$'\e[?1049l'             # restore/enable/open/switch-to the default/primary/main/normal screen buffer
else
	# if unable to tap into alternative screen buffer, then output a newline (in case clear screen isn't supported) and clear the screen (which GitHub CI doesn't support, but it does not output the ansi escape code) - without this change, then following output will incorrectly be on the same line as the previous output
	# https://github.com/bevry/dorothy/actions/runs/11358242517/job/31592464176#step:2:3754
	# https://github.com/bevry/dorothy/actions/runs/11358441972/job/31592966478#step:2:2805
	# even though practically multiple calls to alternative screen buffer will clear the screen, the newline on the initial call is unintuitive — https://github.com/bevry/dorothy/actions/runs/11358588333/job/31593337760#step:2:2439 — so only do the newline
	STYLE__alternative_screen_buffer="$STYLE__clear_screen"
	STYLE__default_screen_buffer=$'\n'"$STYLE__clear_screen"
	# ensure clears are also moved to next line: https://github.com/bevry/dorothy/actions/runs/11358588333/job/31593337760#step:2:2449
	STYLE__clear_screen=$'\n'"$STYLE__clear_screen"
fi

STYLE__ellipsis='…'
STYLE__bell=$'\a'
STYLE__newline=$'\n'
STYLE__tab=$'\t'
STYLE__space=' '   # for testing
STYLE__all=$'\001' # for testing
STYLE__backspace=$'\b'
STYLE__carriage_return=$'\r'
STYLE__escape=$'\e'
STYLE__home=$'\e[H'

# terminal
STYLE__terminal_title=$'\e]0;'
STYLE__END__terminal_title=$'\a'

# echo-style --terminal-resize='100;80' # height and width
# echo-style --terminal-resize='100;'   # width only
# echo-style --terminal-resize=';80'    # width only
STYLE__terminal_resize=$'\e[8;'
STYLE__END__terminal_resize='t'

# echo-style --base64+terminal-clipboard='Hello World' # not yet implemented, but would be great, have a base64 style function
# echo-style --terminal-clipboard="$(printf '%s' 'Hello World' | base64)"
STYLE__terminal_clipboard=$'\e]52;c;'
STYLE__END__terminal_clipboard=$'\a'

# not yet implemented, add styles for meta keys, such as up, down, enter, escape, etc
# not yet implemented, but would dramatically simplify testing, could be done via a sleep style function
# echo-style --sleep+down --sleep+enter --sleep+escape --sleep+escape --sleep+escape --sleep+enter --sleep+enter | eval-tester ...
# echo-style --sleep+down+sleep+enter+sleep+escape+sleep+escape+sleep+escape+sleep+enter+sleep+enter | eval-tester ...
# echo-style --pre-print-delay=$delay --down --enter --escape --escape --escape --enter --enter | eval-tester ...
# echo-style --pre-print-delay=$delay --down+enter+escape+escape+escape+enter+enter | eval-tester ...

# modes
STYLE__MULTICOLOR__END__intensity=$'\e[22m'  #
STYLE__MULTICOLOR__END__foreground=$'\e[39m' #
STYLE__MULTICOLOR__END__background=$'\e[49m' #
# echo-style 'standard' --bold='bold' --dim='dim' --italic='italic' --underline='underline' --blink='blink' --invert='invert' --conceal='conceal' --strike='strike' --framed='framed' --circled='circled' --overlined='overlined'
STYLE__MULTICOLOR__reset=$'\e[0m' # tput sgr0
STYLE__MULTICOLOR__bold=$'\e[1m'  # tput bold [supported: Terminal, VSCode, Ghostty, Alacritty, Hyper, Wave, Warp, iTerm2, Tabby, Kitty] [buggy support: Rio] [unsupported: cool-retro-term, Wez, Extratern, Contour]
STYLE__MULTICOLOR__END__bold="$STYLE__MULTICOLOR__END__intensity"
STYLE__MULTICOLOR__dim=$'\e[2m' # tput dim [supported: Terminal, VSCode, Ghostty, Alacritty, Hyper, Wave, Warp, iTerm2, Tabby, Wez, Contour, Kitty] [unsupported: cool-retro-term, Extraterm, Rio]
STYLE__MULTICOLOR__END__dim="$STYLE__MULTICOLOR__END__intensity"
STYLE__MULTICOLOR__italic=$'\e[3m'       # [supported: VScode, Hyper, Terminal] [colored support: Ghostty, Alacritty, Wave, iTerm2, Tabby, Wez, Extraterm, Contour, Kitty] [unsupported: Warp, cool-retro-term, Rio] - note that Monaspace fonts may appear to having working italic in macOS Terminal, however that is because it by default chooses italic for the generic style so everything is italic
STYLE__MULTICOLOR__END__italic=$'\e[23m' # Ghostty will have this also cancel bold/dim.
STYLE__MULTICOLOR__underline=$'\e[4m'    # tput sgr 0 1 [supported: Terminal, VSCode,Ghostty,  Alacritty, Hyper, cool-retro-term, Wave, Warp, iTerm2, Tabby, Wez, Extraterm, Rio, Contour, Kitty] [unsupported: -]
STYLE__MULTICOLOR__END__underline=$'\e[24m'
STYLE__MULTICOLOR__double_underline=$'\e[21m' # [supported: Tabby]
STYLE__MULTICOLOR__END__double_underline=$'\e[24m'
STYLE__MULTICOLOR__blink=$'\e[5m' # tput blink [supported: Terminal, VSCode, Alacritty, Hyper, Contour] [fade-in-out support: Wez, cool-retro-term] [unsupported: Ghostty, Wave, Warp, iTerm2, Tabby, Extraterm, Rio, Kitty]
STYLE__MULTICOLOR__END__blink=$'\e[25m'
STYLE__MULTICOLOR__invert=$'\e[7m' # tput rev [supported: Terminal, VSCode, Ghostty, Alacritty, Hyper, cool-retro-arm, Wave, Warp, iTerm2, Tabby, Wez, Extraterm, Rio, Contour, Kitty] [unsupported: -]
STYLE__MULTICOLOR__END__invert=$'\e[27m'
STYLE__MULTICOLOR__conceal=$'\e[8m' # [supported: Terminal, VSCode, Ghostty, Alacritty, Hyper, iTerm2, Tabby, Wez, Rio, Contour] [unsupported: cool-retro-term, Wave, Warp, Extraterm, Kitty]
STYLE__MULTICOLOR__END__conceal=$'\e[28m'
STYLE__MULTICOLOR__strike=$'\e[9m' # [supported: VSCode, Ghostty, Alacritty, Hyper, Wave, Warp, iTerm2, Tabby, Wez, Extraterm, Rio, Contour, Kitty] [unsupported: cool-retro-term]
STYLE__MULTICOLOR__END__strike=$'\e[29m'
STYLE__MULTICOLOR__framed=$'\e[51m' # [frames each character: Contour] [unsupported: everything else]
STYLE__MULTICOLOR__END__framed=$'\e[54m'
STYLE__MULTICOLOR__circled=$'\e[52m' # [supported: none known]
STYLE__MULTICOLOR__END__circled="$STYLE__MULTICOLOR__END__framed"
STYLE__MULTICOLOR__overlined=$'\e[53m' # [supported: Ghostty, Tabby, Wez, Extratern, Contour] [unsupported: everything else]
STYLE__MULTICOLOR__END__overlined=$'\e[55m'

# foreground
STYLE__MULTICOLOR__foreground_black=$'\e[30m' # tput setaf 0
STYLE__MULTICOLOR__END__foreground_black="$STYLE__MULTICOLOR__END__foreground"
STYLE__MULTICOLOR__foreground_red=$'\e[31m' # tput setaf 1
STYLE__MULTICOLOR__END__foreground_red="$STYLE__MULTICOLOR__END__foreground"
STYLE__MULTICOLOR__foreground_green=$'\e[32m' # tput setaf 2
STYLE__MULTICOLOR__END__foreground_green="$STYLE__MULTICOLOR__END__foreground"
STYLE__MULTICOLOR__foreground_yellow=$'\e[33m' # tput setaf 3
STYLE__MULTICOLOR__END__foreground_yellow="$STYLE__MULTICOLOR__END__foreground"
STYLE__MULTICOLOR__foreground_blue=$'\e[34m' # tput setaf 4
STYLE__MULTICOLOR__END__foreground_blue="$STYLE__MULTICOLOR__END__foreground"
STYLE__MULTICOLOR__foreground_magenta=$'\e[35m' # tput setaf 5
STYLE__MULTICOLOR__END__foreground_magenta="$STYLE__MULTICOLOR__END__foreground"
STYLE__MULTICOLOR__foreground_cyan=$'\e[36m' # tput setaf 6
STYLE__MULTICOLOR__END__foreground_cyan="$STYLE__MULTICOLOR__END__foreground"
STYLE__MULTICOLOR__foreground_white=$'\e[37m' # tput setaf 7
STYLE__MULTICOLOR__END__foreground_white="$STYLE__MULTICOLOR__END__foreground"
STYLE__MULTICOLOR__foreground_purple="$STYLE__MULTICOLOR__foreground_magenta"
STYLE__MULTICOLOR__END__foreground_purple="$STYLE__MULTICOLOR__END__foreground"
STYLE__MULTICOLOR__foreground_gray="$STYLE__MULTICOLOR__foreground_white"
STYLE__MULTICOLOR__END__foreground_gray="$STYLE__MULTICOLOR__END__foreground"
STYLE__MULTICOLOR__foreground_grey="$STYLE__MULTICOLOR__foreground_white"
STYLE__MULTICOLOR__END__foreground_grey="$STYLE__MULTICOLOR__END__foreground"

# foreground_intense
STYLE__MULTICOLOR__foreground_intense_black=$'\e[90m' # tput setaf 8
STYLE__MULTICOLOR__END__foreground_intense_black="$STYLE__MULTICOLOR__END__foreground"
STYLE__MULTICOLOR__foreground_intense_red=$'\e[91m' # tput setaf 9
STYLE__MULTICOLOR__END__foreground_intense_red="$STYLE__MULTICOLOR__END__foreground"
STYLE__MULTICOLOR__foreground_intense_green=$'\e[92m' # tput setaf 10
STYLE__MULTICOLOR__END__foreground_intense_green="$STYLE__MULTICOLOR__END__foreground"
STYLE__MULTICOLOR__foreground_intense_yellow=$'\e[93m' # tput setaf 11
STYLE__MULTICOLOR__END__foreground_intense_yellow="$STYLE__MULTICOLOR__END__foreground"
STYLE__MULTICOLOR__foreground_intense_blue=$'\e[94m' # tput setaf 12
STYLE__MULTICOLOR__END__foreground_intense_blue="$STYLE__MULTICOLOR__END__foreground"
STYLE__MULTICOLOR__foreground_intense_magenta=$'\e[95m' # tput setaf 13
STYLE__MULTICOLOR__END__foreground_intense_magenta="$STYLE__MULTICOLOR__END__foreground"
STYLE__MULTICOLOR__foreground_intense_cyan=$'\e[96m' # tput setaf 14
STYLE__MULTICOLOR__END__foreground_intense_cyan="$STYLE__MULTICOLOR__END__foreground"
STYLE__MULTICOLOR__foreground_intense_white=$'\e[97m' # tput setaf 15
STYLE__MULTICOLOR__END__foreground_intense_white="$STYLE__MULTICOLOR__END__foreground"
STYLE__MULTICOLOR__foreground_intense_purple="$STYLE__MULTICOLOR__foreground_intense_magenta"
STYLE__MULTICOLOR__END__foreground_intense_purple="$STYLE__MULTICOLOR__END__foreground"
STYLE__MULTICOLOR__foreground_intense_gray="$STYLE__MULTICOLOR__foreground_intense_white"
STYLE__MULTICOLOR__END__foreground_intense_gray="$STYLE__MULTICOLOR__END__foreground"
STYLE__MULTICOLOR__foreground_intense_grey="$STYLE__MULTICOLOR__foreground_intense_white"
STYLE__MULTICOLOR__END__foreground_intense_grey="$STYLE__MULTICOLOR__END__foreground"

# background
STYLE__MULTICOLOR__background_black=$'\e[40m' # tput setab 0
STYLE__MULTICOLOR__END__background_black="$STYLE__MULTICOLOR__END__background"
STYLE__MULTICOLOR__background_red=$'\e[41m' # tput setab 1
STYLE__MULTICOLOR__END__background_red="$STYLE__MULTICOLOR__END__background"
STYLE__MULTICOLOR__background_green=$'\e[42m' # tput setab 2
STYLE__MULTICOLOR__END__background_green="$STYLE__MULTICOLOR__END__background"
STYLE__MULTICOLOR__background_yellow=$'\e[43m' # tput setab 3
STYLE__MULTICOLOR__END__background_yellow="$STYLE__MULTICOLOR__END__background"
STYLE__MULTICOLOR__background_blue=$'\e[44m' # tput setab 4
STYLE__MULTICOLOR__END__background_blue="$STYLE__MULTICOLOR__END__background"
STYLE__MULTICOLOR__background_magenta=$'\e[45m' # tput setab 5
STYLE__MULTICOLOR__END__background_magenta="$STYLE__MULTICOLOR__END__background"
STYLE__MULTICOLOR__background_cyan=$'\e[46m' # tput setab 6
STYLE__MULTICOLOR__END__background_cyan="$STYLE__MULTICOLOR__END__background"
STYLE__MULTICOLOR__background_white=$'\e[47m' # tput setab 7
STYLE__MULTICOLOR__END__background_white="$STYLE__MULTICOLOR__END__background"
STYLE__MULTICOLOR__background_purple="$STYLE__MULTICOLOR__background_magenta"
STYLE__MULTICOLOR__END__background_purple="$STYLE__MULTICOLOR__END__background"
STYLE__MULTICOLOR__background_gray="$STYLE__MULTICOLOR__background_white"
STYLE__MULTICOLOR__END__background_gray="$STYLE__MULTICOLOR__END__background"
STYLE__MULTICOLOR__background_grey="$STYLE__MULTICOLOR__background_white"
STYLE__MULTICOLOR__END__background_grey="$STYLE__MULTICOLOR__END__background"

# background_intense
STYLE__MULTICOLOR__background_intense_black=$'\e[100m' # tput setab 8
STYLE__MULTICOLOR__END__background_intense_black="$STYLE__MULTICOLOR__END__background"
STYLE__MULTICOLOR__background_intense_red=$'\e[101m' # tput setab 9
STYLE__MULTICOLOR__END__background_intense_red="$STYLE__MULTICOLOR__END__background"
STYLE__MULTICOLOR__background_intense_green=$'\e[102m' # tput setab 10
STYLE__MULTICOLOR__END__background_intense_green="$STYLE__MULTICOLOR__END__background"
STYLE__MULTICOLOR__background_intense_yellow=$'\e[103m' # tput setab 11
STYLE__MULTICOLOR__END__background_intense_yellow="$STYLE__MULTICOLOR__END__background"
STYLE__MULTICOLOR__background_intense_blue=$'\e[104m' # tput setab 12
STYLE__MULTICOLOR__END__background_intense_blue="$STYLE__MULTICOLOR__END__background"
STYLE__MULTICOLOR__background_intense_magenta=$'\e[105m' # tput setab 13
STYLE__MULTICOLOR__END__background_intense_magenta="$STYLE__MULTICOLOR__END__background"
STYLE__MULTICOLOR__background_intense_cyan=$'\e[106m' # tput setab 14
STYLE__MULTICOLOR__END__background_intense_cyan="$STYLE__MULTICOLOR__END__background"
STYLE__MULTICOLOR__background_intense_white=$'\e[107m' # tput setab 15
STYLE__MULTICOLOR__END__background_intense_white="$STYLE__MULTICOLOR__END__background"
STYLE__MULTICOLOR__background_intense_purple="$STYLE__MULTICOLOR__background_intense_magenta"
STYLE__MULTICOLOR__END__background_intense_purple="$STYLE__MULTICOLOR__END__background"
STYLE__MULTICOLOR__background_intense_gray="$STYLE__MULTICOLOR__background_intense_white"
STYLE__MULTICOLOR__END__background_intense_gray="$STYLE__MULTICOLOR__END__background"
STYLE__MULTICOLOR__background_intense_grey="$STYLE__MULTICOLOR__background_intense_white"
STYLE__MULTICOLOR__END__background_intense_grey="$STYLE__MULTICOLOR__END__background"

# modes that aren't implemented by operating systems
# blink_fast=$'\e[6m'

#######################################
# CUSTOM STYLES #######################

# styles
STYLE__MULTICOLOR__header="${STYLE__MULTICOLOR__bold}${STYLE__MULTICOLOR__underline}"
STYLE__MULTICOLOR__END__header="${STYLE__MULTICOLOR__END__intensity}${STYLE__MULTICOLOR__END__underline}"
STYLE__MULTICOLOR__header1="${STYLE__MULTICOLOR__invert}"
STYLE__MULTICOLOR__END__header1="${STYLE__MULTICOLOR__END__invert}"
STYLE__MULTICOLOR__header2="${STYLE__MULTICOLOR__bold}${STYLE__MULTICOLOR__underline}"
STYLE__MULTICOLOR__END__header2="${STYLE__MULTICOLOR__END__intensity}${STYLE__MULTICOLOR__END__underline}"
STYLE__MULTICOLOR__header3="${STYLE__MULTICOLOR__bold}"
STYLE__MULTICOLOR__END__header3="${STYLE__MULTICOLOR__END__intensity}"

STYLE__MULTICOLOR__success="${STYLE__MULTICOLOR__foreground_green}${STYLE__MULTICOLOR__bold}"
STYLE__MULTICOLOR__END__success="${STYLE__MULTICOLOR__END__foreground}${STYLE__MULTICOLOR__END__intensity}"
STYLE__MULTICOLOR__positive="${STYLE__MULTICOLOR__foreground_green}${STYLE__MULTICOLOR__bold}"
STYLE__MULTICOLOR__END__positive="${STYLE__MULTICOLOR__END__foreground}${STYLE__MULTICOLOR__END__intensity}"

STYLE__MULTICOLOR__note="${STYLE__MULTICOLOR__bold}${STYLE__MULTICOLOR__foreground_intense_blue}" # on dark theme, this is your eyes that need help
STYLE__MULTICOLOR__END__note="${STYLE__MULTICOLOR__END__intensity}${STYLE__MULTICOLOR__END__foreground}"

STYLE__MULTICOLOR__good1="${STYLE__MULTICOLOR__background_intense_green}${STYLE__MULTICOLOR__foreground_black}"
STYLE__MULTICOLOR__END__good1="${STYLE__MULTICOLOR__END__background}${STYLE__MULTICOLOR__END__foreground}"
STYLE__MULTICOLOR__code_good1="${STYLE__MULTICOLOR__background_intense_green}${STYLE__MULTICOLOR__foreground_intense_blue}"
STYLE__MULTICOLOR__END__code_good1="${STYLE__MULTICOLOR__END__background}${STYLE__MULTICOLOR__END__foreground}"

STYLE__MULTICOLOR__good2="${STYLE__MULTICOLOR__bold}${STYLE__MULTICOLOR__underline}${STYLE__MULTICOLOR__foreground_green}"
STYLE__MULTICOLOR__END__good2="${STYLE__MULTICOLOR__END__intensity}${STYLE__MULTICOLOR__END__underline}${STYLE__MULTICOLOR__END__foreground}"
STYLE__MULTICOLOR__good3="${STYLE__MULTICOLOR__bold}${STYLE__MULTICOLOR__foreground_green}"
STYLE__MULTICOLOR__END__good3="${STYLE__MULTICOLOR__END__intensity}${STYLE__MULTICOLOR__END__foreground}"
STYLE__MULTICOLOR__intense_good3="${STYLE__MULTICOLOR__bold}${STYLE__MULTICOLOR__foreground_intense_green}"
STYLE__MULTICOLOR__END__intense_good3="${STYLE__MULTICOLOR__END__intensity}${STYLE__MULTICOLOR__END__foreground}"

STYLE__MULTICOLOR__negative="${STYLE__MULTICOLOR__foreground_red}${STYLE__MULTICOLOR__bold}"
STYLE__MULTICOLOR__END__negative="${STYLE__MULTICOLOR__END__foreground}${STYLE__MULTICOLOR__END__intensity}"
STYLE__MULTICOLOR__error="${STYLE__MULTICOLOR__background_intense_red}${STYLE__MULTICOLOR__foreground_intense_white}"
STYLE__MULTICOLOR__END__error="${STYLE__MULTICOLOR__END__background}${STYLE__MULTICOLOR__END__foreground}"

STYLE__MULTICOLOR__error1="${STYLE__MULTICOLOR__background_red}${STYLE__MULTICOLOR__foreground_intense_white}"
STYLE__MULTICOLOR__END__error1="${STYLE__MULTICOLOR__END__background}${STYLE__MULTICOLOR__END__foreground}"
STYLE__MULTICOLOR__code_error1="${STYLE__MULTICOLOR__background_red}${STYLE__MULTICOLOR__foreground_intense_yellow}"
STYLE__MULTICOLOR__END__code_error1="${STYLE__MULTICOLOR__END__background}${STYLE__MULTICOLOR__END__foreground}"

STYLE__MULTICOLOR__error2="${STYLE__MULTICOLOR__bold}${STYLE__MULTICOLOR__underline}${STYLE__MULTICOLOR__foreground_red}"
STYLE__MULTICOLOR__END__error2="${STYLE__MULTICOLOR__END__intensity}${STYLE__MULTICOLOR__END__underline}${STYLE__MULTICOLOR__END__foreground}"
STYLE__MULTICOLOR__error3="${STYLE__MULTICOLOR__bold}${STYLE__MULTICOLOR__foreground_red}"
STYLE__MULTICOLOR__END__error3="${STYLE__MULTICOLOR__END__intensity}${STYLE__MULTICOLOR__END__foreground}"
STYLE__MULTICOLOR__intense_error3="${STYLE__MULTICOLOR__bold}${STYLE__MULTICOLOR__foreground_intense_red}"
STYLE__MULTICOLOR__END__intense_error3="${STYLE__MULTICOLOR__END__intensity}${STYLE__MULTICOLOR__END__foreground}"

STYLE__MULTICOLOR__notice="${STYLE__MULTICOLOR__bold}${STYLE__MULTICOLOR__underline}${STYLE__MULTICOLOR__foreground_intense_yellow}" # on dark theme, this is your eyes that need help
STYLE__MULTICOLOR__END__notice="${STYLE__MULTICOLOR__END__intensity}${STYLE__MULTICOLOR__END__underline}${STYLE__MULTICOLOR__END__foreground}"
STYLE__MULTICOLOR__warning="${STYLE__MULTICOLOR__bold}${STYLE__MULTICOLOR__underline}${STYLE__MULTICOLOR__foreground_yellow}"
STYLE__MULTICOLOR__END__warning="${STYLE__MULTICOLOR__END__intensity}${STYLE__MULTICOLOR__END__underline}${STYLE__MULTICOLOR__END__foreground}"
STYLE__MULTICOLOR__info="${STYLE__MULTICOLOR__bold}${STYLE__MULTICOLOR__underline}${STYLE__MULTICOLOR__foreground_intense_blue}" # on dark theme, this is your eyes that need help
STYLE__MULTICOLOR__END__info="${STYLE__MULTICOLOR__END__intensity}${STYLE__MULTICOLOR__END__underline}${STYLE__MULTICOLOR__END__foreground}"

STYLE__MULTICOLOR__notice1="${STYLE__MULTICOLOR__background_intense_yellow}${STYLE__MULTICOLOR__foreground_black}"
STYLE__MULTICOLOR__END__notice1="${STYLE__MULTICOLOR__END__background}${STYLE__MULTICOLOR__END__foreground}"
STYLE__MULTICOLOR__code_notice1="${STYLE__MULTICOLOR__background_intense_yellow}${STYLE__MULTICOLOR__foreground_blue}"
STYLE__MULTICOLOR__END__code_notice1="${STYLE__MULTICOLOR__END__background}${STYLE__MULTICOLOR__END__foreground}"

STYLE__MULTICOLOR__notice2="${STYLE__MULTICOLOR__bold}${STYLE__MULTICOLOR__underline}${STYLE__MULTICOLOR__foreground_yellow}"
STYLE__MULTICOLOR__END__notice2="${STYLE__MULTICOLOR__END__intensity}${STYLE__MULTICOLOR__END__underline}${STYLE__MULTICOLOR__END__foreground}"
STYLE__MULTICOLOR__notice3="${STYLE__MULTICOLOR__bold}${STYLE__MULTICOLOR__foreground_yellow}"
STYLE__MULTICOLOR__END__notice3="${STYLE__MULTICOLOR__END__intensity}${STYLE__MULTICOLOR__END__foreground}"
STYLE__MULTICOLOR__intense_notice3="${STYLE__MULTICOLOR__bold}${STYLE__MULTICOLOR__foreground_intense_yellow}"
STYLE__MULTICOLOR__END__intense_notice3="${STYLE__MULTICOLOR__END__intensity}${STYLE__MULTICOLOR__END__foreground}"

STYLE__MULTICOLOR__info1="${STYLE__MULTICOLOR__background_blue}${STYLE__MULTICOLOR__foreground_intense_white}"
STYLE__MULTICOLOR__END__info1="${STYLE__MULTICOLOR__END__background}${STYLE__MULTICOLOR__END__foreground}"
STYLE__MULTICOLOR__code_info1="${STYLE__MULTICOLOR__background_blue}${STYLE__MULTICOLOR__foreground_intense_green}"
STYLE__MULTICOLOR__END__code_info1="${STYLE__MULTICOLOR__END__background}${STYLE__MULTICOLOR__END__foreground}"

STYLE__MULTICOLOR__info2="${STYLE__MULTICOLOR__bold}${STYLE__MULTICOLOR__underline}${STYLE__MULTICOLOR__foreground_blue}"
STYLE__MULTICOLOR__END__info2="${STYLE__MULTICOLOR__END__intensity}${STYLE__MULTICOLOR__END__underline}${STYLE__MULTICOLOR__END__foreground}"
STYLE__MULTICOLOR__info3="${STYLE__MULTICOLOR__bold}${STYLE__MULTICOLOR__foreground_blue}"
STYLE__MULTICOLOR__END__info3="${STYLE__MULTICOLOR__END__intensity}${STYLE__MULTICOLOR__END__foreground}"
STYLE__MULTICOLOR__intense_info3="${STYLE__MULTICOLOR__bold}${STYLE__MULTICOLOR__foreground_intense_blue}"
STYLE__MULTICOLOR__END__intense_info3="${STYLE__MULTICOLOR__END__intensity}${STYLE__MULTICOLOR__END__foreground}"

STYLE__MULTICOLOR__redacted="${STYLE__MULTICOLOR__background_black}${STYLE__MULTICOLOR__foreground_black}" # alternative to conceal, which respects color themes
STYLE__MULTICOLOR__END__redacted="${STYLE__MULTICOLOR__END__background}${STYLE__MULTICOLOR__END__foreground}"
STYLE__MULTICOLOR__elevate="${STYLE__MULTICOLOR__foreground_intense_yellow}"
STYLE__MULTICOLOR__END__elevate="${STYLE__MULTICOLOR__END__foreground}"
STYLE__MULTICOLOR__code="${STYLE__MULTICOLOR__foreground_intense_black}"
STYLE__MULTICOLOR__END__code="${STYLE__MULTICOLOR__END__foreground}"
STYLE__MULTICOLOR__link="${STYLE__MULTICOLOR__foreground_blue}${STYLE__MULTICOLOR__underline}"
STYLE__MULTICOLOR__END__link="${STYLE__MULTICOLOR__END__underline}${STYLE__MULTICOLOR__END__foreground}"
STYLE__MULTICOLOR__url="${STYLE__MULTICOLOR__link}"
STYLE__MULTICOLOR__END__url="${STYLE__MULTICOLOR__END__link}"
STYLE__MULTICOLOR__path="${STYLE__MULTICOLOR__foreground_yellow}"
STYLE__MULTICOLOR__END__path="${STYLE__MULTICOLOR__END__foreground}"
# do not add a code-notice style that is just yellow text, as it is not better than just a standard code style as it doesn't distinguish itself enough, instead do a notice1 and code-notice1 style
if [[ -n $GITHUB_ACTIONS ]]; then
	STYLE__MULTICOLOR__header1="${STYLE__MULTICOLOR__background_intense_white}${STYLE__MULTICOLOR__foreground_black}"
	STYLE__MULTICOLOR__END__header1="${STYLE__MULTICOLOR__END__background}${STYLE__MULTICOLOR__END__foreground}"
	STYLE__MULTICOLOR__error1="${STYLE__MULTICOLOR__background_red}${STYLE__MULTICOLOR__foreground_black}"
	STYLE__MULTICOLOR__END__error1="${STYLE__MULTICOLOR__END__background}${STYLE__MULTICOLOR__END__foreground}"
	STYLE__MULTICOLOR__error="${STYLE__MULTICOLOR__background_red}${STYLE__MULTICOLOR__foreground_black}"
	STYLE__MULTICOLOR__END__error="${STYLE__MULTICOLOR__END__background}${STYLE__MULTICOLOR__END__foreground}"
elif [[ $THEME == 'light' ]]; then
	# trim STYLE__MULTICOLOR__foreground_intense_yellow as it is unreadable on light theme
	STYLE__MULTICOLOR__notice="${STYLE__MULTICOLOR__bold}${STYLE__MULTICOLOR__underline}${STYLE__MULTICOLOR__foreground_yellow}"
	STYLE__MULTICOLOR__END__notice="${STYLE__MULTICOLOR__END__intensity}${STYLE__MULTICOLOR__END__underline}${STYLE__MULTICOLOR__END__foreground}"
	STYLE__MULTICOLOR__elevate="${STYLE__MULTICOLOR__foreground_yellow}"
	STYLE__MULTICOLOR__END__elevate="${STYLE__MULTICOLOR__END__foreground}"

	# If italics is not supported, swap it with something else...
	# Values of TERM_PROGRAM that are known to not support italics:
	# - Apple_Terminal
	# As italics support is rare, do the swap if not in a known terminal that supports italics....
	if [[ $ITALICS_SUPPORTED == 'no' ]]; then
		# do not use underline, as it makes a mess, an underlined | or , or space is not pretty
		# STYLE__MULTICOLOR__italic="$STYLE__MULTICOLOR__dim"
		# STYLE__MULTICOLOR__END__italic="$STYLE__MULTICOLOR__END__dim"
		STYLE__MULTICOLOR__italic="$STYLE__MULTICOLOR__foreground_intense_black"
		STYLE__MULTICOLOR__END__italic="$STYLE__MULTICOLOR__END__foreground"
	fi
else
	# on dark theme on vscode
	# STYLE__MULTICOLOR__background_intense_red forces black foreground, which black on red is unreadable, so adjust
	if [[ $TERM_PROGRAM == 'vscode' ]]; then
		STYLE__MULTICOLOR__error="${STYLE__MULTICOLOR__background_red}${STYLE__MULTICOLOR__foreground_intense_white}"
		STYLE__MULTICOLOR__END__error="${STYLE__MULTICOLOR__END__background}${STYLE__MULTICOLOR__END__foreground}"
	fi

	# If italics is not supported, swap it with something else...
	# Values of TERM_PROGRAM that are known to not support italics:
	# - Apple_Terminal
	# As italics support is rare, do the swap if not in a known terminal that supports italics....
	if [[ $ITALICS_SUPPORTED == 'no' ]]; then
		# do not use underline, as it makes a mess, an underlined | or , or space is not pretty
		# STYLE__MULTICOLOR__italic="$STYLE__MULTICOLOR__dim"
		# STYLE__MULTICOLOR__END__italic="$STYLE__MULTICOLOR__END__dim"
		STYLE__MULTICOLOR__italic="$STYLE__MULTICOLOR__foreground_intense_white"
		STYLE__MULTICOLOR__END__italic="$STYLE__MULTICOLOR__END__foreground"
	fi
fi

# aliases
STYLE__MULTICOLOR__sudo="$STYLE__MULTICOLOR__elevate"
STYLE__MULTICOLOR__END__sudo="$STYLE__MULTICOLOR__END__elevate"

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
STYLE__icon_good='☺'
STYLE__icon_error='!'

# level 1 wrappers
# hN = header level N
# gN = good level N (use to close a header element)
# eN = error level N (use to close a header element)
# nN = notice level N (use to close a header element)
STYLE__MONOCOLOR__h1=$'\n┌  '
STYLE__MONOCOLOR__END__h1='  ┐'
STYLE__MULTICOLOR__h1=$'\n'"${STYLE__MULTICOLOR__header1}┌  "
STYLE__MULTICOLOR__END__h1="  ┐${STYLE__MULTICOLOR__END__header1}"

STYLE__MONOCOLOR__g1="└${STYLE__icon_good} "
STYLE__MONOCOLOR__END__g1=" ${STYLE__icon_good}┘"
STYLE__MULTICOLOR__g1="${STYLE__MULTICOLOR__good1}└  "
STYLE__MULTICOLOR__END__g1="  ┘${STYLE__MULTICOLOR__END__good1}"

STYLE__MONOCOLOR__e1="└${STYLE__icon_error} "
STYLE__MONOCOLOR__END__e1=" ${STYLE__icon_error}┘"
STYLE__MULTICOLOR__e1="${STYLE__MULTICOLOR__error1}└  "
STYLE__MULTICOLOR__END__e1="  ┘${STYLE__MULTICOLOR__END__error1}"

STYLE__MONOCOLOR__n1='└  '
STYLE__MONOCOLOR__END__n1='  ┘'
STYLE__MULTICOLOR__n1="${STYLE__MULTICOLOR__notice1}└  "
STYLE__MULTICOLOR__END__n1="  ┘${STYLE__MULTICOLOR__END__notice1}"

# level 2 wrappers
STYLE__MONOCOLOR__h2='┌  '
STYLE__MONOCOLOR__END__h2='  ┐'
STYLE__MULTICOLOR__h2="${STYLE__MULTICOLOR__reset}${STYLE__MULTICOLOR__bold}┌  "
STYLE__MULTICOLOR__END__h2="  ┐${STYLE__MULTICOLOR__reset}"
# STYLE__MULTICOLOR__h2="${STYLE__MULTICOLOR__reset}┌  ${STYLE__MULTICOLOR__invert}"
# STYLE__MULTICOLOR__END__h2="${STYLE__MULTICOLOR__END__invert}  ┐${STYLE__MULTICOLOR__reset}"

STYLE__MONOCOLOR__g2="└${STYLE__icon_good} "
STYLE__MONOCOLOR__END__g2=" ${STYLE__icon_good}┘"
STYLE__MULTICOLOR__g2="${STYLE__MULTICOLOR__reset}${STYLE__MULTICOLOR__bold}${STYLE__MULTICOLOR__foreground_green}└  "
STYLE__MULTICOLOR__END__g2="  ┘${STYLE__MULTICOLOR__reset}"

STYLE__MONOCOLOR__e2="└${STYLE__icon_error} "
STYLE__MONOCOLOR__END__e2=" ${STYLE__icon_error}┘"
STYLE__MULTICOLOR__e2="${STYLE__MULTICOLOR__reset}${STYLE__MULTICOLOR__bold}${STYLE__MULTICOLOR__foreground_red}└  "
STYLE__MULTICOLOR__END__e2="  ┘${STYLE__MULTICOLOR__reset}"

STYLE__MONOCOLOR__n2='└  '
STYLE__MONOCOLOR__END__n2='  ┘'
STYLE__MULTICOLOR__n2="${STYLE__MULTICOLOR__reset}${STYLE__MULTICOLOR__bold}${STYLE__MULTICOLOR__foreground_yellow}└  "
STYLE__MULTICOLOR__END__n2="  ┘${STYLE__MULTICOLOR__reset}"

# level 3 wrappers
STYLE__MONOCOLOR__h3='┌  '
STYLE__MONOCOLOR__END__h3='  ┐'
STYLE__MULTICOLOR__h3="${STYLE__MULTICOLOR__reset}┌  "
STYLE__MULTICOLOR__END__h3="  ┐${STYLE__MULTICOLOR__reset}"

STYLE__MONOCOLOR__g3="└${STYLE__icon_good} "
STYLE__MONOCOLOR__END__g3=" ${STYLE__icon_good}┘"
STYLE__MULTICOLOR__g3="${STYLE__MULTICOLOR__reset}${STYLE__MULTICOLOR__foreground_green}└  "
STYLE__MULTICOLOR__END__g3="  ┘${STYLE__MULTICOLOR__reset}"

STYLE__MONOCOLOR__e3="└${STYLE__icon_error} "
STYLE__MONOCOLOR__END__e3=" ${STYLE__icon_error}┘"
STYLE__MULTICOLOR__e3="${STYLE__MULTICOLOR__reset}${STYLE__MULTICOLOR__foreground_red}└  "
STYLE__MULTICOLOR__END__e3="  ┘${STYLE__MULTICOLOR__reset}"

STYLE__MONOCOLOR__n3='└  '
STYLE__MONOCOLOR__END__n3='  ┘'
STYLE__MULTICOLOR__n3="${STYLE__MULTICOLOR__reset}${STYLE__MULTICOLOR__foreground_yellow}└  "
STYLE__MULTICOLOR__END__n3="  ┘${STYLE__MULTICOLOR__reset}"

# element
STYLE__MONOCOLOR__element='< '
STYLE__MONOCOLOR__END__element=' >'
STYLE__MULTICOLOR__element="${STYLE__MULTICOLOR__dim}${STYLE__MULTICOLOR__bold}< ${STYLE__MULTICOLOR__END__intensity}"
STYLE__MULTICOLOR__END__element="${STYLE__MULTICOLOR__dim}${STYLE__MULTICOLOR__bold} >${STYLE__MULTICOLOR__END__intensity}"

STYLE__MONOCOLOR__slash_element='</ '
STYLE__MONOCOLOR__END__slash_element=' >'
STYLE__MULTICOLOR__slash_element="${STYLE__MULTICOLOR__dim}${STYLE__MULTICOLOR__bold}</ ${STYLE__MULTICOLOR__END__intensity}"
STYLE__MULTICOLOR__END__slash_element="${STYLE__MULTICOLOR__dim}${STYLE__MULTICOLOR__bold} >${STYLE__MULTICOLOR__END__intensity}"

STYLE__MONOCOLOR__element_slash='< '
STYLE__MONOCOLOR__END__element_slash=' />'
STYLE__MULTICOLOR__element_slash="${STYLE__MULTICOLOR__dim}${STYLE__MULTICOLOR__bold}< ${STYLE__MULTICOLOR__END__intensity}"
STYLE__MULTICOLOR__END__element_slash="${STYLE__MULTICOLOR__dim}${STYLE__MULTICOLOR__bold} />${STYLE__MULTICOLOR__END__intensity}"

# fragment
STYLE__MONOCOLOR__fragment='<>'
STYLE__MULTICOLOR__fragment="${STYLE__MULTICOLOR__dim}${STYLE__MULTICOLOR__bold}<>${STYLE__MULTICOLOR__END__intensity}"

STYLE__MONOCOLOR__slash_fragment='</>'
STYLE__MULTICOLOR__slash_fragment="${STYLE__MULTICOLOR__dim}${STYLE__MULTICOLOR__bold}</>${STYLE__MULTICOLOR__END__intensity}"

# the STYLE__MULTICOLOR__resets allow these to work:
# echo-style --h1_begin --h1='Setup Python' --h1__END $'\n' --g1_begin --g1='Setup Python' --g1__END
# echo-style --element_slash_begin --h3="this should not be dim" --element_slash__END "$status"
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
STYLE__MULTICOLOR__question_title_prompt="${STYLE__MULTICOLOR__bold}${STYLE__MULTICOLOR__underline}"
STYLE__MULTICOLOR__END__question_title_prompt="${STYLE__MULTICOLOR__END__bold}${STYLE__MULTICOLOR__END__underline}"

STYLE__MULTICOLOR__question_title_result="${STYLE__MULTICOLOR__bold}"
STYLE__MULTICOLOR__END__question_title_result="${STYLE__MULTICOLOR__END__bold}"

STYLE__MULTICOLOR__question_body="${STYLE__MULTICOLOR__dim}"
STYLE__MULTICOLOR__END__question_body="${STYLE__MULTICOLOR__END__dim}"

# ask icons
STYLE__icon_prompt='> '

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
STYLE__icon_multi_selected='▣ '
STYLE__icon_multi_default='⊡ '
STYLE__icon_multi_active='⊡ '
STYLE__icon_multi_standard='□ '
STYLE__icon_single_selected='⦿ ' # only used in confirmation and linger
STYLE__icon_single_default='⦾ '
STYLE__icon_single_active_required='◉ '
STYLE__icon_single_active_optional='⦿ '
STYLE__icon_single_standard='○ '
STYLE__MULTICOLOR__result_line="$STYLE__MULTICOLOR__dim"
STYLE__MULTICOLOR__END__result_line="$STYLE__MULTICOLOR__END__intensity"
STYLE__MULTICOLOR__active_line="$STYLE__MULTICOLOR__invert"
STYLE__MULTICOLOR__END__active_line="$STYLE__MULTICOLOR__END__invert"
STYLE__MULTICOLOR__selected_line="$STYLE__MULTICOLOR__foreground_intense_green"
STYLE__MULTICOLOR__END__selected_line="$STYLE__MULTICOLOR__END__foreground"
STYLE__MULTICOLOR__default_line="$STYLE__MULTICOLOR__foreground_intense_yellow"
STYLE__MULTICOLOR__END__default_line="$STYLE__MULTICOLOR__END__foreground"
STYLE__MULTICOLOR__empty_line="${STYLE__MULTICOLOR__foreground_magenta}${STYLE__MULTICOLOR__background_intense_white}" # this is inverted
STYLE__MULTICOLOR__END__empty_line="${STYLE__MULTICOLOR__END__foreground}${STYLE__MULTICOLOR__END__background}"
STYLE__MULTICOLOR__inactive_line=''
STYLE__MULTICOLOR__END__inactive_line=''

# notice and warning too much emphasis on something with fallback
# confirm/choose/ask failures
STYLE__MULTICOLOR__input_warning="${STYLE__MULTICOLOR__bold}${STYLE__MULTICOLOR__foreground_yellow}"
STYLE__MULTICOLOR__END__input_warning="${STYLE__MULTICOLOR__END__bold}${STYLE__MULTICOLOR__END__foreground_yellow}"
STYLE__MULTICOLOR__input_error="${STYLE__MULTICOLOR__error1}"
STYLE__MULTICOLOR__END__input_error="${STYLE__MULTICOLOR__END__error1}"

# confirm/choose/ask/debugging text
STYLE__commentary='[ '
STYLE__commentary__END=' ]'
STYLE__icon_nothing_provided="${STYLE__commentary}nothing provided${STYLE__commentary__END}"
STYLE__icon_undeclared="${STYLE__commentary}undeclared${STYLE__commentary__END}"
STYLE__icon_undefined="${STYLE__commentary}undefined${STYLE__commentary__END}"
STYLE__icon_empty="${STYLE__commentary}empty${STYLE__commentary__END}"
STYLE__icon_no_selection="${STYLE__commentary}no selection${STYLE__commentary__END}"
STYLE__icon_nothing_selected="${STYLE__commentary}nothing selected${STYLE__commentary__END}"
STYLE__icon_using_password="${STYLE__commentary}using the entered password${STYLE__commentary__END}"
STYLE__icon_timeout_default="${STYLE__commentary}timed out: used default${STYLE__commentary__END}"
STYLE__icon_timeout_optional="${STYLE__commentary}timed out: not required${STYLE__commentary__END}"
STYLE__icon_timeout_required="${STYLE__commentary}input failure: timed out: required${STYLE__commentary__END}"
STYLE__icon_input_failure="${STYLE__commentary}input failure: %s${STYLE__commentary__END}"

STYLE__MONOCOLOR__commentary_nothing_provided="${STYLE__icon_nothing_provided}"
STYLE__MULTICOLOR__commentary_nothing_provided="${STYLE__MULTICOLOR__empty_line}${STYLE__icon_nothing_provided}${STYLE__MULTICOLOR__END__empty_line}"

STYLE__MONOCOLOR__commentary_undeclared="${STYLE__icon_undeclared}"
STYLE__MULTICOLOR__commentary_undeclared="${STYLE__MULTICOLOR__empty_line}${STYLE__icon_undeclared}${STYLE__MULTICOLOR__END__empty_line}"

STYLE__MONOCOLOR__commentary_undefined="${STYLE__icon_undefined}"
STYLE__MULTICOLOR__commentary_undefined="${STYLE__MULTICOLOR__empty_line}${STYLE__icon_undefined}${STYLE__MULTICOLOR__END__empty_line}"

STYLE__MONOCOLOR__commentary_empty="${STYLE__icon_empty}"
STYLE__MULTICOLOR__commentary_empty="${STYLE__MULTICOLOR__empty_line}${STYLE__icon_empty}${STYLE__MULTICOLOR__END__empty_line}"

STYLE__MONOCOLOR__commentary_no_selection="${STYLE__icon_no_selection}"
STYLE__MULTICOLOR__commentary_no_selection="${STYLE__MULTICOLOR__empty_line}${STYLE__icon_no_selection}${STYLE__MULTICOLOR__END__empty_line}"

STYLE__MONOCOLOR__commentary_nothing_selected="${STYLE__icon_nothing_selected}"
STYLE__MULTICOLOR__commentary_nothing_selected="${STYLE__MULTICOLOR__empty_line}${STYLE__icon_nothing_selected}${STYLE__MULTICOLOR__END__empty_line}"

STYLE__MONOCOLOR__commentary_using_password="${STYLE__icon_using_password}"
STYLE__MULTICOLOR__commentary_using_password="${STYLE__MULTICOLOR__empty_line}${STYLE__icon_using_password}${STYLE__MULTICOLOR__END__empty_line}"

STYLE__MONOCOLOR__commentary_timeout_default="${STYLE__icon_timeout_default}"
STYLE__MULTICOLOR__commentary_timeout_default="${STYLE__MULTICOLOR__input_warning}${STYLE__icon_timeout_default}${STYLE__MULTICOLOR__END__input_warning}"

STYLE__MONOCOLOR__commentary_timeout_optional="${STYLE__icon_timeout_optional}"
STYLE__MULTICOLOR__commentary_timeout_optional="${STYLE__MULTICOLOR__input_warning}${STYLE__icon_timeout_optional}${STYLE__MULTICOLOR__END__input_warning}"

STYLE__MONOCOLOR__commentary_timeout_required="${STYLE__icon_timeout_required}"
STYLE__MULTICOLOR__commentary_timeout_required="${STYLE__MULTICOLOR__input_error}${STYLE__icon_timeout_required}${STYLE__MULTICOLOR__END__input_error}"

STYLE__MONOCOLOR__commentary_input_failure="${STYLE__icon_input_failure}"
STYLE__MULTICOLOR__commentary_input_failure="${STYLE__MULTICOLOR__input_error}${STYLE__icon_input_failure}${STYLE__MULTICOLOR__END__input_error}"

# spacers
STYLE__result_commentary_spacer=' '
STYLE__legend_legend_spacer='  '
STYLE__legend_key_spacer=' '
STYLE__key_key_spacer=' '
STYLE__indent_bar='   '
STYLE__indent_active='⏵  '
STYLE__indent_inactive='   '
STYLE__indent_blockquote='│ '
STYLE__MONOCOLOR__count_spacer=' ∙ '
STYLE__MULTICOLOR__count_spacer=" ${STYLE__MULTICOLOR__foreground_intense_black}∙${STYLE__MULTICOLOR__END__foreground} "

# legend
STYLE__MULTICOLOR__legend="$STYLE__MULTICOLOR__dim" # dim is better than white, nice separation
STYLE__MULTICOLOR__END__legend="$STYLE__MULTICOLOR__END__intensity"
STYLE__MULTICOLOR__key="${STYLE__MULTICOLOR__foreground_black}${STYLE__MULTICOLOR__background_white} "
STYLE__MULTICOLOR__END__key=" ${STYLE__MULTICOLOR__END__foreground}${STYLE__MULTICOLOR__END__background}"
STYLE__MULTICOLOR__key_active="${STYLE__MULTICOLOR__foreground_black}${STYLE__MULTICOLOR__background_intense_white} "
STYLE__MULTICOLOR__END__key_active=" ${STYLE__MULTICOLOR__END__foreground}${STYLE__MULTICOLOR__END__background}"
STYLE__MONOCOLOR__key='['
STYLE__MONOCOLOR__END__key=']'
STYLE__MONOCOLOR__key_active='['
STYLE__MONOCOLOR__END__key_active=']'

# paging counts
# STYLE__count_more=''
STYLE__MULTICOLOR__count_more="$STYLE__MULTICOLOR__dim"
STYLE__MULTICOLOR__END__count_more="$STYLE__MULTICOLOR__END__dim"
STYLE__MULTICOLOR__count_selected="$STYLE__MULTICOLOR__foreground_green"
STYLE__MULTICOLOR__END__count_selected="$STYLE__MULTICOLOR__END__foreground"
STYLE__MULTICOLOR__count_defaults="$STYLE__MULTICOLOR__foreground_yellow"
STYLE__MULTICOLOR__END__count_defaults="$STYLE__MULTICOLOR__END__foreground"
STYLE__MULTICOLOR__count_empty="$STYLE__MULTICOLOR__foreground_magenta"
STYLE__MULTICOLOR__END__count_empty="$STYLE__MULTICOLOR__END__foreground"

# paging headers
# STYLE__bar_top='┌ '
# STYLE__END__bar_top=' ┐'
# STYLE__bar_middle='├ '
# STYLE__END__bar_middle=' ┤'
# STYLE__bar_bottom='└ '
# STYLE__END__bar_bottom=' ┘'
# STYLE__bar_line='│ '
STYLE__MONOCOLOR__bar_top='┌ '
STYLE__MONOCOLOR__END__bar_top=' ┐'
STYLE__MONOCOLOR__bar_middle='├ '
STYLE__MONOCOLOR__END__bar_middle=' ┤'
STYLE__MONOCOLOR__bar_bottom='└ '
STYLE__MONOCOLOR__END__bar_bottom=' ┘'
STYLE__MONOCOLOR__bar_line='│ '
STYLE__MULTICOLOR__bar_top="${STYLE__MULTICOLOR__dim}┌${STYLE__MULTICOLOR__END__dim} "
STYLE__MULTICOLOR__END__bar_top=" ${STYLE__MULTICOLOR__dim}┐${STYLE__MULTICOLOR__END__dim}"
STYLE__MULTICOLOR__bar_middle="${STYLE__MULTICOLOR__dim}├${STYLE__MULTICOLOR__END__dim} "
STYLE__MULTICOLOR__END__bar_middle=" ${STYLE__MULTICOLOR__dim}┤${STYLE__MULTICOLOR__END__dim}"
STYLE__MULTICOLOR__bar_bottom="${STYLE__MULTICOLOR__dim}└${STYLE__MULTICOLOR__END__dim} "
STYLE__MULTICOLOR__END__bar_bottom=" ${STYLE__MULTICOLOR__dim}┘${STYLE__MULTICOLOR__END__dim}"
STYLE__MULTICOLOR__bar_line="${STYLE__MULTICOLOR__dim}│${STYLE__MULTICOLOR__END__dim} "

# if confirm appears dim, it is because your terminal theme has changed and you haven't opened a new terminal tab

# adjustments
if [[ $THEME == 'light' ]]; then
	# keys
	STYLE__MULTICOLOR__legend="$STYLE__MULTICOLOR__foreground_intense_black"
	STYLE__MULTICOLOR__END__legend="$STYLE__MULTICOLOR__END__foreground"
	STYLE__MULTICOLOR__key="$STYLE__MULTICOLOR__background_intense_white "
	STYLE__MULTICOLOR__END__key=" $STYLE__MULTICOLOR__END__background"
	# lines
	STYLE__MULTICOLOR__selected_line="$STYLE__MULTICOLOR__foreground_green"
	STYLE__MULTICOLOR__END__selected_line="$STYLE__MULTICOLOR__END__foreground"
	STYLE__MULTICOLOR__default_line="$STYLE__MULTICOLOR__foreground_yellow"
	STYLE__MULTICOLOR__END__default_line="$STYLE__MULTICOLOR__END__foreground"
fi

#######################################
# RENDER HELPERS ######################

# declare -A STYLES_MONOCOLOR STYLES_MULTICOLOR <-- for bash v4.0 and above, cache to these instead for performance
function __load_styles {
	local LOAD_STYLES__item LOAD_STYLES__color='' LOAD_STYLES__save='' LOAD_STYLES__begin='' LOAD_STYLES__end=''
	while [[ $# -ne 0 ]]; do
		LOAD_STYLES__item="$1"
		shift
		case "$LOAD_STYLES__item" in
		--no-color* | --color*) __flag --source={LOAD_STYLES__item} --target={LOAD_STYLES__color} --affirmative --coerce || return $? ;;
		--no-save* | --save* | --no-cache* | --cache*) __flag --source={LOAD_STYLES__item} --target={LOAD_STYLES__save} --affirmative || return $? ;; # yes/no/auto
		--begin={*})
			__dereference --source="${LOAD_STYLES__item#*=}" --name={LOAD_STYLES__begin} || return $?
			# LOAD_STYLES__begin="${LOAD_STYLES__item#*=}"
			# LOAD_STYLES__begin="${LOAD_STYLES__begin//[^a-zA-Z0-9_]/}"
			;;
		--end={*})
			__dereference --source="${LOAD_STYLES__item#*=}" --name={LOAD_STYLES__end} || return $?
			# LOAD_STYLES__end="${LOAD_STYLES__item#*=}"
			# LOAD_STYLES__end="${LOAD_STYLES__end//[^a-zA-Z0-9_]/}"
			;;
		--) break ;;
		--*) __unrecognised_argument "$LOAD_STYLES__item" || return $? ;;
		esac
	done
	# require either save/cache or begin/end
	if [[ -z $LOAD_STYLES__save && -z $LOAD_STYLES__begin && -z $LOAD_STYLES__end ]]; then
		__print_lines "ERROR: ${FUNCNAME[0]}: Either --save/--cache or --begin=.../--end=... is required" >&2 || return $?
		return 22 # EINVAL 22 Invalid argument
	fi
	# color
	if [[ -z $LOAD_STYLES__color ]]; then
		if [[ ${COLOR-} =~ ^(yes|no)$ ]]; then
			LOAD_STYLES__color="$COLOR"
		elif __get_terminal_color_support --quiet --fallback=yes; then
			LOAD_STYLES__color='yes'
		else
			LOAD_STYLES__color='no'
		fi
	fi
	if [[ -z $LOAD_STYLES__save ]]; then
		if [[ $LOAD_STYLES__color == "$COLOR" ]]; then
			LOAD_STYLES__save='auto'
		else
			LOAD_STYLES__save='no'
		fi
	fi
	local LOAD_STYLES__desired LOAD_STYLES__undesired
	if [[ $LOAD_STYLES__color == 'yes' ]]; then
		LOAD_STYLES__desired='MULTICOLOR'
		LOAD_STYLES__undesired='MONOCOLOR'
	else
		LOAD_STYLES__desired='MONOCOLOR'
		LOAD_STYLES__undesired='MULTICOLOR'
	fi
	# cycle
	local LOAD_STYLES__style LOAD_STYLES__eval='' LOAD_STYLES__var='' LOAD_STYLES__found LOAD_STYLES__missing=()
	for LOAD_STYLES__style in "$@"; do
		# RESET
		LOAD_STYLES__found='no' LOAD_STYLES__eval=''

		# BEGIN
		# check if it has explicit desired color
		LOAD_STYLES__var="STYLE__${LOAD_STYLES__desired}__${LOAD_STYLES__style}"
		if __is_var_defined "$LOAD_STYLES__var"; then
			# it has explicit desired color
			case "$LOAD_STYLES__save" in
			yes) LOAD_STYLES__eval+="STYLE__${LOAD_STYLES__style}=\"\${${LOAD_STYLES__var}}\"; " ;;
			esac
			# append our result with the explicit desired color
			if [[ -n $LOAD_STYLES__begin ]]; then
				LOAD_STYLES__eval+="${LOAD_STYLES__begin}+=\"\${${LOAD_STYLES__var}}\"; "
			fi
			# note it has been found
			LOAD_STYLES__found='yes'
		else
			# it does not have explicit undesired color
			# check if it has explicit undesired color
			LOAD_STYLES__var="STYLE__${LOAD_STYLES__undesired}__${LOAD_STYLES__style}"
			if __is_var_defined "$LOAD_STYLES__var"; then
				# it does not have explicit desired color, but it has the explicit undesired color
				case "$LOAD_STYLES__save" in
				auto | yes) LOAD_STYLES__eval+="STYLE__${LOAD_STYLES__desired}__${LOAD_STYLES__style}='' STYLE__${LOAD_STYLES__style}=''; " ;;
				esac
				# note it has been found
				LOAD_STYLES__found='yes'
			else
				# it doesn't have explicit desired nor undesired
				# check if it implicit combo
				LOAD_STYLES__var="STYLE__${LOAD_STYLES__style}"
				if __is_var_defined "$LOAD_STYLES__var"; then
					# it does have implicit combo
					case "$LOAD_STYLES__save" in
					auto | yes) LOAD_STYLES__eval+="STYLE__${LOAD_STYLES__desired}__${LOAD_STYLES__style}=\"\${${LOAD_STYLES__var}}\" STYLE__${LOAD_STYLES__undesired}__${LOAD_STYLES__style}=\"\${${LOAD_STYLES__var}}\"; " ;;
					esac
					# append our result with the implicit combo
					if [[ -n $LOAD_STYLES__begin ]]; then
						LOAD_STYLES__eval+="${LOAD_STYLES__begin}+=\"\${${LOAD_STYLES__var}}\"; "
					fi
					# note it has been found
					LOAD_STYLES__found='yes'
				fi
			fi
		fi

		# END
		# check if it has explicit desired color
		LOAD_STYLES__var="STYLE__${LOAD_STYLES__desired}__END__${LOAD_STYLES__style}"
		if __is_var_defined "$LOAD_STYLES__var"; then
			# it has explicit desired color
			case "$LOAD_STYLES__save" in
			yes) LOAD_STYLES__eval+="STYLE__END__${LOAD_STYLES__style}=\"\${${LOAD_STYLES__var}}\"; " ;;
			esac
			# prepend our result with the explicit desired color
			if [[ -n $LOAD_STYLES__end ]]; then
				LOAD_STYLES__eval+="${LOAD_STYLES__end}=\"\${${LOAD_STYLES__var}}\${${LOAD_STYLES__end}}\"; "
			fi
			# note it has been found
			LOAD_STYLES__found='yes'
		else
			# it does not have explicit undesired color
			# check if it has explicit undesired color
			LOAD_STYLES__var="STYLE__${LOAD_STYLES__undesired}__END__${LOAD_STYLES__style}"
			if __is_var_defined "$LOAD_STYLES__var"; then
				# it does not have explicit desired color, but it has the explicit undesired color
				case "$LOAD_STYLES__save" in
				auto | yes) LOAD_STYLES__eval+="STYLE__${LOAD_STYLES__desired}__END__${LOAD_STYLES__style}='' STYLE__END__${LOAD_STYLES__style}=''; " ;;
				esac
				# note it has been found
				LOAD_STYLES__found='yes'
			else
				# it doesn't have explicit desired nor undesired
				# check if it implicit combo
				LOAD_STYLES__var="STYLE__END__${LOAD_STYLES__style}"
				if __is_var_defined "$LOAD_STYLES__var"; then
					# it does have implicit combo
					case "$LOAD_STYLES__save" in
					auto | yes) LOAD_STYLES__eval+="STYLE__${LOAD_STYLES__desired}__END__${LOAD_STYLES__style}=\"\${${LOAD_STYLES__var}}\" STYLE__${LOAD_STYLES__undesired}__END__${LOAD_STYLES__style}=\"\${${LOAD_STYLES__var}}\"; " ;;
					esac
					# prepend our result with the implicit combo
					if [[ -n $LOAD_STYLES__end ]]; then
						LOAD_STYLES__eval+="${LOAD_STYLES__end}=\"\${${LOAD_STYLES__var}}\${${LOAD_STYLES__end}}\"; "
					fi
					# note it has been found
					LOAD_STYLES__found='yes'
				fi
			fi
		fi
		if [[ -n $LOAD_STYLES__eval ]]; then
			eval "$LOAD_STYLES__eval" || return $?
		fi
		if [[ $LOAD_STYLES__found == 'no' ]]; then
			LOAD_STYLES__missing+=("$LOAD_STYLES__style")
		fi
	done
	if [[ ${#LOAD_STYLES__missing[@]} -ne 0 ]]; then
		__print_lines "ERROR: ${FUNCNAME[0]}: MISSING STYLES:" "${LOAD_STYLES__missing[@]}" >&2 || return $?
		return 22 # EINVAL 22 Invalid argument
	fi
}

function __refresh_style_cache {
	__load_styles --save "$@"
}

function __print_style {
	# process
	local PRINT_STYLE__item PRINT_STYLE__items=() PRINT_STYLE__trail='yes' PRINT_STYLE__color=''
	while [[ $# -ne 0 ]]; do
		PRINT_STYLE__item="$1"
		shift
		case "$PRINT_STYLE__item" in
		--no-trail* | --trail*) __flag --source={PRINT_STYLE__item} --target={PRINT_STYLE__trail} --affirmative --coerce || return $? ;;
		--no-color* | --color*) __flag --source={PRINT_STYLE__item} --target={PRINT_STYLE__color} --affirmative --coerce || return $? ;;
		--)
			PRINT_STYLE__items+=("$@")
			shift $#
			;;
		*)
			PRINT_STYLE__items+=("$PRINT_STYLE__item" "$@")
			shift $#
			;;
		esac
	done

	# fetch color if not provided by argument, as this is expensive
	if [[ -z $PRINT_STYLE__color ]]; then
		PRINT_STYLE__color="$(__get_terminal_color_support --fallback=yes)" # parse env only, as flags are handled by us to support color and nocolor modifiers
	fi

	# =====================================
	# Action

	# act
	local PRINT_STYLE__item PRINT_STYLE__item_flag PRINT_STYLE__item_type \
		PRINT_STYLE__index PRINT_STYLE__current_char_index PRINT_STYLE__last_char_index \
		PRINT_STYLE__item_target \
		PRINT_STYLE__buffer_target='/dev/stdout' \
		PRINT_STYLE__item_color \
		PRINT_STYLE__buffer_color="$PRINT_STYLE__color" \
		PRINT_STYLE__item_begin \
		PRINT_STYLE__item_content \
		PRINT_STYLE__item_end \
		PRINT_STYLE__flag_style \
		PRINT_STYLE__item_styles=() \
		PRINT_STYLE__buffer_left='' \
		PRINT_STYLE__buffer_disable='' \
		PRINT_STYLE__buffer_right=''
	for PRINT_STYLE__item in "${PRINT_STYLE__items[@]}"; do
		# reset
		PRINT_STYLE__item_target="$PRINT_STYLE__buffer_target"
		PRINT_STYLE__item_color="$PRINT_STYLE__buffer_color"
		PRINT_STYLE__item_flag=''
		PRINT_STYLE__item_content=''
		# check flag status
		if [[ ${PRINT_STYLE__item:0:3} == '--=' ]]; then
			# empty flag, just item content, e.g. '--=Hello', --=--=
			PRINT_STYLE__item_type='content'
			PRINT_STYLE__item_content="${PRINT_STYLE__item:3}"
		elif [[ ${PRINT_STYLE__item:0:2} != '--' || $PRINT_STYLE__item == '--' ]]; then
			# not a flag, just item content, e.g. 'Hello', '--'
			PRINT_STYLE__item_type='content'
			PRINT_STYLE__item_content="$PRINT_STYLE__item"
		else
			# is a flag
			PRINT_STYLE__item_type='flag'
			PRINT_STYLE__item_flag="${PRINT_STYLE__item:2}"

			# break apart the flag into <flag>=<item_content> combo
			for ((PRINT_STYLE__index = 0; PRINT_STYLE__index < ${#PRINT_STYLE__item_flag}; PRINT_STYLE__index++)); do
				if [[ ${PRINT_STYLE__item_flag:PRINT_STYLE__index:1} == '=' ]]; then
					PRINT_STYLE__item_type='flag+content'
					PRINT_STYLE__item_content="${PRINT_STYLE__item_flag:PRINT_STYLE__index+1}"
					PRINT_STYLE__item_flag="${PRINT_STYLE__item_flag:0:PRINT_STYLE__index}"
					break
				fi
			done

			# lowercase the flag
			PRINT_STYLE__item_flag="$(__get_lowercase_string "$PRINT_STYLE__item_flag")"

			# handle style+style combinations
			PRINT_STYLE__last_char_index=0
			PRINT_STYLE__item_styles=()
			for ((PRINT_STYLE__current_char_index = 0; PRINT_STYLE__current_char_index <= ${#PRINT_STYLE__item_flag}; PRINT_STYLE__current_char_index++)); do
				if [[ ${PRINT_STYLE__item_flag:PRINT_STYLE__current_char_index:1} == '+' || $PRINT_STYLE__current_char_index -eq ${#PRINT_STYLE__item_flag} ]]; then
					PRINT_STYLE__flag_style="${PRINT_STYLE__item_flag:PRINT_STYLE__last_char_index:PRINT_STYLE__current_char_index-PRINT_STYLE__last_char_index}"
					PRINT_STYLE__last_char_index="$((PRINT_STYLE__current_char_index + 1))"
					PRINT_STYLE__flag_style="${PRINT_STYLE__flag_style//-/_}" # convert hyphens to underscores

					# handle special cases
					case "$PRINT_STYLE__flag_style" in
					black | red | green | yellow | blue | magenta | cyan | white | purple | gray | grey) PRINT_STYLE__flag_style="foreground_${PRINT_STYLE__flag_style}" ;;
					intense_black | intense_red | intense_green | intense_yellow | intense_blue | intense_magenta | intense_cyan | intense_white | intense_purple | intense_gray | intense_grey) PRINT_STYLE__flag_style="foreground_intense_${PRINT_STYLE__flag_style:8}" ;;
					/*) PRINT_STYLE__flag_style="slash_${PRINT_STYLE__flag_style:1}" ;;
					*/)
						__replace --source+target={PRINT_STYLE__flag_style} --trailing='/' || return $?
						PRINT_STYLE__flag_style+='_slash'
						;;
					status)
						if [[ $PRINT_STYLE__item_content -eq 0 ]]; then
							PRINT_STYLE__flag_style='good3'
						else
							PRINT_STYLE__flag_style='error3'
						fi
						PRINT_STYLE__item_content="[${PRINT_STYLE__item_content}]"
						;;
					multicolor)
						PRINT_STYLE__item_color='yes'
						if [[ $PRINT_STYLE__item_type == 'flag' ]]; then
							PRINT_STYLE__buffer_color='yes'
						fi
						continue
						;;
					monocolor)
						PRINT_STYLE__item_color='no'
						if [[ $PRINT_STYLE__item_type == 'flag' ]]; then
							PRINT_STYLE__buffer_color='no'
						fi
						continue
						;;
					stdout)
						PRINT_STYLE__item_target='/dev/stdout'
						continue
						;;
					stderr)
						PRINT_STYLE__item_target='/dev/stderr'
						continue
						;;
					tty)
						PRINT_STYLE__item_target='/dev/tty'
						continue
						;;
					debug)
						if [[ $DOROTHY_DEBUG == 'yes' ]]; then
							PRINT_STYLE__item_target="${BASH_XTRACEFD:-"2"}"
						else
							PRINT_STYLE__item_target='/dev/null'
						fi
						continue
						;;
					null)
						PRINT_STYLE__item_target='/dev/null'
						continue
						;;
					value)
						PRINT_STYLE__item_content="$(__dump --value="$PRINT_STYLE__item_content")" || return $?
						continue
						;;
					variable_value)
						PRINT_STYLE__item_content="$(__dump --variable-value="$PRINT_STYLE__item_content")" || return $?
						continue
						;;
					variable)
						PRINT_STYLE__item_content="$(__dump --variable="$PRINT_STYLE__item_content")" || return $?
						continue
						;;
					help | man)
						# trunk-ignore(shellcheck/SC2119)
						PRINT_STYLE__item_content="$(__print_help <<<"$PRINT_STYLE__item_content" 2>&1)" || return $?
						continue
						;;
					esac

					# add the possibly modified style to the item styles
					PRINT_STYLE__item_styles+=("$PRINT_STYLE__flag_style")
				fi
			done

			# append and prepend the styles
			# it is done here, to do them all at once, but also to make sure that a trailing +multicolor/monocolor is respected
			PRINT_STYLE__item_begin=''
			PRINT_STYLE__item_end=''
			__load_styles --color="$PRINT_STYLE__item_color" --begin={PRINT_STYLE__item_begin} --end={PRINT_STYLE__item_end} -- "${PRINT_STYLE__item_styles[@]}" || return $?
		fi

		# handle nocolor and color correctly, as in conditional output based on NO_COLOR=true
		# e.g. env COLOR=false echo-style --color=yes --nocolor=no # outputs no
		# e.g. env COLOR=true echo-style --color=yes --nocolor=no # outputs yes
		if [[ $PRINT_STYLE__item_color != "$PRINT_STYLE__color" ]]; then
			continue
		fi

		# handle the argument type
		if [[ $PRINT_STYLE__item_type == 'content' ]]; then
			PRINT_STYLE__buffer_left+="$PRINT_STYLE__item_content"
		elif [[ $PRINT_STYLE__item_type == 'flag' ]]; then
			# flush buffer if necessary
			if [[ $PRINT_STYLE__item_target != "$PRINT_STYLE__buffer_target" ]]; then
				__value_to_target "$PRINT_STYLE__buffer_left" "$PRINT_STYLE__buffer_target" || return $?
				PRINT_STYLE__buffer_left=''
				PRINT_STYLE__buffer_target="$PRINT_STYLE__item_target"
			fi
			# update buffer
			PRINT_STYLE__buffer_left+="${PRINT_STYLE__item_begin}"
			# if [[ $PRINT_STYLE__buffer_disable != *"$ITEM_DISABLE"* ]]; then
			# 	PRINT_STYLE__buffer_disable="${ITEM_DISABLE}${PRINT_STYLE__buffer_disable}"
			# fi
			PRINT_STYLE__buffer_right="${PRINT_STYLE__item_end}${PRINT_STYLE__buffer_right}"
		else
			# flush buffer if necessary
			if [[ $PRINT_STYLE__item_target != "$PRINT_STYLE__buffer_target" ]]; then
				__value_to_target "$PRINT_STYLE__buffer_left" "$PRINT_STYLE__buffer_target" || return $?
				PRINT_STYLE__buffer_left=''
				__value_to_target "${PRINT_STYLE__item_begin}${PRINT_STYLE__item_content}${PRINT_STYLE__item_end}" "$PRINT_STYLE__item_target" || return $?
			else
				PRINT_STYLE__buffer_left+="${PRINT_STYLE__item_begin}${PRINT_STYLE__item_content}${PRINT_STYLE__item_end}"
			fi
		fi
	done

	# close the buffer
	if [[ $PRINT_STYLE__trail == 'yes' ]]; then
		PRINT_STYLE__buffer_right+=$'\n'
	fi
	__value_to_target "${PRINT_STYLE__buffer_left}${PRINT_STYLE__buffer_disable}${PRINT_STYLE__buffer_right}" "$PRINT_STYLE__buffer_target" || return $?
}

# beta command, will change
# trunk-ignore(shellcheck/SC2120)
function __print_help {
	__load_styles --save -- intensity bold dim code foreground_magenta foreground_green foreground_red
	cat |
		echo-regexp -gm '^([\t ]*)[-*] ' '$1• ' |
		echo-regexp -gm '^([A-Z ]+\:)$' "${STYLE__foreground_magenta}\$1${STYLE__END__foreground_magenta}" |
		echo-regexp -gm '^( *)([[<\-a-z][{}()[\]<>\-._:$'\''=*`?/| a-zA-Z0-9]+)$' "${STYLE__foreground_magenta}\$1\$2${STYLE__END__foreground_magenta}" |
		echo-regexp -g '\[0\](\s)' "${STYLE__foreground_green}[0]${STYLE__END__foreground_green}\$1" |
		echo-regexp -g '\[([\d]+)\](\s)' "${STYLE__foreground_red}[\$1]${STYLE__END__foreground_red}\$2" |
		{
			local buffer='' character='' buffer='' last='' in_tick='no' in_color='no' intensities=()
			local -i c l
			while LC_ALL=C IFS= read -rd '' -n1 character || [[ -n $character ]]; do
				if [[ $character == $'\e' ]]; then
					in_color='yes'
					buffer+="${character}"
				elif [[ $in_color == 'yes' ]]; then
					if [[ $character == 'm' ]]; then
						in_color='no'
					fi
					buffer+="${character}"
				elif [[ $character == '`' ]]; then
					if [[ $in_tick == 'no' ]]; then
						in_tick='yes'
						buffer+="${STYLE__code}"
					else
						in_tick='no'
						buffer+="${STYLE__END__code}"
					fi
				elif [[ $character == '<' ]]; then
					intensities+=("$STYLE__bold")
					buffer+="${STYLE__bold}${character}"
				elif [[ $character == '[' ]]; then
					intensities+=("$STYLE__dim")
					buffer+="${STYLE__dim}${character}"
				elif [[ $character == '>' || $character == ']' ]]; then
					buffer+="${character}"

					# there's currently a bug in __slice that prevents -1 being used as a length
					# __dump {intensities} >&2
					# __slice --source+target={intensities} --mode=overwrite 0 -1 || return $?
					# __dump {intensities} >&2

					c="${#intensities[@]}"
					if [[ $c -eq 0 ]]; then
						# this is probably malformed syntax, or something like this from `fs-copy`:
						# Enable SSH on macOS via \`System Preferences > Sharing > Remote Login\`.
						# @todo figure out why the first > there drops the backtick intensity
						continue
					fi

					# pop off the last intensity as it is now finished
					if [[ $c -eq 1 ]]; then
						intensities=()
					else
						l="$((c - 1))"
						intensities=("${intensities[@]:0:l}")
						l="$((l - 1))"
					fi

					# re-affirm the prior intensity
					if [[ ${#intensities[@]} -eq 0 ]]; then
						buffer+="${STYLE__END__intensity}"
					else
						# __slice --source={intensities} --target={last} -1 || return $?
						last="${intensities[l]}"
						buffer+="${STYLE__END__intensity}${last}"
					fi
				else
					buffer+="${character}"
				fi
			done
			__print_lines "$buffer" >&2 || return $?
		}
	if [[ $# -ne 0 ]]; then
		__print_line || return $?
		__print_error "$@" || return $?
	fi
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
