#!/usr/bin/env bash

if test -z "${RIPGREP_BIN_PATH-}"; then
	# install ripgrep
	setup-util-ripgrep --quiet || {
		ec="$?"
		echo "setup-util-ripgrep failed with exit code $ec" >/dev/stderr
		echo "cannot proceed with: $0 $*" >/dev/stderr
		return "$ec"
	}

	# workaround for ripgrep outputting colors in pipes
	RIPGREP_BIN_PATH="$(command -v rg)"
	function rg {
		"$RIPGREP_BIN_PATH" --no-line-number --color never "$@"
	}
fi
