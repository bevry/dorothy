#!/usr/bin/env bash
# do not use `export` keyword in this file:
# shellcheck disable=SC2034

# Used by `echo-style`

# https://en.wikipedia.org/wiki/ANSI_escape_code#Colors
# https://gist.github.com/Prakasaka/219fe5695beeb4d6311583e79933a009
# https://mywiki.wooledge.org/BashFAQ/037

#######################################
# ANSI STYLES #########################

# erasure
style__delete_line=$'\e[F\e[J'
style__erase_screen=$'\e[H\e[2J'
style__hide_cursor=$'\e[?25l'
style__show_cursor=$'\e[?25h'
style__bell=$'\a'

# modes
style__color_end__intensity=$'\e[22m'  #
style__color_end__foreground=$'\e[39m' #
style__color_end__background=$'\e[49m' #
# https://en.wikipedia.org/wiki/ANSI_escape_code#SGR_(Select_Graphic_Rendition)_parameters
# echo-style --bold=bold --dim=dim --italic=italic 'standard' --underline=underline --blink=blink --invert=invert --conceal=conceal --strike=strike --framed=framed --circled=circled --overlined=overlined standard
style__color__reset=$'\e[0m' # tput sgr0
style__color__bold=$'\e[1m'  # tput bold [supported: Terminal, VSCode, Alacritty, Hyper, Wave, Warp, iTerm2, Tabby, Kitty] [buggy support: Rio] [unsupported: cool-retro-term, Wez, Extratern, Contour]
style__color_end__bold="$style__color_end__intensity"
style__color__dim=$'\e[2m' # tput dim [supported: Terminal, VSCode, Alacritty, Hyper, Wave, Warp, iTerm2, Tabby, Wez, Contour, Kitty] [unsupported: cool-retro-term, Extraterm, Rio]
style__color_end__dim="$style__color_end__intensity"
style__color__italic=$'\e[3m' # [supported: VScode, Hyper, Terminal] [colored support: Alacritty, Wave, iTerm2, Tabby, Wez, Extraterm, Contour, Kitty] [unsupported: Warp, cool-retro-term, Rio] - note that Monaspace fonts may appear to having working italic in macOS Terminal, however that is because it by default chooses italic for the generic style so everything is italic
style__color_end__italic=$'\e[23m'
style__color__underline=$'\e[4m' # tput sgr 0 1 [supported: Terminal, VSCode, Alacritty, Hyper, cool-retro-term, Wave, Warp, iTerm2, Tabby, Wez, Extraterm, Rio, Contour, Kitty] [unsupported: -]
style__color_end__underline=$'\e[24m'
style__color__double_underline=$'\e[21m' # [supported: Tabby]
style__color_end__double_underline=$'\e[24m'
style__color__blink=$'\e[5m' # tput blink [supported: Terminal, VSCode, Alacritty, Hyper, Contour] [fade-in-out support: Wez, cool-retro-term] [unsupported: Wave, Warp, iTerm2, Tabby, Extraterm, Rio, Kitty]
style__color_end__blink=$'\e[25m'
style__color__invert=$'\e[7m' # tput rev [supported: Terminal, VSCode, Alacritty, Hyper, cool-retro-arm, Wave, Warp, iTerm2, Tabby, Wez, Extraterm, Rio, Contour, Kitty] [unsupported: -]
style__color_end__invert=$'\e[27m'
style__color__conceal=$'\e[8m' # [supported: Terminal, VSCode, Alacritty, Hyper, iTerm2, Tabby, Wez, Rio, Contour] [unsupported: cool-retro-term, Wave, Warp, Extraterm, Kitty]
style__color_end__conceal=$'\e[28m'
style__color__strike=$'\e[9m' # [supported: VSCode, Alacritty, Hyper, Wave, Warp, iTerm2, Tabby, Wez, Extraterm, Rio, Contour, Kitty] [unsupported: cool-retro-term]
style__color_end__strike=$'\e[29m'
style__color__framed=$'\e[51m' # [frames each character: Contour] [unsupported: everything else]
style__color_end__framed=$'\e[54m'
style__color__circled=$'\e[52m' # [supported: none known]
style__color_end__circled="$style__color_end__framed"
style__color__overlined=$'\e[53m' # [supported: Tabby, Wez, Extratern, Contour] [unsupported: everything else]
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

