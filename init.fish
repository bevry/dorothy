#!/usr/bin/env fish

# this should be consistent with:
# $DOROTHY/init.fish
# $DOROTHY/init.sh
# $DOROTHY/commands/setup-dorothy
if ! set -q DOROTHY
	set -xg DOROTHY (dirname (status -f))
end
if ! set -q DOROTHY_USER_HOME
	if set -q XDG_CONFIG_HOME; and test -d "$XDG_CONFIG_HOME/dorothy"
		set -xg DOROTHY_USER_HOME "$XDG_CONFIG_HOME/dorothy"
	else if test -d "$HOME/.config/dorothy"
		set -xg DOROTHY_USER_HOME "$HOME/.config/dorothy"
	else if test -d "$DOROTHY/user"
		set -xg DOROTHY_USER_HOME "$DOROTHY/user"
	else
		set -xg DOROTHY_USER_HOME "$HOME/.config/dorothy"
	end
end

# login
if status --is-login
	source "$DOROTHY/sources/init.fish"
	source "$DOROTHY/sources/shell.fish"
end
