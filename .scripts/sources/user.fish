#!/usr/bin/env fish

if test -f "$HOME/.scripts/users/"(whoami)"/source.sh"
	source "$HOME/.scripts/users/"(whoami)"/source.sh"
end

if test -f "$HOME/.scripts/users/"(whoami)"/source.fish"
	source "$HOME/.scripts/users/"(whoami)"/source.fish"
end
