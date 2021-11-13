#!/usr/bin/env sh

# workaround for ripgrep being silly
env QUIET=yes setup-util-ripgrep || {
	ec="$?"
	echo "setup-util-ripgrep failed with exit code $ec" >/dev/stderr
	echo "cannot proceed with: $0 $*" >/dev/stderr
	exit "$ec"
}
_rg="$(which rg)"
rg() {
	"${_rg}" --no-line-number --color never "$@"
}
