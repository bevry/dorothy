#!/usr/bin/env ksh

if [ "$0" = '-ksh' ] || [ "$0" = 'ksh' ]; then
	. "${DOROTHY:-"${XDG_DATA_HOME:-"$HOME/.local/share/dorothy"}"}/init.sh"
fi
