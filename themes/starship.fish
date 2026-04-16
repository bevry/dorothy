#!/usr/bin/env fish

if command-missing -- starship
	setup-util-starship dependency
end

starship init fish | source
