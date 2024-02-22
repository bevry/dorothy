#!/usr/bin/env bash

if test -z "${RIPGREP_BIN_PATH-}"; then
	# install ripgrep
	setup-util-ripgrep --quiet

	# workaround for ripgrep outputting colors in pipes
	function rg {
		local ripgrep_bin_path
		ripgrep_bin_path="$(type -P rg)"
		if test -z "$ripgrep_bin_path"; then
			echo-style --error='ripgrep is required to continue, and was not able to be auto-installed.' ' ' --notice='Install it with:' ' ' --code='setup-util-ripgrep' >/dev/stderr
			return 74 # EPROGUNAVAIL 74 RPC prog. not avail
		fi
		"$ripgrep_bin_path" --no-line-number --color never "$@"
	}
fi
