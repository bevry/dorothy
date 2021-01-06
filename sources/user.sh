#!/usr/bin/env sh

# defaults
if test -n "${BASH_VERSION-}" -a -f "$DOROTHY/sources/defaults.bash"; then
	. "$DOROTHY/sources/defaults.bash"
else
	. "$DOROTHY/sources/defaults.sh"
fi

# user
if test -n "${BASH_VERSION-}" -a -f "$DOROTHY/user/source.bash"; then
	. "$DOROTHY/user/source.bash"
elif test -n "${ZSH_VERSION-}" -a -f "$DOROTHY/user/source.zsh"; then
	. "$DOROTHY/user/source.zsh"
elif test -f "$DOROTHY/user/source.sh"; then
	. "$DOROTHY/user/source.sh"
fi
