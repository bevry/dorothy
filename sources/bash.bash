#!/usr/bin/env bash

if [[ $BASH_VERSION != "5."* ]]; then
	BASH_VERSION_LATEST='yes'
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
