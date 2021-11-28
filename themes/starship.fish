#!/usr/bin/env fish

if command-missing starship
	setup-util-starship
end

starship init fish | source