# If italics is not supported, swap it with something else...
# Values of TERM_PROGRAM that are known to not support italics:
# - Apple_Terminal
# As italics support is rare, do the swap if not in a known terminal that supports italics....
if ! [[ ${TERM_PROGRAM-} =~ ^(Hyper|tmux|vscode)$ ]]; then
	# do not use underline, as it makes a mess, an underlined | or , or space is not pretty
	# style__color__italic="$style__color__dim"
	# style__color_end__italic="$style__color_end__dim"
	style__color__italic="$style__color__foreground_intense_white"
	style__color_end__italic="$style__color_end__foreground"
fi

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
style__color__good1="${style__color__background_intense_green}${style__color__foreground_black}"
style__color_end__good1="${style__color_end__background}${style__color_end__foreground}"
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
style__color__sudo="${style__color__foreground_intense_yellow}"
style__color_end__sudo="${style__color_end__foreground}"
style__color__code="${style__color__dim}"
style__color_end__code="${style__color_end__intensity}"
# do not add a code-notice style that is just yellow text, as it is not better than just a standard code style as it doesn't distinguish itself enough, instead do a notice1 and code-notice1 style
style__color__code_dim="${style__color__dim}${style__color__foreground_gray}"
style__color_end__code_dim="${style__color_end__intensity}${style__color_end__foreground}"
if test -n "${GITHUB_ACTIONS-}"; then
	style__color__header1="${style__color__background_intense_white}${style__color__foreground_black}"
	style__color_end__header1="${style__color_end__background}${style__color_end__foreground}"
	style__color__error1="${style__color__background_red}${style__color__foreground_black}"
	style__color_end__error1="${style__color_end__background}${style__color_end__foreground}"
	style__color__error="${style__color__background_red}${style__color__foreground_black}"
	style__color_end__error="${style__color_end__background}${style__color_end__foreground}"
elif test "$(get-terminal-theme || :)" = 'light'; then
	# trim style__color__foreground_intense_yellow as it is unreadable on light theme
	style__color__notice="${style__color__bold}${style__color__underline}${style__color__foreground_yellow}"
	style__color_end__notice="${style__color_end__intensity}${style__color_end__underline}${style__color_end__foreground}"
	style__color__sudo="${style__color__foreground_yellow}"
	style__color_end__sudo="${style__color_end__foreground}"
else
	# on dark theme on vscode
	# style__color__background_intense_red forces black foreground, which black on red is unreadable, so adjust
	if test "${TERM_PROGRAM-}" = vscode; then
		style__color__error="${style__color__background_red}${style__color__foreground_intense_white}"
		style__color_end__error="${style__color_end__background}${style__color_end__foreground}"
	fi
fi

# don't use these in segments, as it prohibits alternative usage
# instead, when things take a long time,
# output a long time messasge after the segment
# ⏲
# ✅
# ❌

# level 1 wrappers
# hN = header level N
# gN = good level N (use to close a header element)
# eN = error level N (use to close a header element)
# nN = notice level N (use to close a header element)
style__nocolor__h1=$'\n┌  '
style__nocolor_end__h1='  ┐'
style__color__h1=$'\n'"${style__color__header1}┌  "
style__color_end__h1="  ┐${style__color_end__header1}"

style__nocolor__g1='└  '
style__nocolor_end__g1='  ┘'
style__color__g1="${style__color__good1}└  "
style__color_end__g1="  ┘${style__color_end__good1}"

style__nocolor__e1='└  '
style__nocolor_end__e1='  ┘'
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

style__nocolor__g2='└  '
style__nocolor_end__g2='  ┘'
style__color__g2="${style__color__reset}${style__color__bold}${style__color__foreground_green}└  "
style__color_end__g2="  ┘${style__color__reset}"

