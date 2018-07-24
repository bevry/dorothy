#!/usr/bin/env bash

function vset {
	# make it available immediately
	var_set "$1" "$2"

	# output it for evaluation later
	echo "var_set \"$1\" \"$2\";"  # ; needed for fish
}

function vadd {
	# make it available immediately
	var_add "$1" "$2"

	# output it for evaluation later
	echo "var_add \"$1\" \"$2\";"  # ; needed for fish
}

function var_set {
	export "$1"="$2"
}

function var_add {
	local exists="no"
	local X="${!1}"
	if test -z "$X"; then
		export "$1"="$2"
	else
		local Y="${X//:/\\n}"
		while read -r line; do
			if test "$line" = "$2"; then
				exists="yes"
				break
			fi
		done < <(echo -e "$Y")

		if test "$exists" = "no"; then
			export "$1"="$2":"${!1}"
		fi
	fi
}
