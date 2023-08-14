#!/usr/bin/env bash

if test -z "${RIPGREP_BIN_PATH-}"; then
	# install ripgrep
	setup-util-ripgrep --quiet

	# workaround for ripgrep outputting colors in pipes
	RIPGREP_BIN_PATH="$(command -v rg)"
	function rg {
		"$RIPGREP_BIN_PATH" --no-line-number --color never "$@"
	}
fi