style__nocolor__e2='└  '
style__nocolor_end__e2='  ┘'
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

style__nocolor__g3='└  '
style__nocolor_end__g3='  ┘'
style__color__g3="${style__color__reset}${style__color__foreground_green}└  "
style__color_end__g3="  ┘${style__color__reset}"

style__nocolor__e3='└  '
style__nocolor_end__e3='  ┘'
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

# confirm/choose/ask failures
style__color__input_warning="${style__color__bold}${style__color__foreground_yellow}"
style__color_end__input_warning="${style__color_end__bold}${style__color_end__foreground_yellow}"
# notice and warning too much emphasis on something with fallback

# style__color__input_error="${style__color__bold}${style__color__foreground_red}"
# style__color_end__input_error="${style__color_end__bold}${style__color_end__foreground_red}"
style__color__input_error="${style__color__error1}"
style__color_end__input_error="${style__color_end__error1}"

# confirm/choose/ask text
style__icon_nothing_provided='[ nothing provided ]'
style__icon_no_selection='[ no selection ]'         # used while choosing
style__icon_nothing_selected='[ nothing selected ]' # used in result
style__icon_using_password='[ using the entered password ]'

# ask icons
style__icon_prompt='> '

# confirm icons
style__color__icon_question_positive="${style__color__blink}(${style__color__bold}${style__color__foreground_green}Y${style__color_end__foreground}${style__color_end__bold}/n)${style__color_end__blink}"
style__nocolor__icon_question_positive='(Y/n)'

style__color__icon_question_negative="${style__color__blink}(y/${style__color__bold}${style__color__foreground_red}N${style__color_end__foreground}${style__color_end__bold})${style__color_end__blink}"
style__nocolor__icon_question_negative='(y/N)'

style__color__icon_question_bool="${style__color__blink}(y/n)${style__color_end__blink}"
style__nocolor__icon_question_bool='(y/n)'

style__color__icon_question_confirm="${style__color__blink}(CONFIRM)${style__color_end__blink}"
style__nocolor__icon_question_confirm='(CONFIRM)'

# confirm results
style__color__result_positive="${style__color__bold}${style__color__foreground_green}"
style__color_end__result_positive="${style__color_end__foreground}${style__color_end__bold}"

style__color__result_negative="${style__color__bold}${style__color__foreground_red}"
style__color_end__result_negative="${style__color_end__foreground}${style__color_end__bold}"

style__color__result_abort="${style__color__bold}${style__color__foreground_red}"
style__color_end__result_abort="${style__color_end__foreground}${style__color_end__bold}"

# ask resuktls
style__color__result_value="${style__color__dim}"
style__color_end__result_value="${style__color_end__dim}"

# for input result indentation, it doesn't make sense:
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

# spacers
style__legend_legend_spacer='  '
style__legend_key_spacer=' '
style__key_key_spacer=' '
style__indent_bar='   '
style__indent_active='⏵  '
style__indent_inactive='   '
style__nocolor__indent_subsequent='   │ '
style__color__indent_subsequent="   ${style__color__dim}│ ${style__color_end__dim}"
style__nocolor__count_spacer=' ∙ '
style__color__count_spacer=" ${style__color__foreground_intense_black}∙${style__color_end__foreground} "

# legend
style__color__legend="$style__color__dim" # dim is better than white, nice separation
style__color_end__legend="$style__color_end__intensity"
style__color__key="${style__color__foreground_black}${style__color__background_white} "
style__color_end__key=" ${style__color_end__foreground}${style__color_end__background}"
style__nocolor__key='['
style__nocolor_end__key=']'

# paging counts
style__color__count_more="$style__color__foreground_white"
style__color_end__count_more="$style__color_end__foreground"
style__color__count_selected="$style__color__foreground_green"
style__color_end__count_selected="$style__color_end__foreground"
style__color__count_defaults="$style__color__foreground_yellow"
style__color_end__count_defaults="$style__color_end__foreground"
style__color__count_empty="$style__color__foreground_magenta"
style__color_end__count_empty="$style__color_end__foreground"

