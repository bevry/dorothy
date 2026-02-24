#!/usr/bin/env bash

# <is-fs:header>
item='' option_failures='' option_echo='no' option_first='no' option_need='all' path='' option_paths=() path_status=0 paths_status=0
while [[ $# -ne 0 ]]; do
	item="$1"
	shift
	case "$item" in
	'--failures='*) option_failures="${item#*=}" ;;
	'--echo' | '--echo=yes' | '--no-echo=no') option_echo='yes' ;;
	'--no-echo' | '--echo=no' | '--no-echo=yes') option_echo='no' ;;
	'--echo=') : ;;
	'--first' | '--first=yes' | '--no-first=no') option_first='yes' ;;
	'--no-first' | '--first=no' | '--no-first=yes') option_first='no' ;;
	'--first=') : ;;
	'--none' | '--need=none' | '--require=none' | '--optional' | '--need=optional' | '--require=optional') option_need='none' ;;
	'--any' | '--need=any' | '--require=any') option_need='any' ;;
	'--all' | '--need=all' | '--require=all' | '--required' | '--need=required' | '--require=required') option_need='all' ;;
	'--need=') : ;;
	'--path='*) option_paths+=("${item#*=}") ;;
	'--')
		option_paths+=("$@")
		shift $#
		break
		;;
	'--'*) exit 22 ;;  # EINVAL 22 Invalid argument
	*) option_paths+=("$item") ;;
	esac
done
any_had_success_override='no'
for path in "${option_paths[@]}"; do
	if [[ -z $path ]]; then
		if [[ -n $option_failures ]]; then
			printf '%d\t%s\n' 22 "$path" >>"$option_failures"
		fi
		exit 22 # EINVAL 22 Invalid argument
	fi
	path_status=0
	# </is-fs:header>

	# operation
	__is_fs__operation "$path" || path_status=$?

	# <is-fs:footer>
	# handle our exit combination
	if [[ $path_status -eq 0 ]]; then
		if [[ $option_need == 'any' ]]; then
			any_had_success_override='yes'
		fi
		if [[ $option_echo == 'yes' ]]; then
			printf '%s\n' "$path"
		fi
		if [[ $option_first == 'yes' ]]; then
			break
		fi
	else
		if [[ -n $option_failures ]]; then
			printf '%d\t%s\n' "$path_status" "$path" >>"$option_failures"
		fi
		paths_status="$path_status"
		if [[ $path_status -eq 22 || $path_status -eq 13 || $option_need == 'all' ]]; then
			# if invalid arg, or inaccessible, or all, then exit right away
			break
		fi
	fi
done
if [[ $any_had_success_override == 'yes' ]]; then
	paths_status=0
fi
exit "$paths_status"
# </is-fs:footer>
