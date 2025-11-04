#!/usr/bin/env ksh

if [ "$0" = '-ksh' ] || [ "$0" = 'ksh' ]; then
	. "${DOROTHY:-"${XDG_DATA_HOME:-"$HOME/.local/share/dorothy"}"}/init.sh"
elif [ -n "${CI-}" ]; then
	echo "ksh did not load Dorothy on CI because \$0 = $0" >&2
fi
