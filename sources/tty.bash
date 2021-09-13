#!/usr/bin/env bash

# -------------------------------------
# These create a new TTY that can be cleared without affecting the prior TTY.
# https://unix.stackexchange.com/a/668615/50703

# tty_stderr_pipefile=''

#tty_stderr_pipefile="$(mktemp)"
# tty_stderr_fd="asdasdasd$RANDOM"
# mkfifo "$tty_stderr_fd"
tty_start () {
	# tty_stderr_pipefile="$(mktemp)"
	# readlink -f /proc/$$/fd/2
	# sleep 2
	tput smcup > /dev/tty
	tput cup 0 0 > /dev/tty
	# readlink -f /proc/$$/fd/2
	# sleep 2
	#tty_stderr_fd="$(readlink -f /proc/$$/fd/2)"
	#exec 5<&2
	#exec 5<&2
	#exec 2>>"$tty_stderr_pipefile"
	#exec 2> "$tty_stderr_pipefile"
	# exec "$tty_stderr_fd"<&2
	#exec 2> >(tee "$tty_stderr_pipefile" >&2)
	#exec 3>&2
}

tty_clear () {
	tput clear > /dev/tty # also resets cursor to top
}

tty_finish () {
	# `tput rmcup` also wipes stderr, so check if we have failed `exit 1`, if we have, then don't wipe anything
	#if test "$?" -eq 0; then
	#	tput rmcup > /dev/tty
	#fi
	tput rmcup > /dev/tty

	#exec 2>&3 3>&-
	#exec 2>&2
	#sleep 1
	#tput rmcup > /dev/tty
	# sleep 1
	# exec 2> /dev/sterr
	# cat "$tty_stderr_pipefile" > /dev/stderr
	# cat "$tty_stderr_pipefile" >&2
	# exec 2<&5 5>&-
	# exec 2>"$tty_stderr_fd"
	#echo "$tty_stderr_fd"
	#exec 2<&5
	#exec 5>&2
	#exec 5>&-
	#exec 2>&2
	#exec 2>&-
	#exec 5>&2
	#echo "echo$tty_stderr_pipefile" > /dev/stderr
	#cat "$tty_stderr_pipefile" > /dev/stderr
	# exec 2>&-
	# "$tty_stderr_fd" > /dev/stderr
	# echo "$tty_stderr_pipefile:[[[[" > /dev/stderr
	# cat "$tty_stderr_pipefile" > /dev/stderr
	# echo ']]]]' > /dev/stderr
	# rm "$tty_stderr_pipefile"
	# tty_stderr_pipefile=''
}

tty_auto () {
	tty_start
	trap tty_finish EXIT
}

# -------------------------------------
# The below methods are only useful if the y is below $LINES
# In other words, if the scroll buffer has not been and will not be reached.
# As such, these are prone to failure, and you should use the earlier methods instead.
# https://stackoverflow.com/a/69138082/130638

tty_get_y_x () {
	local y x
	IFS='[;' read -srd R -p $'\e[6n' _ y x < /dev/tty
	echo "$y"
	echo "$x"
}

tty_set_y_x () {
	local y x
	if test "$#" -eq 0; then
		mapfile -t yx < <(tty_get_y_x); y="${yx[0]}"; x="${yx[1]}"
	else
		y="${1-}"; x="${2-}"
	fi
	echo -en "\e[${y};${x}H" > /dev/tty
}

tty_erase_to_end () {
	echo -en "\e[J" > /dev/tty
}

tty_erase_from_y_x () {
	tty_set_y_x "${1-}" "${2-}"
	tty_erase_to_end
}

# -------------------------------------
# These are here for posterity, and will be removed.

# # https://stackoverflow.com/a/69138082/130638
# # https://unix.stackexchange.com/a/88304/50703
# # https://stackoverflow.com/a/2575525/130638
# # https://askubuntu.com/a/366158/22776
# # https://stackoverflow.com/a/5810220/130638
# # https://stackoverflow.com/a/2575525/130638
# get_tty_snapshot () {
# 	# local pos oldstty y x y_offset="${1:-0}" x_offset="${2:-0}"
# 	# exec < /dev/tty # use /dev/tty for the rest of this subshell
# 	# oldstty=$(stty -g) # save stty settings, why is this necessary?
# 	# stty raw -echo min 0 # suppress echo on terminal
# 	# echo -en "\e[6n" > /dev/tty # get cursor position: [[25;1R
# 	# IFS=';' read -rd 'R' -a pos  # read cursor position: [[25;1
# 	# stty "$oldstty" # restore stty settings
# 	# y="$((${pos[0]:2} - 2 + y_offset))" # get row from cursor position, [[25 => 25 - 2
# 	# x="$((pos[1] - 1 + x_offset))" # get column from cusor position
# 	# https://stackoverflow.com/a/52944692/130638
# 	local y x y_offset="${1:-0}" x_offset="${2:-0}"
# 	IFS='[;' read -srd R -p $'\e[6n' _ y x
# 	y="$((y + y_offset))"
# 	# x="$((x + x_offset))"
# 	# echo -e "y=$y x=$x"
# 	x=''
# 	echo -en "\e[${y};${x}H\e[J" # restore cursor position and clear to end of screen
# }
# use_tty_snapshot () {
# 	echo -en "$1" > /dev/tty
# }

# # # https://unix.stackexchange.com/a/88304/50703
# # # https://stackoverflow.com/a/2575525/130638
# # # https://askubuntu.com/a/366158/22776
# # # https://stackoverflow.com/a/5810220/130638
# # # https://stackoverflow.com/a/2575525/130638
# # get_tty_snapshot () {
# # 	# local pos oldstty y x y_offset="${1:-0}" x_offset="${2:-0}"
# # 	# exec < /dev/tty # use /dev/tty for the rest of this subshell
# # 	# oldstty=$(stty -g) # save stty settings, why is this necessary?
# # 	# stty raw -echo min 0 # suppress echo on terminal
# # 	# echo -en "\e[6n" > /dev/tty # get cursor position: [[25;1R
# # 	# IFS=';' read -rd 'R' -a pos  # read cursor position: [[25;1
# # 	# stty "$oldstty" # restore stty settings
# # 	# y="$((${pos[0]:2} - 2 + y_offset))" # get row from cursor position, [[25 => 25 - 2
# # 	# x="$((pos[1] - 1 + x_offset))" # get column from cusor position
# # 	# https://stackoverflow.com/a/52944692/130638
# # 	local y x y_offset="${1:-0}" x_offset="${2:-0}"
# # 	IFS='[;' read -srd R -p $'\e[6n' _ y x
# # 	y="$((y + y_offset))"
# # 	# x="$((x + x_offset))"
# # 	# echo -e "y=$y x=$x"
# # 	x=''
# # 	echo -en "\e[${y};${x}H\e[J" # restore cursor position and clear to end of screen
# # }
# # use_tty_snapshot () {
# # 	echo -en "$1" > /dev/tty
# # }
