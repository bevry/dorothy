#!/usr/bin/env sh

if test -n "${DOROTHY_THEME_OVERRIDE-}"; then
	DOROTHY_THEME="$DOROTHY_THEME_OVERRIDE"
fi

if test -n "${DOROTHY_THEME-}" -a "$DOROTHY_THEME" != 'system'; then
	if test -f "$DOROTHY/user/themes/${DOROTHY_THEME}.${ACTIVE_POSIX_SHELL}"; then
		. "$DOROTHY/user/themes/${DOROTHY_THEME}.${ACTIVE_POSIX_SHELL}"
	elif test -f "$DOROTHY/themes/${DOROTHY_THEME}.${ACTIVE_POSIX_SHELL}"; then
		. "$DOROTHY/themes/${DOROTHY_THEME}.${ACTIVE_POSIX_SHELL}"
	else
		echo-style --warning="Dorothy theme [$DOROTHY_THEME] is not supported by this shell [$ACTIVE_POSIX_SHELL]" >/dev/stderr
	fi
fi
