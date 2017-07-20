#!/usr/bin/env fish

if command_exists azure
	azure --completion-fish | source
end