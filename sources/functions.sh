#!/usr/bin/env sh

secure_history () {
	what="${1:-"$(choose 'delete only the known risks' 'erase your entire history')"}"
	if test "$what" = 'erase your entire history'; then
		history -c
		echo 'Erased everything.'
	else
		stderr echo 'Erasing only known risks is not supported in shells that are not Fish.'
		return 1
	fi
}
