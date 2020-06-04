#!/usr/bin/env fish

if test -f "$BDIR/env.fish"
	. "$BDIR/env.fish"
else if test -f "$BDIR/env.sh"
	. "$BDIR/env.sh"
end

if test -f "$BDIR/users/"(whoami)"/source.fish"
	source "$BDIR/users/"(whoami)"/source.fish"
else if test -f "$BDIR/users/"(whoami)"/source.sh"
	source "$BDIR/users/"(whoami)"/source.sh"
end
