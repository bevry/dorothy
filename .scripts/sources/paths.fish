#!/usr/bin/env fish

var_add PATH "$HOME/.scripts/commands"
function setup-paths
	eval (setup-paths-commands)
end
setup-paths