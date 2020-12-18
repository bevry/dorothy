#!/usr/bin/env sh

if test -n "${BASH_VERSION-}" -a -f "$BDIR/env.bash"; then
	. "$BDIR/env.bash"
elif test -n "${ZSH_VERSION-}" -a -f "$BDIR/env.zsh"; then
	. "$BDIR/env.zsh"
elif test -f "$BDIR/env.sh"; then
	. "$BDIR/env.sh"
fi

if test -n "${BASH_VERSION-}" -a -f "$BDIR/users/$(whoami)/source.bash"; then
	. "$BDIR/users/$(whoami)/source.bash"
elif test -n "${ZSH_VERSION-}" -a -f "$BDIR/users/$(whoami)/source.zsh"; then
	. "$BDIR/users/$(whoami)/source.zsh"
elif test -f "$BDIR/users/$(whoami)/source.sh"; then
	. "$BDIR/users/$(whoami)/source.sh"
fi
