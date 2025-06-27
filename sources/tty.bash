#!/usr/bin/env bash

dorothy-warnings add --code='tty.bash' --bold=' has been deprecated in favor of ' --code='get-terminal-*' --bold=' commands'

if get-terminal-tty-support --quiet; then
	function tty_start {
		dorothy-warnings add --code='tty_start' --bold=' has been deprecated in favor of ' --code='echo-style --no-trail --tty --alternative-screen-buffer'
		{
			tput smcup >/dev/tty && tput cup 0 0 >/dev/tty
		} || tput clear >/dev/tty
	}
	function tty_clear {
		dorothy-warnings add --code='tty_clear' --bold=' has been deprecated in favor of ' --code='echo-style --no-trail --tty --clear-screen'
		tput clear >/dev/tty # also resets cursor to top
	}
	function tty_finish {
		dorothy-warnings add --code='tty_clear' --bold=' has been deprecated in favor of ' --code='echo-style --no-trail --tty --default-screen-buffer'
		tput rmcup >/dev/tty || tput clear >/dev/tty
	}
	function tty_auto {
		dorothy-warnings add --code='tty_auto' --bold=' has been deprecated in favor of ' --code='echo-style --no-trail --tty --alternative-screen-buffer' --bold=' and ' --code='echo-style --no-trail --tty --default-screen-buffer'
		trap tty_finish EXIT
	}
else
	function tty_start {
		dorothy-warnings add --code='tty_start' --bold=' has been deprecated in favor of ' --code='echo-style --no-trail --tty --alternative-screen-buffer'
		return 0
	}
	function tty_clear {
		dorothy-warnings add --code='tty_clear' --bold=' has been deprecated in favor of ' --code='echo-style --no-trail --tty --clear-screen'
		return 0
	}
	function tty_finish {
		dorothy-warnings add --code='tty_clear' --bold=' has been deprecated in favor of ' --code='echo-style --no-trail --tty --default-screen-buffer'
		return 0
	}
	function tty_auto {
		dorothy-warnings add --code='tty_auto' --bold=' has been deprecated in favor of ' --code='echo-style --no-trail --tty --alternative-screen-buffer' --bold=' and ' --code='echo-style --no-trail --tty --default-screen-buffer'
		return 0
	}
fi

# -------------------------------------
# The below methods are only useful if the y is below $LINES
# In other words, if the scroll buffer has not been and will not be reached.
# As such, these are prone to failure, and you should use the earlier methods instead.
# https://stackoverflow.com/a/69138082/130638

function tty_get_y_x {
	dorothy-warnings add --code='tty_get_y_x' --bold=' has been deprecated in favor of ' --code='get-terminal-cursor-line-and-column'
	local y x
	IFS='[;' read -srd R -p $'\e[6n' _ y x </dev/tty
	printf '%s\n' "$y"
	printf '%s\n' "$x"
}

function tty_set_y_x {
	dorothy-warnings add --code='tty_get_y_x' --bold=' has been been removed, use the ansi escape code directly.'
	local y x yx=()
	if [[ $# -eq 0 ]]; then
		__split --target={yx} --no-zero-length --invoke -- \
			tty_get_y_x
		y="${yx[0]}"
		x="${yx[1]}"
	else
		y="${1-}"
		x="${2-}"
	fi
	printf "\e[${y};${x}H" >/dev/tty
}

function tty_erase_to_end {
	dorothy-warnings add --code='tty_get_y_x' --bold=' has been been removed, use the appropriate ansi escape code directly.'
	printf '\e[J' >/dev/tty
}

function tty_erase_from_y_x {
	dorothy-warnings add --code='tty_get_y_x' --bold=' has been been removed, use the appropriate ansi escape code directly.'
	tty_set_y_x "${1-}" "${2-}"
	tty_erase_to_end
}
