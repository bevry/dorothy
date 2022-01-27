#!/usr/bin/env bash
# shellcheck disable=SC2059
# ^ [echo -en] doesn't work with escape codes on bash v3, [printf ...] does

# -------------------------------------
# These create a new TTY that can be cleared without affecting the prior TTY.
# https://unix.stackexchange.com/a/668615/50703

tty_start() {
	tput smcup >/dev/tty
	tput cup 0 0 >/dev/tty
}

tty_clear() {
	tput clear >/dev/tty # also resets cursor to top
}

tty_finish() {
	# `tput rmcup` does not persist stderr, so for failure/stderr dumps, use `sleep 5` to ensure sterr is visible for long enough to be noticed before wiped.
	tput rmcup >/dev/tty
}

tty_auto() {
	tty_start
	trap tty_finish EXIT
}

# if alt tty is disabled however, then disable it
if is-affirmative "${NO_ALT_TTY-}" || test "$(echo-exit-code is-affirmative "${ALT_TTY-}")" -eq 1; then
	tty_start() {
		return
	}
	tty_clear() {
		return
	}
	tty_finish() {
		return
	}
	tty_auto() {
		return
	}
fi

# -------------------------------------
# The below methods are only useful if the y is below $LINES
# In other words, if the scroll buffer has not been and will not be reached.
# As such, these are prone to failure, and you should use the earlier methods instead.
# https://stackoverflow.com/a/69138082/130638

tty_get_y_x() {
	local y x
	IFS='[;' read -srd R -p $'\e[6n' _ y x </dev/tty
	echo "$y"
	echo "$x"
}

tty_set_y_x() {
	local y x
	if test "$#" -eq 0; then
		mapfile -t yx < <(tty_get_y_x)
		y="${yx[0]}"
		x="${yx[1]}"
	else
		y="${1-}"
		x="${2-}"
	fi
	printf "\e[${y};${x}H" >/dev/tty
}

tty_erase_to_end() {
	printf "\e[J" >/dev/tty
}

tty_erase_from_y_x() {
	tty_set_y_x "${1-}" "${2-}"
	tty_erase_to_end
}
