#!/usr/bin/env bash
# do not use `export` keyword in this file:
# shellcheck disable=SC2034

# Used by `echo-style`

# colors which will be sought later
# https://en.wikipedia.org/wiki/ANSI_escape_code#Colors
# https://gist.github.com/Prakasaka/219fe5695beeb4d6311583e79933a009
# https://mywiki.wooledge.org/BashFAQ/037

# foreground
foreground_black=$'\e[30m'   # tput setaf 0
foreground_red=$'\e[31m'     # tput setaf 1
foreground_green=$'\e[32m'   # tput setaf 2
foreground_yellow=$'\e[33m'  # tput setaf 3
foreground_blue=$'\e[34m'    # tput setaf 4
foreground_magenta=$'\e[35m' # tput setaf 5
foreground_cyan=$'\e[36m'    # tput setaf 6
foreground_white=$'\e[37m'   # tput setaf 7
foreground_purple="$foreground_magenta"
foreground_gray="$foreground_white"
foreground_grey="$foreground_white"

# foreground_intense
foreground_intense_black=$'\e[90m'   # tput setaf 8
foreground_intense_red=$'\e[91m'     # tput setaf 9
foreground_intense_green=$'\e[92m'   # tput setaf 10
foreground_intense_yellow=$'\e[93m'  # tput setaf 11
foreground_intense_blue=$'\e[94m'    # tput setaf 12
foreground_intense_magenta=$'\e[95m' # tput setaf 13
foreground_intense_cyan=$'\e[96m'    # tput setaf 14
foreground_intense_white=$'\e[97m'   # tput setaf 15
foreground_intense_purple="$foreground_intense_magenta"
foreground_intense_gray="$foreground_intense_white"
foreground_intense_grey="$foreground_intense_white"

# background
background_black=$'\e[40m'   # tput setab 0
background_red=$'\e[41m'     # tput setab 1
background_green=$'\e[42m'   # tput setab 2
background_yellow=$'\e[43m'  # tput setab 3
background_blue=$'\e[44m'    # tput setab 4
background_magenta=$'\e[45m' # tput setab 5
background_cyan=$'\e[46m'    # tput setab 6
background_white=$'\e[47m'   # tput setab 7
background_purple="$background_magenta"
background_gray="$background_white"
background_grey="$background_white"

# background_intense
background_intense_black=$'\e[100m'   # tput setab 8
background_intense_red=$'\e[101m'     # tput setab 9
background_intense_green=$'\e[102m'   # tput setab 10
background_intense_yellow=$'\e[103m'  # tput setab 11
background_intense_blue=$'\e[104m'    # tput setab 12
background_intense_magenta=$'\e[105m' # tput setab 13
background_intense_cyan=$'\e[106m'    # tput setab 14
background_intense_white=$'\e[107m'   # tput setab 15
background_intense_purple="$background_intense_magenta"
background_intense_gray="$background_intense_white"
background_intense_grey="$background_intense_white"

# modes
# https://en.wikipedia.org/wiki/ANSI_escape_code#SGR_(Select_Graphic_Rendition)_parameters
reset=$'\e[0m'                    # tput sgr0
bold=$'\e[1m'                     # tput bold
dim=$'\e[2m'                      # tput dim
italic=$'\e[3m'                   # not widely supported
underline=$'\e[4m'                # tput sgr 0 1
blink=$'\e[5m'                    # tput blink
invert=$'\e[7m'                   # tput rev
conceal=$'\e[8m'                  #
strike=$'\e[9m'                   # not widely supported
double_underline=$'\e[21m'        #
disable_intensity=$'\e[22m'       #
disable_bold="$disable_intensity" #
disable_dim="$disable_intensity"  #
disable_italic=$'\e[23m'          #
disable_underline=$'\e[24m'       #
disable_blink=$'\e[25m'           #
disable_invert=$'\e[27m'          #
disable_conceal=$'\e[28m'         #
reveal="$disable_conceal"         #
disable_strike=$'\e[29m'          #
disable_foreground=$'\e[39m'      #
disable_background=$'\e[49m'      #
framed=$'\e[51m'                  # not widely supported
circled=$'\e[52m'                 # not widely supported
overlined=$'\e[53m'               # not widely supported
disable_framed=$'\e[54m'          #
disable_circled="$disable_framed" #
disable_overlined=$'\e[55m'       #

