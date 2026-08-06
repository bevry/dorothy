#!/usr/bin/env bash

if [[ $OSTYPE == darwin* ]]; then # see `__is_macos` for details
	function __get_owner {
		stat -Lf '%u %Su %g %Sg' -- "$1"
	}
else
	function __get_owner {
		stat -Lc '%u %U %g %G' -- "$1"
	}
fi

function __is_fs__operation {
	is-present.bash -- "$path" || return $?
	__get_owner "$path" || return $?
}

source "$DOROTHY/sources/is-fs-operation.bash"
