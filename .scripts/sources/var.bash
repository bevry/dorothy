#!/usr/bin/env bash

function var_set {
	export $1="$2"
}

function var_add {
	local exists="no"
	local X="${!1}"
	if test -z "$X"; then
		export $1="$2"
	else
		local Y="${X//:/\\n}"
		while read -r line; do
			if test "$line" = "$2"; then
				exists="yes"
				break
			fi
		done < <(echo -e "$Y")

		if test "$exists" = "no"; then
			export $1="$2":"${!1}"
		fi
	fi
}
