#!/usr/bin/env bash

paths=() option_absolute='physical' option_validate='no'
while [[ $# -ne 0 ]]; do
	item="$1"
	shift
	case "$item" in
	# physical, leaf, follow
	--absolute=physical | --absolute=yes | --absolute | --physical=yes | --physical) option_absolute='physical' ;;
	--absolute=leaf | --leaf=yes | --leaf) option_absolute='leaf' ;;
	--absolute=follow | --follow=yes | --follow) option_absolute='follow' ;;
	# validate
	--validate | --validate=yes) option_validate='yes' ;;
	--no-validate | --validate=no) option_validate='no' ;;
	# ignore
	--physical= | --leaf= | --follow= | --validate=) : ;;
	# path, as option ~ isn't interpolated by the caller shell
	--path=*) paths+=("${item#*=}") ;;
	# path, with interpolations by caller shell
	--)
		paths+=("$@")
		shift $#
		;;
	--*)
		printf '%s\n' "ERROR: An unrecognised flag was provided: $item" >&2
		exit 22 # EINVAL 22 Invalid argument
		;;
	*) paths+=("$item") ;;
	esac
done
if [[ ${#paths[@]} -eq 0 ]]; then
	printf '%s\n' 'ERROR: No <path>s were provided.' >&2
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
	# ^ subshell so change directories do not affect subsequent calls
	local item path='' absolute='physical' validate='no'
	while [[ $# -ne 0 ]]; do
		item="$1"
		shift
		case "$item" in
		--path=*) path="${item#*=}" ;;
		--absolute=*) absolute="${item#*=}" ;;
		--validate=*) validate="${item#*=}" ;;
		*) exit 22 ;; # EINVAL 22 Invalid argument
		esac
	done
	# macos only has `readlink <path>`, and `-f [--] <path>`
	# fedora/GNU has `readlink <path>`, `readlink -version`, and `readlink -<f|e|m> [--] <path>`
	#
	# on a symlink with a missing target (recursive or otherwise):
	# `[[ -e <path> ]]` returns failure exit status
	# `[[ -L <path> ]]` returns success exit status
	# `readlink -- <path>` on macos and fedora/GNU will resolve with success exit status
	# `readlink -f -- <path>` on macos will partially resolve with failure exit status
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
	# on a non-symlink that is missing:
	# `readlink -- <path> on macos and fedora/GNU will not resolve with failure exit status
	# @todo
	#
	# on a non-symlink that is present:
	# @todo
	#
	# on a non-symlink that inaccessible:
	# @todo
	#
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
			# `readlink -f -- <broken-symlink>` is messed up
			# `readlink -f -- /private/var/folders/wm/8g56ry4s47z_hbt0tgv0m5gr0000gn/T/dorothy/fs-path/tests/30356/symlinks/empty-dir` outputs:
			# `/private/var/folders/wm/8g56ry4s47z_hbt0tgv0m5gr0000gn/T/dorothy/fs-path/tests/30356/targets`
			# instead of:
			# `/var/folders/wm/8g56ry4s47z_hbt0tgv0m5gr0000gn/T/dorothy/fs-path/tests/30356/targets/empty-dir`
			# so still return the exit status so we can fallback to manual following
			readlink -f -- "$path" || return $?
		}
	fi
	function __resolve {
		readlink -- "$path" || :
	}
	# `cd -P <path>` and `pwd -P` resolves all symlinks (nested and recursive), replicates `<cd -P | ls | ...> <a>/<b>/<symlink-dir>/../..` functionality which return to two parents of <symlink-dir>'s target
	# `cd <path>` and `pwd` resolves no symlinks, replicates `cd <a>/<b>/<symlink-dir>/../..` functionality which return to <a>
	function __enter {
		local dirname basename
		# if the path is relative, then prepend our current pwd
		if [[ ${path:0:1} != '/' ]]; then
			path="$(pwd)/$path" || return $?
		fi
		dirname="$(dirname -- "$path")" || return $?
		basename="$(basename -- "$path")" || return $?
		# swap it around, to avoid having to do two `cd` operations
		if [[ $basename == '..' ]]; then
			dirname+='/..'
			basename='.'
		fi
		# if we have upwards traversal, then follow
		# @todo in the future, this should do recursive readlink only if upward traversal is of a symlink directory, but that is too complicated for now
		if [[ $dirname =~ (^|/)[.][.](/|$) || $absolute == 'follow' ]]; then
			# enter via follow, however `cd -P <path>` fails for missing paths, which if .. then will persist
			cd -P -- "$dirname" &>/dev/null || return $?
		elif [[ $dirname != '.' ]]; then
			# otherwise enter normally
			cd -- "$dirname" &>/dev/null || return $?
		fi
		# now get the current path
		path="$(pwd)" || exit 14 # EFAULT 14 Bad address
		if [[ $basename != '.' ]]; then
			if [[ ${path:-1} != '/' ]]; then
				path+="/$basename"
			else
				path+="$basename"
			fi
			# if basename is also a directory, then enter it
			if [[ -d $path ]]; then
				if [[ $absolute == 'follow' ]]; then
					cd -P -- "$path" &>/dev/null || return $?
				else
					cd -- "$path" &>/dev/null || return $?
				fi
				path="$(pwd)" || return $?
			fi
		fi
	}
	# bubble upwards until successful absolute or root
	local resolution subpath='' accessible='' initial_iteration='yes' dirname basename
	function __is_accessible {
		if [[ -z $accessible ]]; then
			is-accessible.bash -- "$path" || return $?
			accessible='yes' # cache lineages
		fi
	}
	while :; do
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
		# `[[ -<d|e|f|L> ]]` are physical not logical operations, so resolve synthetic paths
		__enter || {
			__is_accessible || return $?
			if [[ -e $path ]]; then
				# its parent directory is aware of it, however it itself is inaccessible
				return 13 # EACCES 13 Permission denied
			fi
		}
		# now handle the resolution
		if [[ $absolute == 'leaf' && $initial_iteration == 'no' ]]; then
			# if <resolve:yes> then we only care about resolving if the leaf is a symlink
			# this prevents missing leafs bubbling up to resolving the first directory if it is a symlink, which is peculiar behaviour
			absolute='physical'
		fi
		initial_iteration='no'
		if [[ $absolute =~ ^(leaf|follow)$ && -L $path ]]; then
			# @todo this does a follow check, which later, we want to avoid unless following (as it violates logical and leaf resolution), but for now, it's fine
			if ! __check; then
				__is_accessible || return $?
				if [[ $validate == 'yes' ]]; then
					return 9 # EBADF 9 Bad file descriptor
				fi
			fi
			if [[ $absolute == 'follow' ]]; then
				# resolve all symlinks (nested and recursive) and make absolute
				resolution="$(__follow "$path")" || {
					# workaround macos follow of broken symlinks returning bad data, by manually following instead
					resolution="$(__resolve "$path")" || return $?
					accessible=''
					if [[ ${resolution:0:1} == '/' ]]; then
						# absolute, replace
						path="$resolution"
					else
						# relative, append to original parent
						path="$(dirname -- "$path")/$(basename -- "$resolution")"
					fi
					# repeat again for the resolution
					continue
				}
				# otherwise continue with this resolution
				if [[ -z $resolution ]]; then
					return 14 # EFAULT 14 Bad address
				fi
				# assign resolution, and exit
				path="$resolution"
				printf '%s\n' "$path$subpath"
				break
			elif [[ $absolute == 'leaf' ]]; then
				# this can return absolute or relative, and real or synthetic, so we have to process the resolve path again, to make real and absolute
				resolution="$(__resolve "$path")" || return $?
				if [[ -z $resolution ]]; then
					return 14 # EFAULT 14 Bad address
				fi
				## reiterate on the resolved path, without further resolutions, to resolve synthetics and relatives, and validation
				# reset lineage, necessary if the target doesn't exist, and we have to bubble up in the future
				accessible=''
				# prevent future resolutions as we only wanted to resolve once
				absolute='physical'
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
			# we don't exist, bubble up until we find something that does exist
			dirname="$(dirname -- "$path")" || return $?
			if [[ $dirname == '/' ]]; then
				# we've already gotten as far as we can
				printf '%s\n' "$path$subpath"
				break
			else
				subpath="/$(basename -- "$path")$subpath" || return $?
			fi
			path="$dirname"
			continue
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
	done
)
for path in "${paths[@]}"; do
	__process --path="$path" --absolute="$option_absolute" --validate="$option_validate" || __fail $? || exit $?
done
exit 0
