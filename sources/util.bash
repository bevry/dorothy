#!/usr/bin/env bash
source "$DOROTHY/sources/bash.bash"
# source "$(type -P setup-util)" # enable *_EVAL
local user_options=("$@") util_options=()
shift $#

# __symlink_app_cli <app> ...[<existing> <symlink>]
function __symlink_app_cli {
	local app path existing symlink
	# get the app
	app="$1"
	shift
	# get the path
	path="$(setup-util get-installations --path --first -- "$app" || :)"
	if [[ -n $path && -d $path ]]; then
		# create a symlink for each bin
		while [[ $# -ne 0 ]]; do
			existing="$path/$1"
			shift
			symlink="$XDG_BIN_HOME/$1"
			shift
			if [[ -x $existing ]]; then
				fs-link --existing="$existing" --symlink="$symlink"
			fi
		done
	fi
}

function __add_option {
	util_options+=("$@")
}

function __add_appimage_option_via_url {
	local url="$1"
	util_options+=(APPIMAGE="$url")
}
function __add_deb_option_via_url {
	local url="$1"
	util_options+=(DEB="$url")
}
function __add_rpm_option_via_url {
	local url="$1"
	util_options+=(RPM="$url")
}

function __add_download_option_via_url {
	local url="$1"
	util_options+=(DOWNLOAD="$url")
}
function __add_download_option_via_url_glob {
	local url="$1" glob="$2"
	util_options+=(
		DOWNLOAD="$url"
		DOWNLOAD_ARCHIVE_GLOB="$glob"
	)
}
function __get_github_asset_url_via_slug_regexp {
	local slug="$1" asset_regexp="$2"
	github-download --dry --slug="$slug" --latest  --asset-regexp="$asset_regexp"|| return $?
}
function __get_github_asset_url_via_slug_asset {
	local slug="$1" asset="$2" asset_regexp
	asset_regexp="^$(echo-escape-regexp -- "$asset")$" || return $?
	github-download --dry --slug="$slug" --latest  --asset-regexp="$asset_regexp"|| return $?
}
function __get_github_asset_url_via_slug_suffix {
	local slug="$1" asset_suffix="$2" asset_regexp
	asset_regexp="$(echo-escape-regexp -- "$asset_suffix")$" || return $?
	github-download --dry --slug="$slug" --latest  --asset-regexp="$asset_regexp"|| return $?
}
function __get_github_asset_url_via_slug_pathname {
	local slug="$1" pathname="$2"
	github-download --dry --slug="$slug" --head  --pathname="$pathname" || return $?
}
function __get_github_asset {
	github-download --dry "$@" | echo-first-line || return $? # don't escape, we actually use a regex
}

function __fetch_and_add_download_option_via_github {
	local url
	url="$(__get_github_asset "$@")" || return $?
	util_options+=(DOWNLOAD="$url")
}
function __fetch_and_add_download_option_via_slug_regexp {
	local slug="$1" asset_regexp="$2" url
	url="$(__get_github_asset_url_via_slug_regexp "$slug" "$asset_regexp")" || return $?
	util_options+=(DOWNLOAD="$url")
}
function __fetch_and_add_download_option_via_slug_asset {
	local slug="$1" asset="$2" url
	url="$(__get_github_asset_url_via_slug_asset "$slug" "$asset")" || return $?
	util_options+=(DOWNLOAD="$url")
}
function __fetch_and_add_download_option_via_slug_suffix {
	local slug="$1" asset_suffix="$2" url
	url="$(__get_github_asset_url_via_slug_regexp "$slug" "$asset_suffix")" || return $?
	util_options+=(DOWNLOAD="$url")
}
function __fetch_and_add_apk_option_via_slug_regexp {
	local slug="$1" asset_regexp="$2" url
	url="$(__get_github_asset_url_via_slug_regexp "$slug" "$asset_regexp")" || return $?
	util_options+=(APK="$url")
}
function __fetch_and_add_appimage_option_via_slug_regexp {
	local slug="$1" asset_regexp="$2" url
	url="$(__get_github_asset_url_via_slug_regexp "$slug" "$asset_regexp")" || return $?
	util_options+=(APPIMAGE="$url")
}
function __fetch_and_add_deb_option_via_slug_regexp {
	local slug="$1" asset_regexp="$2" url
	url="$(__get_github_asset_url_via_slug_regexp "$slug" "$asset_regexp")" || return $?
	util_options+=(DEB="$url")
}
function __fetch_and_add_rpm_option_via_slug_regexp {
	local slug="$1" asset_regexp="$2" url
	url="$(__get_github_asset_url_via_slug_regexp "$slug" "$asset_regexp")" || return $?
	util_options+=(RPM="$url")
}

function __fetch_and_add_apk_option_via_slug_asset {
	local slug="$1" asset="$2" url
	url="$(__get_github_asset_url_via_slug_asset "$slug" "$asset")" || return $?
	util_options+=(APK="$url")
}
function __fetch_and_add_appimage_option_via_slug_asset {
	local slug="$1" asset="$2" url
	url="$(__get_github_asset_url_via_slug_asset "$slug" "$asset")" || return $?
	util_options+=(APPIMAGE="$url")
}
function __fetch_and_add_deb_option_via_slug_asset {
	local slug="$1" asset="$2" url
	url="$(__get_github_asset_url_via_slug_asset "$slug" "$asset")" || return $?
	util_options+=(DEB="$url")
}
function __fetch_and_add_rpm_option_via_slug_asset {
	local slug="$1" asset="$2" url
	url="$(__get_github_asset_url_via_slug_asset "$slug" "$asset")" || return $?
	util_options+=(RPM="$url")
}

function __fetch_and_add_apk_option_via_slug_suffix {
	local slug="$1" asset_suffix="$2" url
	url="$(__get_github_asset_url_via_slug_suffix "$slug" "$asset_suffix")" || return $?
	util_options+=(APK="$url")
}
function __fetch_and_add_appimage_option_via_slug_suffix {
	local slug="$1" asset_suffix="$2" url
	url="$(__get_github_asset_url_via_slug_suffix "$slug" "$asset_suffix")" || return $?
	util_options+=(APPIMAGE="$url")
}
function __fetch_and_add_deb_option_via_slug_suffix {
	local slug="$1" asset_suffix="$2" url
	url="$(__get_github_asset_url_via_slug_suffix "$slug" "$asset_suffix")" || return $?
	util_options+=(DEB="$url")
}
function __fetch_and_add_rpm_option_via_slug_suffix {
	local slug="$1" asset_suffix="$2" url
	url="$(__get_github_asset_url_via_slug_suffix "$slug" "$asset_suffix")" || return $?
	util_options+=(RPM="$url")
}

function __fetch_and_add_download_option_via_slug_pathname {
	local slug="$1" pathname="$2" url
	url="$(__get_github_asset_url_via_slug_pathname "$slug" "$pathname")" || return $?
	util_options+=(DOWNLOAD="$url")
}
function __fetch_and_add_download_option_via_slug_pathname_filename {
	local slug="$1" pathname="$2" filename="$3" url
	url="$(__get_github_asset_url_via_slug_pathname "$slug" "$pathname")" || return $?
	util_options+=(
		DOWNLOAD="$url"
		DOWNLOAD_FILENAME="$filename"
	)
}

function __fetch_and_add_download_option_via_slug_regexp_glob {
	local slug="$1" asset_regexp="$2" archive_glob="$3" url
	url="$(__get_github_asset_url_via_slug_regexp "$slug" "$asset_regexp")" || return $?
	util_options+=(
		DOWNLOAD="$url"
		DOWNLOAD_ARCHIVE_GLOB="$archive_glob"
	)
}
function __fetch_and_add_download_option_via_slug_suffix_glob {
	local slug="$1" asset_suffix="$2" archive_glob="$3" url
	url="$(__get_github_asset_url_via_slug_suffix "$slug" "$asset_suffix")" || return $?
	util_options+=(
		DOWNLOAD="$url"
		DOWNLOAD_ARCHIVE_GLOB="$archive_glob"
	)
}

function __fetch_and_add_dmg_option_via_url_glob_filename {
	local url="$1" glob="$2" filename="$3"
	util_options+=(
		DOWNLOAD="$url"
		DOWNLOAD_ARCHIVE_GLOB="$glob"
		DOWNLOAD_FILENAME="$filename"
	)
}
function __fetch_and_add_dmg_option_via_slug_suffix_glob_filename {
	local slug="$1" asset_suffix="$2" glob="$3" filename="$4" url
	url="$(__get_github_asset_url_via_slug_suffix "$slug" "$asset_suffix")" || return $?
	util_options+=(
		DOWNLOAD="$url"
		DOWNLOAD_ARCHIVE_GLOB="$glob"
		DOWNLOAD_FILENAME="$filename"
	)
}

# function __add_installer_option {
# 	local suffix="$1" url
# 	url="$(__get_github_asset_url "$suffix")" || return $?
# 	util_options+=(
# 		INSTALLER="$url"
# 		INSTALLER_OPEN=yes
# 	)
# }

# case "$*" in
# '--help' | '-h')
# 	local fn_help
# 	fn_help="$(__stdinargs__get_first_function __help help __on_help on_help)" || return $?
# 	fn_help # eval
# 	return $?
# fi
