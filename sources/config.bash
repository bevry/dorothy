#!/usr/bin/env bash
source "$DOROTHY/sources/config.sh"

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
		installer="$(get-installer --first-success --quiet "$item" || :)"
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

		[--template=default]             DEFAULT: If we have to create a file, copy the default config.
		[--no-template] / [--template=]  If we have to create a file, only copy the headers from the default config.

		[--source=default]               DEFAULT: If we have to create a file, copy the default config.
		[--no-source] / [--source=]      If we have to create a file, only copy the headers from the default config.

		All arguments after -- are passed to \`config-helper\`.

		QUIRKS:
		If there are multiple config files, prompt the user which one to use.
	EOF
	if test "$#" -ne 0; then
		echo-error "$@"
	fi
	return 22 # Invalid argument
}

function update_dorothy_user_config {
	local item
	local dorothy_config_filename=''
	local config_helper_args=()
	local dorothy_config_prefer=''
	local dorothy_config_template='default'
	local dorothy_config_source='default'
	while test "$#" -ne 0; do
		item="$1"
		shift
		case "$item" in
		'--help' | '-h') update_dorothy_user_config_help ;;
		'--file='*) dorothy_config_filename="${item#*--file=}" ;;
		'--prefer=local') dorothy_config_prefer='local' ;;
		'--no-prefer' | '--prefer=') dorothy_config_prefer='' ;;
		'--template=default') dorothy_config_template='default' ;;
		'--no-template' | '--template=') dorothy_config_template='' ;;
		'--source=default') dorothy_config_source='default' ;;
		'--no-source' | '--source=') dorothy_config_source='' ;;
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
	if ! [[ $dorothy_config_extension =~ bash|zsh|sh|fish ]]; then
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
		local dorothy_config_default="$DOROTHY/config/$dorothy_config_filename"
		if test -f "$dorothy_config_default"; then
			if test "$dorothy_config_template" = 'default'; then
				#  copy the entire template
				cp "$dorothy_config_default" "$dorothy_config_filepath"
			else
				# copy only the header
				echo-before-blank --append=$'\n' "$dorothy_config_default" >"$dorothy_config_filepath"
			fi
		else
			# default missing, make it with the typical header
			cat <<-EOF >"$dorothy_config_filepath"
				#!/usr/bin/env $dorothy_config_extension
				# do not use \`export\` keyword in this file:
				# shellcheck disable=SC2034

			EOF
		fi

		# add the source of the default file
		if test "$dorothy_config_source" = 'default'; then
			# use `.` over `source` as must be posix, in case we are saving a .sh file
			cat <<-EOF >>"$dorothy_config_filepath"
				# Load the default configuration file
				. "\$DOROTHY/config/${dorothy_config_filename}"

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
