#!/usr/bin/env sh

# # set the active shell as the detected POSIX (.sh) shell
# # do not export
# if [ -n "${BASH_VERSION-}" ]; then
# 	ACTIVE_POSIX_SHELL='bash'
# elif [ -n "${ZSH_VERSION-}" ]; then
# 	ACTIVE_POSIX_SHELL='zsh'
# elif [ "$0" = '-dash' ] || [ "$0" = 'dash' ]; then
# 	# dash does not define DASH_VERSION
# 	ACTIVE_POSIX_SHELL='dash'
# elif [ -n "${KSH_VERSION-}" ]; then
# 	ACTIVE_POSIX_SHELL='ksh'
# else
# 	ACTIVE_POSIX_SHELL='sh'
# fi

# setup new env
if [ "${LOAD_EXISTING_CACHE_SUCCESS-}" = 'no' ] || [ -z "${LOAD_EXISTING_CACHE_SUCCESS-}" ]; then
	echo "[environment.sh] | Load full env"
	eval "$(
		"$DOROTHY/commands/setup-environment-commands" "$ACTIVE_POSIX_SHELL" || {
			echo "DOROTHY FAILED TO SETUP ENVIRONMENT, RUN THIS TO DEBUG: bash -x '$DOROTHY/commands/setup-environment-commands' '$ACTIVE_POSIX_SHELL'" >/dev/stderr
			return 1
		}
	)"
fi

if [ "${LOAD_EXISTING_CACHE_SUCCESS-}" = 'yes' ]; then
	# process previous env
	echo "[environment.sh] | Use cache -> Load only prev env"
	pairs_formatted="$(echo "$PREV_ENV_KEY_VALUES" | tr '\n' ' ')"
	# echo "$pairs_formatted"
	eval "$(
		env "$pairs_formatted" \
			"$DOROTHY/commands/setup-environment-commands" "$ACTIVE_POSIX_SHELL" || {
			echo "DOROTHY FAILED TO SETUP ENVIRONMENT, RUN THIS TO DEBUG: bash -x '$DOROTHY/commands/setup-environment-commands' '$ACTIVE_POSIX_SHELL'" >/dev/stderr
			return 1
		}
	)"
fi

# # env '' should be completely redundant with no unforseen consequences, so we
# # can achieve the conditional loading of setup-environment-commands based
# # on the cache with the following
# [ "$LOAD_EXISTING_CACHE_SUCCESS" = 'yes' ] &&
# 	pairs_formatted="$(echo "$PREV_ENV_KEY_VALUES" | tr '\n' ' ')" || pairs_formatted=''
# # if [ "$LOAD_EXISTING_CACHE_SUCCESS" = 'yes' ]; then
# 	# process previous env
# 	# pairs_formatted="$(echo "$PREV_ENV_KEY_VALUES" | tr '\n' ' ')"
# 	# echo "$pairs_formatted"
# 	eval "$(
# 		env "$pairs_formatted" \
# 			"$DOROTHY/commands/setup-environment-commands" "$ACTIVE_POSIX_SHELL" || {
# 			echo "DOROTHY FAILED TO SETUP ENVIRONMENT, RUN THIS TO DEBUG: bash -x '$DOROTHY/commands/setup-environment-commands' '$ACTIVE_POSIX_SHELL'" >/dev/stderr
# 			return 1
# 		}
# 	)"
# # fi

# save cache
if [ ! -f "$PATH_ENV_CACHE" ]; then
	touch "$PATH_ENV_CACHE"
fi
export -p >"$PATH_ENV_CACHE"