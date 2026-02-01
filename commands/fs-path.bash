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
	# buble upwards until successful absolute or root
	local resolution bubble subpath='' accessible='' initial_iteration='yes'
	local -i __readlink_status
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
		# `-<d|e|f|L>` do not operate correctly when inside a symlinked directory, and doing on `fs-path --resolve -- ../<symlink>`
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
			__readlink_status=0
			if [[ $resolve == 'follow' ]]; then
				# resolve all symlinks (nested and recursive) and make absolute
				# on a broken symlink:
				# `-f` on macos will resolve while returning a failure exit status
				# `-f` on fedora will return a failure exit status
				# macos only has `-f`, fedora/GNU has `-<f|e|m>`
				# so do `-f` which is macos and fedora, and if it is empty (fedora/GNU) then fill with `-m` but keep `-f`'s exit status
				resolution="$(readlink -f -- "$path")" || __readlink_status=9 # EBADF 9 Bad file descriptor
				if [[ -z $resolution ]]; then
					resolution="$(readlink -m -- "$path")" || __return "$__readlink_status" $? || return $?
					if [[ -z $resolution ]]; then
						# should never happen
						return 14 # EFAULT 14 Bad address
					fi
					if [[ $__readlink_status -eq 0 ]]; then
						__readlink_status=9 # EBADF 9 Bad file descriptor
					fi
				elif [[ $validate == 'no' ]]; then
					__readlink_status=0
				elif [[ ! -e $path ]]; then
					# handle the case where this symlink resolves, but resolves to another symlink that doesn't, or when we are on a platform where readlink doesn't fail for whatever reason
					__readlink_status=9 # EBADF 9 Bad file descriptor
				fi
				# reset lineage
				accessible=''
				# handle resolution
				path="$resolution"
				if [[ $__readlink_status -eq 0 ]]; then
					printf '%s\n' "$path$subpath"
					break
				else
					__is_accessible || return $?
					if [[ $validate == 'yes' ]]; then
						return "$__readlink_status"
					else
						bubble='yes'
					fi
				fi
			elif [[ $resolve == 'yes' ]]; then
				# this can return absolute or relative, and real or synthetic, so we have to process it again
				resolution="$(readlink -- "$path")" || __readlink_status=9 # EBADF 9 Bad file descriptor
				if [[ -z $resolution ]]; then
					resolution="$path"
					if [[ $__readlink_status -eq 0 ]]; then
						__readlink_status=9 # EBADF 9 Bad file descriptor
					fi
				elif [[ $validate == 'no' ]]; then
					__readlink_status=0
				elif [[ ! -e $path ]]; then
					# handle the case where this symlink resolves, but resolves to another symlink that doesn't, or when we are on a platform where readlink doesn't fail for whatever reason
					__readlink_status=9 # EBADF 9 Bad file descriptor
				fi
				# reset lineage
				accessible=''
				# prevent future resolutions as we only wanted to resolve once
				resolve='no'
				# handle resolution
				if [[ $__readlink_status -eq 0 ]]; then
					# success, reiterate to complete the removal of synthetics and relatives
					if [[ ${resolution:0:1} == '/' ]]; then
						# absolute, replace
						path="$resolution"
					else
						# relative, append to the parent
						path="$(dirname -- "$path")"
						subpath="/$(basename -- "$resolution")$subpath"
					fi
					continue
				else
					__is_accessible || return $?
					if [[ $validate == 'yes' ]]; then
						return "$__readlink_status"
					else
						# failed, so bubble to complete the removal of synthetics and relatives
						if [[ ${resolution:0:1} == '/' ]]; then
							# absolute, replace
							path="$resolution"
						else
							# relative, append to original parent
							path="$(dirname -- "$path")/$(basename -- "$resolution")"
						fi
						bubble='yes'
					fi
				fi
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
