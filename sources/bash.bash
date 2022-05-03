#!/usr/bin/env bash
# trunk-ignore-all(shellcheck/SC2034)

if test -z "${BASH_VERSION_LATEST-}"; then
	# If there is ever a double digit version part, we can change this, until then, this is perfect
	BASH_VERSION_MAJOR="${BASH_VERSION:0:1}"
	BASH_VERSION_MINOR="${BASH_VERSION:2:1}"
	if test "$BASH_VERSION_MAJOR" = '5'; then
		BASH_VERSION_LATEST='yes' # any v5 version is good enough
	else
		BASH_VERSION_LATEST='no'
	fi

	function require_latest_bash {
		if test "$BASH_VERSION_LATEST" = 'no'; then
			echo-style \
				--code="$0" --error=" is incompatible with " --code="bash $BASH_VERSION" $'\n' \
				"Run " --bold="setup-util-bash" " to upgrade capabilities, then run the prior command again." >/dev/stderr
			return 95 # Operation not supported
		fi
	}
fi
