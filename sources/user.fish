#!/usr/bin/env fish

# defaults
. "$DOROTHY/sources/defaults.sh"

# user
if test -f "$DOROTHY/user/source.fish"
	source "$DOROTHY/user/source.fish"
else if test -f "$DOROTHY/user/source.sh"
	source "$DOROTHY/user/source.sh"
end
