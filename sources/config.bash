#!/usr/bin/env bash
source "$DOROTHY/sources/config.sh"

# @BETA
# @todo this should be moved into [commands/dorothy] or at last be its own command
# as [config-edit], [config-helper], are all doubling up on this

# todo
# if test \"\$(get-hostname)\" = '$(get-hostname)'; then

# for scripts to prune custom installers from packages
# USAGE:
# ``` bash
# mapfile -t GEM_INSTALL < <(prepare_packages 'GEM_INSTALL' -- "${GEM_INSTALL[@]}" "${RUBY_INSTALL[@]}")
# ````
function prepare_packages {
	local reconfigure='no' name="$1" inputs=("${@:3}") outputs=() item installer util

	# SETUP_UTILS should have already been loaded, but let's create it if not
	# we need to do it this way, otherwise we would wipe pre-existing custom configuration
	if test -z "${SETUP_UTILS-}"; then
		SETUP_UTILS=()
	fi

	# remove inputs with dedicated installers
	for item in "${inputs[@]}"; do
		installer="$(get-installer --first-success --quiet -- "$item" || :)"
		if test -n "$installer"; then
			if [[ $installer == 'setup-util-'* ]]; then
				util="${installer#*setup-util-}"
				echo-style --notice="Moved [$item] from [$name] to [SETUP_UTILS] as [$util]." >/dev/stderr
				SETUP_UTILS+=("$util")
				reconfigure='yes'
			else
				echo-style --notice="Skipping [$item] from [$name], as it should be installed via [$installer]." >/dev/stderr
			fi
			continue
		else
			echo "$item"
			outputs+=("$item")
		fi
	done

	# update configuration if necessary
	if test "$reconfigure" = 'yes'; then
		update_dorothy_user_config 'setup.bash' -- \
			--field="$name" --array="$(echo-lines -- "${outputs[@]}" | sort --ignore-case | uniq)" \
			--field='SETUP_UTILS' --array="$(echo-lines -- "${SETUP_UTILS[@]}" | sort --ignore-case | uniq)"
	fi
}

# for scripts to update the correct configuration file
function update_dorothy_user_config_help {
	cat <<-EOF >/dev/stderr
		USAGE:
		update_dorothy_user_config [--flags]... <filename> -- [arguments for \`config-helper\`]...

		OPTIONS:
		<filename>                       The filename of the configuratio file to find or create, then update.

		[--prefer=local]                 If we need to create a file, make it inside user/config.local/
		[--no-prefer] / [--prefer=]      DEFAULT: If we need to create a file, make it inside user/config/

		All arguments after -- are passed to \`config-helper\`.

		QUIRKS:
		If there are multiple config files, prompt the user which one to use.
	EOF
	if test "$#" -ne 0; then
		echo-error "$@"
	fi
	return 22 # EINVAL 22 Invalid argument
}

function update_dorothy_user_config {
	local item
	local dorothy_config_filename=''
	local config_helper_args=()
	local dorothy_config_prefer=''
	while test "$#" -ne 0; do
		item="$1"
		shift
		case "$item" in
		'--help' | '-h') update_dorothy_user_config_help ;;
		'--file='*) dorothy_config_filename="${item#*--file=}" ;;
		'--prefer=local') dorothy_config_prefer='local' ;;
		'--no-prefer' | '--prefer=') dorothy_config_prefer='' ;;
		'--')
			config_helper_args+=("$@")
			shift $#
			break
			;;
		'--'*) help "An unrecognised flag was provided: $item" ;;
		*)
			if test -z "$dorothy_config_filename"; then
				dorothy_config_filename="$item"
			else
				update_dorothy_user_config_help "An unrecognised argument was provided: $item"
			fi
			;;
		esac
	done

	# check extension
	local dorothy_config_extension # this is used later too
	dorothy_config_extension="$(fs-extension -- "$dorothy_config_filename")"
	if ! [[ $dorothy_config_extension =~ bash|zsh|sh|fish|nu ]]; then
		help "The file extension of [$dorothy_config_filename] is not yet supported."
	fi

	# check for existing
	local dorothy_config_filepaths=()
	if test -f "$DOROTHY/user/config.local/$dorothy_config_filename"; then
		dorothy_config_filepaths+=("$DOROTHY/user/config.local/$dorothy_config_filename")
	fi
	if test -f "$DOROTHY/user/config/$dorothy_config_filename"; then
		dorothy_config_filepaths+=("$DOROTHY/user/config/$dorothy_config_filename")
	fi

	# no user config exists, we got to make it
	local dorothy_config_filepath
	if test "${#dorothy_config_filepaths[@]}" -eq 0; then
		# what location do we prefer?
		if test "$dorothy_config_prefer" = 'local'; then
			dorothy_config_filepath="$DOROTHY/user/config.local/$dorothy_config_filename"
		else
			dorothy_config_filepath="$DOROTHY/user/config/$dorothy_config_filename"
		fi

		# are we okay with using a template, if so, does a default config file exist?
		local dorothy_config_default_filepath=''
		if test -f "$DOROTHY/config/$dorothy_config_filename"; then
			dorothy_config_default_filepath="$DOROTHY/config/$dorothy_config_filename"
		fi
		if test -n "$dorothy_config_default_filepath"; then
			# start witht he header of the default configuration file
			echo-lines-before --line='' <"$dorothy_config_default_filepath" >"$dorothy_config_filepath"
			echo >>"$dorothy_config_filepath"

			# inject the sourcing of the default configuration file
			if test "$dorothy_config_extension" = 'nu'; then
				# nu doesn't support dynamic sourcing
				dorothy_config_default_filepath="${dorothy_config_default_filepath/"$DOROTHY"/"~/.local/share/dorothy"}"
				cat <<-EOF >>"$dorothy_config_filepath"
					# load the default configuration
					source '$dorothy_config_default_filepath'

				EOF
			elif test "$dorothy_config_extension" = 'sh'; then
				# sh uses [.] instead of [source]
				# trunk-ignore(shellcheck/SC2016)
				dorothy_config_default_filepath="${dorothy_config_default_filepath/"$DOROTHY"/'$DOROTHY'}"
				cat <<-EOF >>"$dorothy_config_filepath"
					# load the default configuration
					. "$dorothy_config_default_filepath"

				EOF
			else
				# fish, zsh, bash
				# trunk-ignore(shellcheck/SC2016)
				dorothy_config_default_filepath="${dorothy_config_default_filepath/"$DOROTHY"/'$DOROTHY'}"
				cat <<-EOF >>"$dorothy_config_filepath"
					# load the default configuration
					source "$dorothy_config_default_filepath"

				EOF
			fi

			# append the body of the default configuration file
			echo-lines-after --line='' <"$dorothy_config_default_filepath" >>"$dorothy_config_filepath"
		else
			# even the dorothy default is missing
			cat <<-EOF >"$dorothy_config_filepath"
				#!/usr/bin/env $dorothy_config_extension

			EOF
		fi

		# add the new file to the paths
		dorothy_config_filepaths+=("$dorothy_config_filepath")
	fi

	# prompt the user which file to use
	dorothy_config_filepath="$(
		choose-option --required \
			--question="The [$dorothy_config_filename] configuration file is pending updates, which one do you wish to update?" \
			-- "${dorothy_config_filepaths[@]}"
	)"

	# now that the file exists, update it if we have values to update it
	if test "${#config_helper_args[@]}" -ne 0; then
		config-helper --file="$dorothy_config_filepath" \
			-- "${config_helper_args[@]}"
	fi
}
