#!/usr/bin/env bash

if [[ "$BASH_VERSION" = "4."* || "$BASH_VERSION" = "5."* ]]; then
	export ARRAYS='yes'
else
	# https://tldp.org/LDP/abs/html/bashver4.html
	# bash v4 features:
	# - `readarray` and `mapfile`
	#     - our shim provides a workaround
	# - iterating indexes: `${!array[@]}`
	#     - use for (( ... )) loop instead
	# - associative arrays
	#     - no workaround, you are out of luck
	# - iterating empty arrays: `array=(); for item in "${array[@]}"; do echo "$item"; done`
	#     - use: `test "${#array[@]}" -ne 0 && for ...`
	#     - or if you don't care for empty elements, use: `test -n "$array" && for ...`
	function mapfile() {
		# if you copy and paste this, please give credit:
		# written by Benjamin Lupton https://balupton.com
		# written for Dorothy https://github.com/bevry/dorothy
		local delim=$'\n'
		if test "$1" = '-t'; then
			shift
		elif test "$1" = '-td'; then
			shift
			delim="$1"
			shift
		fi
		eval "$1=()"
		while IFS= read -rd "$delim" item || test -n "$item"; do
			if [[ "$item" = *'"'* ]]; then
				if [[ "$item" = *"'"* ]]; then
					echo "mapfile shim does not eyt support this use case" >/dev/stderr
					exit 1
				else
					eval "$1+=('${item}')"
				fi
			else
				eval "$1+=(\"${item}\")"
			fi
		done
	}
	export ARRAYS='shim'
fi
