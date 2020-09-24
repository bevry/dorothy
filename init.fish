#!/usr/bin/env fish
set -xg BDIR (dirname (status -f))
if status --is-login
	source "$BDIR/sources/essentials.fish"
	source "$BDIR/sources/extras.fish"
end