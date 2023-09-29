#!/usr/bin/env fish

# this should be consistent with:
# $DOROTHY/init.*
# $DOROTHY/commands/dorothy
if ! set -q DOROTHY
	set -xg DOROTHY (dirname (status -f))
end

# login
if status --is-login
	source "$DOROTHY/sources/login.fish"
	source "$DOROTHY/sources/interactive.fish"
end
