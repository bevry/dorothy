#!/usr/bin/env sh

if test -z "${RIPGREP_BIN_PATH-}"; then
	# install ripgrep
	env QUIET=yes setup-util-ripgrep || {
		ec="$?"
		echo "setup-util-ripgrep failed with exit code $ec" >/dev/stderr
		echo "cannot proceed with: $0 $*" >/dev/stderr
		exit "$ec"
	}

	# workaround for ripgrep outputting colors in pipes
	RIPGREP_BIN_PATH="$(which rg)"
	rg() {
		"$RIPGREP_BIN_PATH" --no-line-number --color never "$@"
	}
fi
