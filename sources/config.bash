#!/usr/bin/env sh
source "$DOROTHY/sources/config.sh"

# todo
# if test \"\$(get-hostname)\" = '$(get-hostname)'; then

# for scripts to prune custom installers from packages
# USAGE:
# ``` bash
# mapfile -t GEM_INSTALL < <(prepare_packages 'GEM_INSTALL' -- "${GEM_INSTALL[@]}" "${RUBY_INSTALL[@]}")
# ````
prepare_packages() {
	local reconfigure='no' name="$1" packages=("${@:3}")

	# SETUP_UTILS should have already been loaded, but let's create it if not
	# we need to do it this way, otherwise we would wipe pre-existing custom configuration
	if test -z "${SETUP_UTILS-}"; then
		SETUP_UTILS=()
	fi

	# remove packages with dedicated installers
	for item in "${packages[@]}"; do
		installer="$(get-installer "$item" || :)"
		if test -n "$installer"; then
			if [[ "$installer" = 'setup-util-'* ]]; then
				util="${installer:11}"
				echo-style --notice="Moved [$item] from [$name] to [SETUP_UTILS] as [$util]." >/dev/tty
				SETUP_UTILS+=("$util")
				reconfigure='yes'
			else
				echo-style --notice="Skipping [$item] from [$name], as it should be installed via [$installer]." >/dev/tty
			fi
			continue
		else
			echo "$item"
		fi
	done

	# update configuration if necessary
	if test "$reconfigure" = 'yes'; then
		update_dorothy_user_config 'setup.bash' -- \
			--field='SETUP_UTILS' --array="$(echo-lines --quoted -- "${SETUP_UTILS[@]}" | sort --ignore-case | uniq)"
	fi
}

# for scripts to update the correct configuration file
# update_dorothy_user_config [--prefer=local] <filename> -- <--find=., replace>...
#
# if there are multiple config files, prompt the user which one to use
# if there are no configuration files, then use --prefer=... if available
# otherwise use standard
# when creating a config file, copy the default one
update_dorothy_user_config() {
	local dorothy_config_prefer_local dorothy_config_filename dorothy_config_filepaths

	# --prefer=local
	dorothy_config_prefer_local='no'
	if test "$1" = '--prefer=local'; then
		dorothy_config_prefer_local='yes'
		shift
	fi

	# <filename>
	dorothy_config_filename="$1"
	shift

	# check for existing
	if test -f "$DOROTHY/user/config.local/$dorothy_config_filename"; then
		dorothy_config_filepaths+=("$DOROTHY/user/config.local/$dorothy_config_filename")
	fi
	if test -f "$DOROTHY/user/config/$dorothy_config_filename"; then
		dorothy_config_filepaths+=("$DOROTHY/user/config/$dorothy_config_filename")
	fi

	# no user config exists, we got to make it
	if test "${#dorothy_config_filepaths[@]}" -eq 0; then
		# what location do we prefer?
		if test "$dorothy_config_prefer_local" = 'yes'; then
			dorothy_config_filepath="$DOROTHY/user/config.local/$dorothy_config_filename"
		else
			dorothy_config_filepath="$DOROTHY/user/config/$dorothy_config_filename"
		fi

		# does a default config file exist?
		if test -f "$DOROTHY/config/$dorothy_config_filename"; then
			# if so, use it as the template
			cp "$DOROTHY/config/$dorothy_config_filename" "$dorothy_config_filepath"
		else
			# if nmot, create the file manually
			dorothy_config_extension="$(fs-extension "$dorothy_config_filepath")"
			if "$dorothy_config_extension" != "json"; then
				# if not a json file, then use a shell style
				cat <<-EOF >"$dorothy_config_filepath"
					#!/usr/bin/env $dorothy_config_extension
					# shellcheck disable=SC2034
					# do not use \`export\` keyword in this file

				EOF
			else
				# it is a json file, so scaffold empty, and let the user figure it out
				touch "$dorothy_config_filepath"
			fi
		fi

		# add it to the paths
		dorothy_config_filepaths+=("$dorothy_config_filepath")
	fi

	# prompt the user which file to use
	dorothy_config_filepath="$(
		choose-option --required \
			--question="Which [$dorothy_config_filename] configuration file to save changes to?" \
			-- "${dorothy_config_filepaths[@]}"
	)"

	# now that the file exists, update it if we have values to update it
	if test "${1-}" = '--'; then
		config-helper --file="$dorothy_config_filepath" "$@"
	fi
}
