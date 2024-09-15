#!/usr/bin/env fish

if command-missing -- starship
	setup-util-starship --quiet
end

starship init fish | source
