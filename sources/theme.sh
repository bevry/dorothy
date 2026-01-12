#!/usr/bin/env sh

if [ -n "${DOROTHY_THEME_OVERRIDE-}" ]; then
	DOROTHY_THEME="$DOROTHY_THEME_OVERRIDE"
fi

if [ -n "${DOROTHY_THEME-}" ] && [ "$DOROTHY_THEME" != 'system' ]; then
	if [ -f "$DOROTHY/user/themes/${DOROTHY_THEME}.${ACTIVE_POSIX_SHELL}" ]; then
		. "$DOROTHY/user/themes/${DOROTHY_THEME}.${ACTIVE_POSIX_SHELL}"
	elif [ -f "$DOROTHY/themes/${DOROTHY_THEME}.${ACTIVE_POSIX_SHELL}" ]; then
		. "$DOROTHY/themes/${DOROTHY_THEME}.${ACTIVE_POSIX_SHELL}"
	else
		echo-style --stderr --warning="Dorothy theme [$DOROTHY_THEME] is not supported by this shell [$ACTIVE_POSIX_SHELL]"
	fi
fi
