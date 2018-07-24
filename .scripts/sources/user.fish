#!/usr/bin/env fish

if test -f "$HOME/.scripts/env.fish"
	. "$HOME/.scripts/env.fish"
else if test -f "$HOME/.scripts/env.sh"
	. "$HOME/.scripts/env.sh"
end

if test -f "$HOME/.scripts/users/"(whoami)"/source.fish"
	source "$HOME/.scripts/users/"(whoami)"/source.fish"
else if test -f "$HOME/.scripts/users/"(whoami)"/source.sh"
	source "$HOME/.scripts/users/"(whoami)"/source.sh"
end
