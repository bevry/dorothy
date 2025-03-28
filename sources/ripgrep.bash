#!/usr/bin/env bash

if [[ -z ${RIPGREP_BIN_PATH-} ]]; then
	# install ripgrep
	setup-util-ripgrep --quiet

	# workaround for ripgrep outputting colors in pipes
	function rg {
		local ripgrep_bin_path
		ripgrep_bin_path="$(type -P rg)"
		if [[ -z $ripgrep_bin_path ]]; then
			echo-style --stderr --error1='ripgrep is required to continue, and was not able to be auto-installed.' --notice1=' Install it with: ' --code-notice1='setup-util-ripgrep'
			return 74 # EPROGUNAVAIL 74 RPC prog. not avail
		fi
		"$ripgrep_bin_path" --no-line-number --color never "$@"
	}
fi