# If italics is not supported, swap it with something else...
# Values of TERM_PROGRAM that are known to not support italics:
# - Apple_Terminal
# As italics support is rare, do the swap if not in a known terminal that supports italics....
if ! [[ ${TERM_PROGRAM-} =~ Hyper|tmux|vscode ]]; then
	# do not use underline, as it makes a mess, an underlined | or , or space is not pretty
	# italic="$dim"
	# disable_italic="$disable_dim"
	italic="$foreground_intense_white"
	disable_italic="$disable_foreground"
fi

# modes that aren't implemented by operating systems
# blink_fast=$'\e[6m'

# styles
h1="${invert}"
e1="${background_red}${foreground_intense_white}"
g1="${background_intense_green}${foreground_black}"
n1="${background_intense_yellow}${foreground_black}"
h2="${bold}${underline}"
g2="${h2}${foreground_green}"
e2="${h2}${foreground_red}"
n2="${h2}${foreground_yellow}"
h3="${bold}"
g3="${h3}${foreground_green}"
e3="${h3}${foreground_red}"
n3="${h3}${foreground_yellow}"
header="${bold}${underline}"
error="${background_intense_red}${foreground_intense_white}"
success="${foreground_green}${bold}"
positive="${foreground_green}${bold}"
negative="${foreground_red}${bold}"
notice="${h2}${foreground_intense_yellow}"
warning="${e2}"
code="${dim}"
# don't use intense_yellow as it is unreadable on light terminal themes, plain yellow works for light and dark themes
# g1="${background_green}${intense_white}"

# redacted, alternative to conceal, which respects color themes
redacted="${background_black}${foreground_black}"

# don't use these in segments, as it prohibits alternative usage
# instead, when things take a long time,
# output a long time messasge after the segment
# ⏲
# ✅
# ❌

# level 1 wrappers
h1_open="${reset}${h1}┌  ${reset}"
h1_close="${reset}${h1}  ┐${reset}"
g1_open="${reset}${g1}└  ${reset}"
g1_close="${reset}${g1}  ┘${reset}"
e1_open="${reset}${e1}└  ${reset}"
e1_close="${reset}${e1}  ┘${reset}"
n1_open="${reset}${n1}└  ${reset}"
n1_close="${reset}${n1}  ┘${reset}"

# level 2 wrappers
h2_open="${reset}${bold}┌  ${reset}"
h2_close="${reset}${bold}  ┐${reset}"
g2_open="${reset}${bold}${foreground_green}└  ${reset}"
g2_close="${reset}${bold}${foreground_green}  ┘${reset}"
e2_open="${reset}${bold}${foreground_red}└  ${reset}"
e2_close="${reset}${bold}${foreground_red}  ┘${reset}"
n2_open="${reset}${bold}${foreground_yellow}└  ${reset}"
n2_close="${reset}${bold}${foreground_yellow}  ┘${reset}"

# level 3 wrappers
h3_open="${reset}┌  ${reset}"
h3_close="${reset}  ┐${reset}"
g3_open="${reset}${foreground_green}└  ${reset}"
g3_close="${reset}${foreground_green}  ┘${reset}"
e3_open="${reset}${foreground_red}└  ${reset}"
e3_close="${reset}${foreground_red}  ┘${reset}"
n3_open="${reset}${foreground_yellow}└  ${reset}"
n3_close="${reset}${foreground_yellow}  ┘${reset}"

# element wrappers
element_open="${reset}${dim}${bold}< ${reset}"
element_close="${reset}${dim}${bold} >${reset}"
element_slash_open="${reset}${dim}${bold}</ ${reset}"
element_slash_close="${reset}${dim}${bold} />${reset}"

# the resets allow these to work:
# echo-style --h1_open --h1='Setup Python' --h1_close $'\n' --g1_open --g1='Setup Python' --g1_close
# echo-style --element_slash_open --h3="this should not be dim" --element_slash_close "$status"
