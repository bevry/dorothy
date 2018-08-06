#!/usr/bin/env fish

if command-exists azure
	azure --completion-fish | source
end