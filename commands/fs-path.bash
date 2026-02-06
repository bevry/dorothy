#!/usr/bin/env bash

paths=() option_resolve='no' option_validate='no'
while [[ $# -ne 0 ]]; do
	item="$1"
	shift
	case "$item" in
	--resolve | --resolve=yes) option_resolve='yes' ;;
	--resolve=follow) option_resolve='follow' ;;
	--no-resolve | --resolve=no) option_resolve='no' ;;
	--resolve=) : ;;
	--validate | --validate=yes) option_validate='yes' ;;
	--no-validate | --validate=no) option_validate='no' ;;
	--validate=) : ;;
	--path=*) paths+=("${item#*=}") ;;
	--)
		paths+=("$@")
		shift $#
		;;
	*) paths+=("$item") ;;
	esac
done
if [[ ${#paths[@]} -eq 0 ]]; then
	exit 22 # EINVAL 22 Invalid argument
fi
# make it absolute, with optional resolution, optional validation
function __fail {
	# inherit $path
	local -i status="$1"
	printf '%s\n' "$path" >>"$TMPDIR/is-fs-failed-paths"
	return "$status"
}
# export BASH_DEBUG_FORMAT PS4
# BASH_DEBUG_FORMAT='+ ${BASH_SOURCE[0]-} [${LINENO}] [${FUNCNAME-}] [${BASH_SUBSHELL-}]'$'    \t'
# PS4="$BASH_DEBUG_FORMAT"
# set -xv
function __process() (
	local item path='' resolve='no' validate='no'
	while [[ $# -ne 0 ]]; do
		item="$1"
		shift
		case "$item" in
		--path=*) path="${item#*=}" ;;
		--resolve=*) resolve="${item#*=}" ;;
		--validate=*) validate="${item#*=}" ;;
		*) exit 22 ;; # EINVAL 22 Invalid argument
		esac
	done
	function __enter {
		local dirname basename
		dirname="$(dirname "$path")" || return $?
		basename="$(basename "$path")" || return $?
		# swap it around, to avoid having to do two `cd` operations
		if [[ $dirname == '.' && $basename == '..' ]]; then
			dirname='..'
			basename='.'
		fi
		__cd "$dirname" || return $?
		path="$(__pwd)" || return $?
		if [[ $basename != '.' ]]; then
			if [[ ${path:-1} != '/' ]]; then
				path+="/$basename"
			else
				path+="$basename"
			fi
			if [[ -d $path ]]; then
				__cd "$path" || return $?
				path="$(__pwd)" || return $?
			fi
		fi
	}
	# macos only has `readlink <path>`, and `-f [--] <path>`
	# fedora/GNU has `readlink <path>`, `readlink -version`, and `readlink -<f|e|m> [--] <path>`
	#
	# on a symlink with a missing target (recursive or otherwise):
	# `[[ -e <path> ]]` returns failure exit status
	# `[[ -L <path> ]]` returns success exit status
	# `readlink -- <path>` on macos and fedora/GNU will resolve with success exit status
	# `readlink -f -- <path>` on macos will resolve with failure exit status
	# `readlink -f -- <path>` on fedora/GNU will resolve with success exit status
	# `readlink -m -- <path>` on fedora/GNU will resolve with success exit status
	# `readlink -e -- <path>` on fedora/GNU will not resolve with failure exit status
	#
	# on a symlink with an inaccessible target (recursive or otherwise)
	# `readlink -- <path>` on macos and fedora/GNU will resolve with success exit status
	# `readlink -f -- <path>` on macos will resolve with failure exit status
	# `readlink -f -- <path>` on fedora/GNU will not resolve with failure exit status
	# `readlink -m -- <path>` on fedora/GNU will resolve with success exit status
	# `readlink -e -- <path>` on fedora/GNU will not resolve with failure exit status
	#
	# on a working symlink (resurcive or otherwise):
	#
	# on a non-symlink that is missing:
	# `readlink -- <path> on macos and fedora/GNU will not resolve with failure exit status
	#
	# on a non-symlink that is present:
	#
	# on a non-symlink that inaccessible:
	local resolution
	if readlink --version &>/dev/null; then
		# fedora/GNU
		function __check {
			readlink -e -- "$path" &>/dev/null || return $?
		}
		function __follow {
			readlink -m -- "$path" || :
		}
	else
		# macos
		function __check {
			readlink -f -- "$path" &>/dev/null || return $?
		}
		function __follow {
			readlink -f -- "$path" || :
		}
	fi
	function __resolve {
		readlink -- "$path" || :
	}
	# buble upwards until successful absolute or root
	local resolution bubble subpath='' accessible='' initial_iteration='yes'
	local -i symlink_status
	function __is_accessible {
		if [[ -z $accessible ]]; then
			is-accessible.bash -- "$path" || return $?
			accessible='yes' # cache lineages
		fi
	}
	while :; do
		# prepare
		if [[ $resolve == 'follow' ]]; then
			# resolve all symlinks (nested and recursive), replicates `<cd -P | ls | ...> <a>/<b>/<symlink-dir>/../..` functionality which return to two parents of <symlink-dir>'s target
			function __cd {
				cd -P "$@" 2>/dev/null || return $?
			}
			function __pwd {
				pwd -P || return $?
			}
		else
			# resolves no symlinks, replicates `cd <a>/<b>/<symlink-dir>/../..` functionality which return to <a>
			function __cd {
				cd "$@" 2>/dev/null || return $?
			}
			function __pwd {
				pwd || return $?
			}
		fi
		# essential checks
		if [[ -z $path ]]; then
			# we or the user has stuffed up
			return 22 # EINVAL 22 Invalid argument
		elif [[ -p $path ]]; then
			# on linux, named-pipes `/dev/fd/X` are symlinks that exist, which resolve to `pipe:[Y]`, of which nothing knows how to handle this resolution, so return the symlink not the resolution
			printf '%s\n' "$path" || return $?
			break
		elif [[ $path == '/' ]]; then
			# if we've reached root, stop bubbling and return
			if [[ -n $subpath ]]; then
				# we have a subpath, which starts with /, so return it
				printf '%s\n' "$subpath" || return $?
			else
				# no subpath, so return root
				printf '%s\n' '/' || return $?
			fi
			break
		fi
		# `[[ -<d|e|f|L> ]]` do not operate correctly when inside a symlinked directory, and doing on `fs-path --resolve -- ../<symlink>`
		# so we must first resolve these synthetic paths before anything else, so those conditionals work correctly
		bubble='no'
		__enter || {
			__is_accessible || return $?
			if [[ -e $path ]]; then
				# its parent directory is aware of it, however it itself is inaccessible
				return 13 # EACCES 13 Permission denied
			fi
		}
		# now handle the resolution
		if [[ $resolve == 'yes' && $initial_iteration == 'no' ]]; then
			# if <resolve:yes> then we only care about resolving if the leaf is a symlink
			# this prevents missing leafs bubbling up to resolving the first directory if it is a symlink, which is peculiar behaviour
			resolve='no'
		fi
		initial_iteration='no'
		if [[ $resolve =~ ^(yes|follow)$ && -L $path ]]; then
			# @todo this does a follow check, which later, we want to avoid unless following (as it violates logical and leaf resolution), but for now, it's fine
			if ! __check; then
				__is_accessible || return $?
				if [[ $validate == 'yes' ]]; then
					return 9 # EBADF 9 Bad file descriptor
				fi
			fi
			if [[ $resolve == 'follow' ]]; then
				# resolve all symlinks (nested and recursive) and make absolute
				resolution="$(__follow "$path")" || return $?
				if [[ -z $resolution ]]; then
					return 14 # EFAULT 14 Bad address
				fi
				# assign resolution, and exit
				path="$resolution"
				printf '%s\n' "$path$subpath"
				break
			elif [[ $resolve == 'yes' ]]; then
				# this can return absolute or relative, and real or synthetic, so we have to process the resolve path again, to make real and absolute
				resolution="$(__resolve "$path")" || return $?
				if [[ -z $resolution ]]; then
					return 14 # EFAULT 14 Bad address
				fi
				## reiterate on the resolved path, without further resolutions, to resolve synthetics and relatives, and validation
				# reset lineage, necessary if the target doesn't exist, and we have to bubble up in the future
				accessible=''
				# prevent future resolutions as we only wanted to resolve once
				resolve='no'
				# handle absolute vs relative
				if [[ ${resolution:0:1} == '/' ]]; then
					# absolute, replace
					path="$resolution"
				else
					# relative, append to original parent
					path="$(dirname -- "$path")/$(basename -- "$resolution")"
				fi
				# perform the reiteration
				continue
			fi
		elif [[ -e $path ]]; then
			# finally found something that does exist, so we are done
			printf '%s\n' "$path$subpath"
			break
		elif [[ $validate == 'no' ]]; then
			bubble='yes'
		else
			__is_accessible || return $?
			if [[ -L $path ]]; then
				# broken symlink
				return 9 # EBADF 9 Bad file descriptor
			else
				# missing
				return 2 # ENOENT 2 No such file or directory
			fi
		fi
		if [[ $bubble == 'yes' ]]; then
			# bubble up until we find something that does exist
			resolution="$(dirname -- "$path")" || return $?
			if [[ $resolution == '.' ]]; then
				# we've already gotten as far as we can
				printf '%s\n' "$path$subpath"
				break
			else
				subpath="/$(basename -- "$path")$subpath" || return $?
				path="$resolution"
				continue
			fi
		fi
	done
)
for path in "${paths[@]}"; do
	__process --path="$path" --resolve="$option_resolve" --validate="$option_validate" || __fail $? || exit $?
done
exit 0
