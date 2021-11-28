#!/usr/bin/env bash
# shellcheck disable=SC2034
# do not use `export` keyword in this file

# colors which will be sought later
# https://en.wikipedia.org/wiki/ANSI_escape_code#Colors
# https://gist.github.com/Prakasaka/219fe5695beeb4d6311583e79933a009
# https://mywiki.wooledge.org/BashFAQ/037

# foreground
black=$'\e[30m'   # tput setaf 0
red=$'\e[31m'     # tput setaf 1
green=$'\e[32m'   # tput setaf 2
yellow=$'\e[33m'  # tput setaf 3
blue=$'\e[34m'    # tput setaf 4
magenta=$'\e[35m' # tput setaf 5
cyan=$'\e[36m'    # tput setaf 6
white=$'\e[37m'   # tput setaf 7
purple="$magenta"
gray="$white"
grey="$white"

# intense_foreground
intense_black=$'\e[90m'   # tput setaf 8
intense_red=$'\e[91m'     # tput setaf 9
intense_green=$'\e[92m'   # tput setaf 10
intense_yellow=$'\e[93m'  # tput setaf 11
intense_blue=$'\e[94m'    # tput setaf 12
intense_magenta=$'\e[95m' # tput setaf 13
intense_cyan=$'\e[96m'    # tput setaf 14
intense_white=$'\e[97m'   # tput setaf 15
intense_purple="$intense_magenta"
intense_gray="$intense_white"
intense_grey="$intense_white"

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
reset=$'\e[0m'                       # tput sgr0
bold=$'\e[1m'                        # tput bold
dim=$'\e[2m'                         # tput dim
italic=$'\e[3m'                      #
underline=$'\e[4m'                   # tput sgr 0 1
blink=$'\e[5m'                       # tput blink
invert=$'\e[7m'                      # tput rev
conceal=$'\e[8m'                     #
strike=$'\e[9m'                      # not widely supported
double_underline=$'\e[21m'           #
disable_intensity=$'\e[22m'          #
disable_italic=$'\e[23m'             #
disable_underline=$'\e[24m'          #
disable_blink=$'\e[25m'              #
disable_invert=$'\e[27m'             #
disable_conceal=$'\e[28m'            #
reveal="$disable_conceal"            #
disable_strike=$'\e[29m'             #
disable_foreground_color=$'\e[39m'   #
disable_background_color=$'\e[49m'   #
framed=$'\e[51m'                     # not widely supported
circled=$'\e[52m'                    # not widely supported
overlined=$'\e[53m'                  # not widely supported
disable_framed_and_circled=$'\e[54m' #
disable_overlined=$'\e[55m'          #

# modes that aren't implemented by operating systems
# blink_fast=$'\e[6m'

# styles
h1="${invert}"
e1="${background_red}${intense_white}"
#g1="${background_green}${intense_white}"
g1="${background_intense_green}${black}"
h2="${bold}${underline}"
g2="${h2}${green}"
e2="${h2}${red}"
h3="${bold}"
g3="${h3}${green}"
e3="${h3}${red}"
header="${bold}${underline}"
error="${background_intense_red}${intense_white}"
success="${green}${bold}"
notice="${intense_yellow}${bold}${underline}"
code="${dim}"

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

# level 2 wrappers
h2_open="${reset}${bold}┌  ${reset}"
h2_close="${reset}${bold}  ┐${reset}"
g2_open="${reset}${bold}${green}└  ${reset}"
g2_close="${reset}${bold}${green}  ┘${reset}"
e2_open="${reset}${bold}${red}└  ${reset}"
e2_close="${reset}${bold}${red}  ┘${reset}"

# level 3 wrappers
h3_open="${reset}┌  ${reset}"
h3_close="${reset}  ┐${reset}"
g3_open="${reset}${green}└  ${reset}"
g3_close="${reset}${green}  ┘${reset}"
e3_open="${reset}${red}└  ${reset}"
e3_close="${reset}${red}  ┘${reset}"

# element wrappers
element_open="${reset}${dim}${bold}< ${reset}"
element_close="${reset}${dim}${bold} >${reset}"
element_slash_open="${reset}${dim}${bold}</ ${reset}"
element_slash_close="${reset}${dim}${bold} />${reset}"

# the resets allow these to work:
# echo-style --h1_open --h1='Setup Python' --h1_close $'\n' --g1_open --g1='Setup Python' --g1_close
# echo-style --element_slash_open --h3="this should not be dim" --element_slash_close "$status"