# paging headers
style__nocolor__bar_top='┌ '
style__nocolor_end__bar_top=' ┐'
style__nocolor__bar_middle='├ '
style__nocolor_end__bar_middle=' ┤'
style__nocolor__bar_bottom='└ '
style__nocolor_end__bar_bottom=' ┘'
style__color__bar_top="${style__color__foreground_intense_black}┌${style__color_end__foreground} "
style__color_end__bar_top=" ${style__color__foreground_intense_black}┐${style__color_end__foreground}"
style__color__bar_middle="${style__color__foreground_intense_black}├${style__color_end__foreground} "
style__color_end__bar_middle=" ${style__color__foreground_intense_black}┤${style__color_end__foreground}"
style__color__bar_bottom="${style__color__foreground_intense_black}└${style__color_end__foreground} "
style__color_end__bar_bottom=" ${style__color__foreground_intense_black}┘${style__color_end__foreground}"

# adjustments
if test "$(get-terminal-theme || :)" = 'light'; then
	# counts
	style__color__count_more="$style__color__foreground_intense_black"
	style__color_end__count_more="$style__color_end__foreground"
	# keys
	style__color__legend="$style__color__foreground_intense_black"
	style__color_end__legend="$style__color_end__foreground"
	style__color__key="${style__color__background_intense_white} "
	style__color_end__key="$style__color_end__background"
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
	while test $# -ne 0; do
		item="$1"
		shift
		case "$item" in
		--color=yes | --color) use_color='yes' ;;
		--color=no | --nocolor) use_color='no' ;;
		--) break ;;
		esac
	done
	if test -z "$use_color"; then
		if test -n "${USE_COLOR-}"; then
			use_color="$USE_COLOR"
		elif is-color-enabled --; then
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
		if test "$use_color" = 'yes'; then
			# begin
			var="style__color__${style}"
			if __is_var_set "$var"; then
				eval "style__${style}=\"\${!var}\""
				found='yes'
			else
				var="style__${style}"
				if __is_var_set "$var"; then
					# no need to update it
					found='yes'
				else
					var="style__nocolor__${style}"
					if __is_var_set "$var"; then
						eval "style__${style}=''"
						found='yes'
					fi
				fi
			fi

			# end
			var="style__color_end__${style}"
			if __is_var_set "$var"; then
				eval "style__end__${style}=\"\${!var}\""
				found='yes'
			else
				var="style__end__${style}"
				if __is_var_set "$var"; then
					# no need to updat eit
					found='yes'
				else
					var="style__nocolor_end__${style}"
					if __is_var_set "$var"; then
						eval "style__end__${style}=''"
						found='yes'
					fi
				fi
			fi
		else
			# begin
			var="style__nocolor__${style}"
			if __is_var_set "$var"; then
				eval "style__${style}=\"\${!var}\""
				found='yes'
			else
				var="style__${style}"
				if __is_var_set "$var"; then
					# no need to update it
					found='yes'
				else
					var="style__color__${style}"
					if __is_var_set "$var"; then
						eval "style__${style}=''"
						found='yes'
					fi
				fi
			fi

			# end
			var="style__nocolor_end__${style}"
			if __is_var_set "$var"; then
				eval "style__end__${style}=\"\${!var}\""
				found='yes'
			else
				var="style__end__${style}"
				if __is_var_set "$var"; then
					# no need to update it
					found='yes'
				else
					var="style__color_end__${style}"
					if __is_var_set "$var"; then
						eval "style__end__${style}=''"
						found='yes'
					fi
				fi
			fi
		fi
		# only respect found on versions of bash that can detect accurately detect it, as otherwise empty values will be confused as not found
		if test "$found" = 'no' -a "$IS_BASH_VERSION_OUTDATED" = 'no'; then
			echo-error "Style not found: $style"
			return 1
		fi
	done
}
