#!/usr/bin/env bash

option_resolve='no'
option_validate='no'
while :; do
	case "$1" in
	--resolve | --resolve=yes)
		option_resolve='yes'
		shift
		;;
	--resolve=follow)
		option_resolve='follow'
		shift
		;;
	--no-resolve | --resolve=no)
		option_resolve='no'
		shift
		;;
	--resolve=) shift ;;
	--validate | --validate=yes)
		option_validate='yes'
		shift
		;;
	--no-validate | --validate=no)
		option_validate='no'
		shift
		;;
	--validate=) shift ;;
	--)
		shift
		break
		;;
	*) break ;;
	esac
done
if [[ $# -eq 0 ]]; then
	exit 22 # EINVAL 22 Invalid argument
fi
if [[ $option_resolve == 'yes' ]]; then
	function __cd {
		cd -P "$@" || return $?
	}
	function __pwd {
		pwd -P || return $?
	}
else
	function __cd {
		cd "$@" || return $?
	}
	function __pwd() {
		pwd || return $?
	}
fi
function __process() (
	# keep going upwards until we find the first existing parent
	local path="$1" subpath='' status resolved_absolute_or_relative_path is_accessible=''
	function __fail {
		# inherit $path
		local status="$1"
		printf '%s\n' "$path" >>"$TMPDIR/is-fs-failed-paths"
		return "$status"
	}
	function __accessible {
		# inherit $path
		# we only need to do the accessibility check once
		if [[ -z $is_accessible ]]; then
			is-accessible.bash -- "$path" || return $?
			is_accessible='yes'
		fi
	}
	while :; do
		if [[ $path == '/' ]]; then
			# reached root, so return it
			if [[ -n $subpath ]]; then
				# we have a subpath, so return it
				printf '%s\n' "$subpath" || __fail $? || return $?
			else
				# no subpath, so return root
				printf '%s\n' '/' || __fail $? || return $?
			fi
			break
		fi
		if [[ -d $path ]]; then
			# found an existing parent
			__cd "$path" || __fail $? || return $?
			printf '%s\n' "$(__pwd)$subpath" || __fail $? || return $?
			break
		else
			# not a directory
			if [[ $option_resolve =~ ^(yes|follow)$ ]]; then
				if [[ -L $path ]]; then
					if [[ -p $path ]]; then
						# on linux, /dev/fd/* (which things know how to handle), is a name-pipe but also a symlink, that will go to pipe:[*] (which nothing knows how to handle)
						printf '%s\n' "$path" || __fail $? || return $?
						break
					fi
					# is a symlink (broken or otherwise), resolve it
					# `stat -tc %N "$path"` # alpine, however format is tedious, use `readlink` instead
					# `stat -f %Y "$path"`  # macos/bsd, use `readlink` for consistency as wherever `readlink` is available, `stat` is available
					# readlink supports broken symlinks
					# must do `-f` to handle the case where a path is a symlink inside a symlink, e.g.
					# `readlink -f /opt/homebrew/opt/python/libexec/bin/python`
					# => `/opt/homebrew/Cellar/python@3.13/3.13.7/Frameworks/Python.framework/Versions/3.13/bin/python3.13`
					# `readlink /opt/homebrew/opt/python/libexec/bin/python`
					# => `../../Frameworks/Python.framework/Versions/3.13/bin/python3.13` which is 404, as depends upon
					# `readlink /opt/homebrew/opt/python`
					# => `../Cellar/python@3.13/3.13.7` to be resolved first
					resolved_absolute_or_relative_path="$(readlink -f -- "$path")" || __fail $? || return $?
					if [[ $option_resolve == 'follow' ]]; then
						resolved_absolute_or_relative_path="$(__process "$resolved_absolute_or_relative_path")" || __fail $? || return $?
					fi
					__cd "$(dirname -- "$resolved_absolute_or_relative_path")" || __fail $? || return $?
					printf '%s\n' "$(__pwd)/$(basename -- "$resolved_absolute_or_relative_path")$subpath" || __fail $? || return $?
					break
				fi
			fi
			if [[ -e $path ]]; then
				# exists
				__cd "$(dirname -- "$path")" || __fail $? || return $?
				printf '%s\n' "$(__pwd)/$(basename -- "$path")$subpath" || __fail $? || return $?
				break
			fi
		fi
		# doesn't exist, check if it is because we are not accessible
		__accessible || return $?
		# we are accessible, so it is just missing
		if [[ $option_validate == 'yes' ]]; then
			if [[ -L $path ]]; then
				# it is a broken symlink
				__fail 9 || return 9 # EBADF 9 Bad file descriptor
			else
				# it is just a missing path
				__fail 2 || return $? # ENOENT 2 No such file or directory
			fi
		fi
		# bubble up
		subpath="/$(basename -- "$path")$subpath" || __fail $? || return $?
		path="$(dirname -- "$path")" || __fail $? || return $?
	done
)
while [[ $# -ne 0 ]]; do
	if [[ -z $1 ]]; then
		exit 22 # EINVAL 22 Invalid argument
	fi
	path="$1"
	shift
	__process "$path" || exit $?
done
exit 0
