#!/usr/bin/env fish

if test -f "$HOME/.scripts/users/"(whoami)".sh"
	source "$HOME/.scripts/users/"(whoami)".sh"
end
