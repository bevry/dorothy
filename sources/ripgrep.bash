#!/usr/bin/env bash

if test -z "${RIPGREP_BIN_PATH-}"; then
	# install ripgrep
	setup-util-ripgrep --quiet

	# workaround for ripgrep outputting colors in pipes
	function rg {
		local ripgrep_bin_path
		ripgrep_bin_path="$(type -P rg)"
		"$ripgrep_bin_path" --no-line-number --color never "$@"
	}
fi
