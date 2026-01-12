#!/usr/bin/env bash

if [[ $1 == '--' ]]; then
	shift
fi
if [[ $# -eq 0 ]]; then
	exit 22 # EINVAL 22 Invalid argument
fi
if [[ $OSTYPE == darwin* ]]; then # see `__is_macos` for details
	function __get_owner {
		stat -Lf '%u %Su %g %Sg' -- "$1"
	}
else
	function __get_owner {
		stat -Lc '%u %U %g %G' -- "$1"
	}
fi
while [[ $# -ne 0 ]]; do
	if [[ -z $1 ]]; then
		exit 22 # EINVAL 22 Invalid argument
	fi
	path="$1"
	shift

	# checks
	is-present.bash -- "$path" || exit $?
	__get_owner "$path" || {
		status=$?
		printf '%s\n' "$path" >>"$TMPDIR/is-fs-failed-paths"
		exit "$status"
	}
done
exit 0
