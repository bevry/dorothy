#!/usr/bin/env bash

paths=() option_resolve='no'  option_validate='no'
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
	--) paths+=("$@"); shift $#; ;;
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
function __process() (
	local item path='' subpath='' resolve='no' validate='no' accessible=''
	while [[ $# -ne 0 ]]; do
		item="$1"
		shift
		case "$item" in
		--path=*) path="${item#*=}" ;;
		--subpath=*) subpath="${item#*=}" ;;
		--resolve=*) resolve="${item#*=}" ;;
		--validate=*) validate="${item#*=}" ;;
		--accessible=*) accessible="${item#*=}" ;;
		*) exit 22 ;; # EINVAL 22 Invalid argument
		esac
	done
	function __accessible {
		# inherit $path
		# we only need to do the accessibility check once for each ancestral lineage, as the most nested path will reveal the accessibility of parents
		if [[ -z $accessible ]]; then
			is-accessible.bash -- "$path" || return $?
			accessible='yes'
		fi
	}
	function __parse_dir_failure {
		local check_path="$1"
		is-accessible.bash -- "$check_path" || return $?
		if [[ -e "$check_path" ]]; then
			# its parent directory is aware of it, however it itself is inaccessible
			return 13 # EACCES 13 Permission denied
		else
			# it is missing
			return 2 # ENOENT 2 No such file or directory
		fi
	}
	function __parse_readlink_failure {
		# `readlink -<f|e|m>` resolves every symlink in every component (aka recursive and deep resolution)
		# `readlink -<f|m> <broken-symlink|missing-file>` on fedora output resolution with [0] exit status
		# `readlink -e <broken-symlink|missing-file>` on fedora outputs nothing with [1] exit status
		# `readlink -f <broken-symlink>` on macos output resolution with [1] exit status
		local -i readlink_status=$?
		if [[ -n $path && $validate == 'no' ]]; then
			return 0
		elif [[ -z $path || ! -e $path ]]; then
			return 9 # EBADF 9 Bad file descriptor
		else
			__fail "$readlink_status" || return $?
		fi
	}
	function __bubble {
		local basename dirname
		subpath="/$(basename -- "$path")$subpath" || return $?
		path="$(dirname -- "$path")" || return $?
	}
	function __absolute_path_as_dirname {
		local pwd
		__cd "$path" || __parse_dir_failure "$path" || return $?
		pwd="$(__pwd)" || return $?
		printf '%s\n' "$pwd$subpath" || return $?
	}
	function __absolute_path_as_basename {
		local dirname basename pwd
		dirname="$(dirname -- "$path")" || return $?
		basename="$(basename -- "$path")" || return $?
		__cd  "$dirname" || __parse_dir_failure "$dirname" || return $?
		pwd="$(__pwd)" || return $?
		printf '%s\n' "$pwd/$basename$subpath" || return $?
	}
	if [[ $resolve == 'follow' ]]; then
		# these resolve all symlinks (nested and recursive)
		function __cd {
			cd -P "$@" 2>/dev/null || return $?
		}
		function __pwd {
			pwd -P || return $?
		}
	else
		# these do not resolve any symlink
		function __cd {
			cd "$@" 2>/dev/null || return $?
		}
		function __pwd {
			pwd || return $?
		}
	fi
	# buble upwards until successful absolute or root
	while :; do
		# confirm we or the user hasn't stuffed up
		if [[ -z $path ]]; then
			return 22 # EINVAL 22 Invalid argument
		# if we've reached root, stop bubbling and return
		elif [[ $path == '/' ]]; then
			if [[ -n $subpath ]]; then
				# we have a subpath, so return it
				printf '%s\n' "$subpath" || return $?
			else
				# no subpath, so return root
				printf '%s\n' '/' || return $?
			fi
			break
		elif [[ -L $path ]]; then
			# is a symlink (broken or otherwise)
			if [[ -p $path ]]; then
				# on linux, named-pipes `/dev/fd/X` are symlinks that exist, which resolve to `pi`pe:[Y]`, of which nothing knows how to handle this resolution, so return the symlink not the resolution
				printf '%s\n' "$path" || return $?
				break
			# if we are validating, confirm it
			elif [[ $validate == 'yes' && ! -e $path ]]; then
				# doesn't exist, check if it is because we are not accessible
				__accessible || return $?
				# we are accessible, so it is just a broken symlink
				return 9 # EBADF 9 Bad file descriptor
			elif [[ $resolve =~ ^(yes|follow)$ ]]; then
				# resolve the symlink (present or otherwise)
				# notes on stat:
				# `stat -tc %N "$path"` # alpine, however format is tedious, use `readlink` instead
				# `stat -f %Y "$path"`  # macos/bsd, use `readlink` for consistency as wherever `readlink` is available, `stat` is available
				# `stat -tc %n "$path"` # does not absolute
				# notes on readlink:
				# must do `-f` to handle the case where a path is a symlink inside a symlink, e.g.
				# `readlink -f /opt/homebrew/opt/python/libexec/bin/python`
				# => `/opt/homebrew/Cellar/python@3.13/3.13.7/Frameworks/Python.framework/Versions/3.13/bin/python3.13`
				# `readlink /opt/homebrew/opt/python/libexec/bin/python`
				# => `../../Frameworks/Python.framework/Versions/3.13/bin/python3.13` which is 404, as depends upon
				# `readlink /opt/homebrew/opt/python`
				# => `../Cellar/python@3.13/3.13.7` to be resolved first
				if [[ $resolve == 'follow' ]]; then
					# resolve all symlinks (nested and recursive) and make absolute
					# this is two-step as macos will provide output and a failure exit status on a broken symlink
					path="$(readlink -f -- "$path")" || __parse_readlink_failure || return $?
					printf '%s\n' "$path" || return $?
					break
				else
					# resolve only this symlink, can return relative path, even `ln -s /.. <symlink>` resolves via `readlink -- <symlink>` to `/..`
					# `readlink -- <path>` fails if `<path>` is not a symlink
					path="$(readlink -- "$path")" || __parse_readlink_failure || return $?
					# relative to absolute
					__process --path="$path" --subpath="$subpath" --resolve=no --validate="$validate" || return $?
					break
				fi
			fi
		fi
		# continue with path and file handling in the case of a non-broken symlink that we don't want to resolve
		if [[ -d $path ]]; then
			# is a directory
			__absolute_path_as_dirname || return $?
			break
		elif [[ -e $path ]]; then
			# is a file
			__absolute_path_as_basename || return $?
			break
		elif [[ $validate == 'yes' ]]; then
			# doesn't exist, check if it is because we are not accessible
			__accessible || return $?
			# we are accessible, so is just a missing path
			return 2 # ENOENT 2 No such file or directory
		else
			# it is missing, but we aren't validating, so try parse the parent
			__bubble || return $?
			continue
		fi
	done
)
for path in "${paths[@]}"; do
	__process --path="$path" --resolve="$option_resolve" --validate="$option_validate" || __fail $? || exit $?
done
exit 0
