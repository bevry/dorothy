#!/usr/bin/env sh

secure_history() {
	action="$(
		choose \
			--question='What do you want to delete?' \
			--default="${1-}" --label -- \
			'some' 'delete only the known risks' 'all' 'erase your entire history'
	)"
	if [ "$action" = 'erase your entire history' ]; then
		history -c
		printf '%s\n' 'Erased everything.'
	else
		printf '%s\n' 'Erasing only known risks is not supported in shells that are not Fish.' >&2
		return 1
	fi
}
