#!/usr/bin/env sh

var_add PATH "$HOME/.scripts/commands"
function setup-paths {
	eval "$(setup-paths-commands)"
}
setup-paths