#!/usr/bin/env fish

# this should be consistent with:
# $DOROTHY/init.fish
# $DOROTHY/init.sh
# $DOROTHY/commands/dorothy
if ! set -q DOROTHY
	set -xg DOROTHY (dirname (status -f))
end

# login
if status --is-login
	source "$DOROTHY/sources/init.fish"
	source "$DOROTHY/sources/shell.fish"
end
