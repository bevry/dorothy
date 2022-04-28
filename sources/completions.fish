#!/usr/bin/env fish

if command-exists azure
	azure --completion-fish | source
end

if command-exists op
	op completion fish | source
end
