#!/usr/bin/env sh

secure_history () {
	action="$(choose-option --question='What do you want to delete?' --filter="${1-}" --label -- 'some' 'delete only the known risks' 'all' 'erase your entire history')"
	if test "$action" = 'erase your entire history'; then
		history -c
		echo 'Erased everything.'
	else
		stderr echo 'Erasing only known risks is not supported in shells that are not Fish.'
		return 1
	fi
}
