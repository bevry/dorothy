#!/usr/bin/env sh

# workaround for ripgrep being silly
env QUIET=y setup-util-ripgrep
_rg="$(which rg)"
rg() {
	"${_rg}" --no-line-number --color never "$@"
}
