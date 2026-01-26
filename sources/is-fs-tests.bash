source "$DOROTHY/sources/bash.bash"

function is_fs_tests__prep {
	local command="$1" root
	root="$(fs-temp --directory='dorothy' --directory="$command" --directory='tests' --directory)"
	# if [[ -d $root ]]; then
	# 	__print_lines "$root"
	# 	return 0
	# fi

	__print_style --tty --header1='prepping directories'
	__mkdirp \
		"$root/symlinks" \
		"$root/targets/empty-dir" \
		"$root/targets/filled-dir/filled-subdir/empty-subdir" \
		"$root/targets/unaccessible-empty-dir" \
		"$root/targets/unaccessible-filled-dir/filled-subdir/empty-subdir" \
		"$root/targets/unexecutable-empty-dir" \
		"$root/targets/unexecutable-filled-dir/filled-subdir/empty-subdir" \
		"$root/targets/unreadable-empty-dir" \
		"$root/targets/unreadable-filled-dir/filled-subdir/empty-subdir" \
		"$root/targets/unwritable-empty-dir" \
		"$root/targets/unwritable-filled-dir/filled-subdir/empty-subdir"

	__print_style --tty --header1='prepping files'
	touch \
		"$root/targets/empty-file" \
		"$root/targets/filled-dir/empty-subfile" \
		"$root/targets/filled-dir/filled-subfile" \
		"$root/targets/filled-file" \
		"$root/targets/unaccessible-empty-file" \
		"$root/targets/unaccessible-filled-dir/empty-subfile" \
		"$root/targets/unaccessible-filled-dir/filled-subfile" \
		"$root/targets/unaccessible-filled-file" \
		"$root/targets/unexecutable-empty-file" \
		"$root/targets/unexecutable-filled-dir/empty-subfile" \
		"$root/targets/unexecutable-filled-dir/filled-subfile" \
		"$root/targets/unexecutable-filled-file" \
		"$root/targets/unreadable-empty-file" \
		"$root/targets/unreadable-filled-dir/empty-subfile" \
		"$root/targets/unreadable-filled-dir/filled-subfile" \
		"$root/targets/unreadable-filled-file" \
		"$root/targets/unwritable-empty-file" \
		"$root/targets/unwritable-filled-dir/empty-subfile" \
		"$root/targets/unwritable-filled-dir/filled-subfile" \
		"$root/targets/unwritable-filled-file"

	__print_style --tty --header1='prepping content'
	__print_lines 'content' >"$root/targets/filled-dir/filled-subfile"
	__print_lines 'content' >"$root/targets/filled-file"
	__print_lines 'content' >"$root/targets/unaccessible-filled-dir/filled-subfile"
	__print_lines 'content' >"$root/targets/unaccessible-filled-file"
	__print_lines 'content' >"$root/targets/unexecutable-filled-dir/filled-subfile"
	__print_lines 'content' >"$root/targets/unexecutable-filled-file"
	__print_lines 'content' >"$root/targets/unreadable-filled-dir/filled-subfile"
	__print_lines 'content' >"$root/targets/unreadable-filled-file"
	__print_lines 'content' >"$root/targets/unwritable-filled-dir/filled-subfile"
	__print_lines 'content' >"$root/targets/unwritable-filled-file"

	__print_style --tty --header1='prepping symlinks'
	fs-link --quiet \
		--target="$root/targets/empty-dir" --symlink="$root/symlinks/empty-dir" \
		--target="$root/targets/empty-file" --symlink="$root/symlinks/empty-file" \
		--target="$root/targets/filled-dir/empty-subfile" --symlink="$root/symlinks/filled-dir--empty-subfile" \
		--target="$root/targets/filled-dir/filled-subdir" --symlink="$root/symlinks/filled-dir--filled-subdir" \
		--target="$root/targets/filled-dir/filled-subdir/empty-subdir" --symlink="$root/symlinks/filled-dir--filled-subdir--empty-subdir" \
		--target="$root/targets/filled-dir/filled-subfile" --symlink="$root/symlinks/filled-dir--filled-subfile" \
		--target="$root/targets/filled-file" --symlink="$root/symlinks/filled-file" \
		--target="$root/targets/unaccessible-empty-dir" --symlink="$root/symlinks/unaccessible-empty-dir" \
		--target="$root/targets/unaccessible-empty-file" --symlink="$root/symlinks/unaccessible-empty-file" \
		--target="$root/targets/unaccessible-filled-dir" --symlink="$root/symlinks/unaccessible-filled-dir" \
		--target="$root/targets/unaccessible-filled-dir/empty-subfile" --symlink="$root/symlinks/unaccessible-filled-dir--empty-subfile" \
		--target="$root/targets/unaccessible-filled-dir/filled-subdir" --symlink="$root/symlinks/unaccessible-filled-dir--filled-subdir" \
		--target="$root/targets/unaccessible-filled-dir/filled-subdir/empty-subdir" --symlink="$root/symlinks/unaccessible-filled-dir--filled-subdir--empty-subdir" \
		--target="$root/targets/unaccessible-filled-dir/filled-subfile" --symlink="$root/symlinks/unaccessible-filled-dir--filled-subfile" \
		--target="$root/targets/unaccessible-filled-file" --symlink="$root/symlinks/unaccessible-filled-file" \
		--target="$root/targets/unexecutable-empty-dir" --symlink="$root/symlinks/unexecutable-empty-dir" \
		--target="$root/targets/unexecutable-empty-file" --symlink="$root/symlinks/unexecutable-empty-file" \
		--target="$root/targets/unexecutable-filled-dir" --symlink="$root/symlinks/unexecutable-filled-dir" \
		--target="$root/targets/unexecutable-filled-dir/empty-subfile" --symlink="$root/symlinks/unexecutable-filled-dir--empty-subfile" \
		--target="$root/targets/unexecutable-filled-dir/filled-subdir" --symlink="$root/symlinks/unexecutable-filled-dir--filled-subdir" \
		--target="$root/targets/unexecutable-filled-dir/filled-subdir/empty-subdir" --symlink="$root/symlinks/unexecutable-filled-dir--filled-subdir--empty-subdir" \
		--target="$root/targets/unexecutable-filled-dir/filled-subfile" --symlink="$root/symlinks/unexecutable-filled-dir--filled-subfile" \
		--target="$root/targets/unexecutable-filled-file" --symlink="$root/symlinks/unexecutable-filled-file" \
		--target="$root/targets/unreadable-empty-dir" --symlink="$root/symlinks/unreadable-empty-dir" \
		--target="$root/targets/unreadable-empty-file" --symlink="$root/symlinks/unreadable-empty-file" \
		--target="$root/targets/unreadable-filled-dir" --symlink="$root/symlinks/unreadable-filled-dir" \
		--target="$root/targets/unreadable-filled-dir/empty-subfile" --symlink="$root/symlinks/unreadable-filled-dir--empty-subfile" \
		--target="$root/targets/unreadable-filled-dir/filled-subdir" --symlink="$root/symlinks/unreadable-filled-dir--filled-subdir" \
		--target="$root/targets/unreadable-filled-dir/filled-subdir/empty-subdir" --symlink="$root/symlinks/unreadable-filled-dir--filled-subdir--empty-subdir" \
		--target="$root/targets/unreadable-filled-dir/filled-subfile" --symlink="$root/symlinks/unreadable-filled-dir--filled-subfile" \
		--target="$root/targets/unreadable-filled-file" --symlink="$root/symlinks/unreadable-filled-file" \
		--target="$root/targets/unwritable-empty-dir" --symlink="$root/symlinks/unwritable-empty-dir" \
		--target="$root/targets/unwritable-empty-file" --symlink="$root/symlinks/unwritable-empty-file" \
		--target="$root/targets/unwritable-filled-dir" --symlink="$root/symlinks/unwritable-filled-dir" \
		--target="$root/targets/unwritable-filled-dir/empty-subfile" --symlink="$root/symlinks/unwritable-filled-dir--empty-subfile" \
		--target="$root/targets/unwritable-filled-dir/filled-subdir" --symlink="$root/symlinks/unwritable-filled-dir--filled-subdir" \
		--target="$root/targets/unwritable-filled-dir/filled-subdir/empty-subdir" --symlink="$root/symlinks/unwritable-filled-dir--filled-subdir--empty-subdir" \
		--target="$root/targets/unwritable-filled-dir/filled-subfile" --symlink="$root/symlinks/unwritable-filled-dir--filled-subfile" \
		--target="$root/targets/unwritable-filled-file" --symlink="$root/symlinks/unwritable-filled-file"

	__print_style --tty --header1='prepping ownership and permissions'
	fs-own --recursive --permissions='+rwx' -- \
		"$root/targets"
	fs-own --permissions='a-r' -- \
		"$root/targets/unreadable-empty-dir" \
		"$root/targets/unreadable-empty-file" \
		"$root/targets/unreadable-filled-dir" \
		"$root/targets/unreadable-filled-file"
	fs-own --permissions='a-x' -- \
		"$root/targets/unexecutable-empty-dir" \
		"$root/targets/unexecutable-empty-file" \
		"$root/targets/unexecutable-filled-dir" \
		"$root/targets/unexecutable-filled-file"
	fs-own --permissions='a-w' -- \
		"$root/targets/unwritable-empty-dir" \
		"$root/targets/unwritable-empty-file" \
		"$root/targets/unwritable-filled-dir" \
		"$root/targets/unwritable-filled-file"
	fs-own --root --permissions='a-xrw,u+xrw' -- \
		"$root/targets/unaccessible-empty-dir" \
		"$root/targets/unaccessible-empty-file" \
		"$root/targets/unaccessible-filled-dir" \
		"$root/targets/unaccessible-filled-file"

	__print_style --tty --header1='prepping structure'
	fs-structure -- "$root/targets" >&2

	# invalidate elevation after the `fs-own` calls above, such that our `__is_fs_tests__print_root_or_nonroot` returns correct results
	eval-helper --invalidate-elevation

	__print_lines "$root"
}
function is_fs_tests__break_symlinks {
	eval-helper --elevate -- rm -rf -- "$root/targets"
}
function __is_fs_tests__print_root_or_nonroot {
	# don't do login, as it just wiggles around what we actually need, which is for the current user to be the current elevation
	# note that invalidation in a process that is already elevated has no effect on that process, only those beyond it
	if is-root; then
		__print_lines "$1" || return $?
	else
		__print_lines "$2" || return $?
	fi
}
function is_fs_tests__tuples {
	local group='' command command_args=() tuples=()

	# process
	local item
	while [[ $# -ne 0 ]]; do
		item="$1"
		shift
		case "$item" in
		'--group='*) group="${item#*=}" ;;
		'--command='*) command="${item#*=}" ;;
		'--')
			tuples+=("$@")
			shift $#
			break
			;;
		*)
			if [[ -z ${command-} ]]; then
				command="$item"
			else
				command_args+=("$item")
			fi
			;;
		esac
	done

	# ensure tests are running with intended elevation
	eval-helper --invalidate-elevation

	# parse tests
	if [[ -n $group ]]; then
		__print_style --h2="$group"
	fi
	local test_args=() path=''
	local -i total=0 index=0 result=0 # some bash versions don't default it to zero it seems, so must be explicit
	function __flush {
		# or condition to handle `--path='' --status=22`
		if [[ -n $path || ${#test_args[@]} -ne 0 ]]; then
			index=$((index + 1))
			eval-tester --ignore-tty --name="$index / $total" "${test_args[@]}" -- "$command" "${command_args[@]}" -- "$path" || result=$?
			# reset
			path=''
			test_args=()
		fi
	}

	# count the amount of paths so we have a total
	for item in "${tuples[@]}"; do
		if [[ $item == '--path='* ]]; then
			total=$((total+1))
		fi
	done

	# parse and perform our tuple tests
	for item in "${tuples[@]}"; do
		if [[ $item == '--path='* ]]; then
			__flush
			path="${item#*=}"
		else
			test_args+=("$item")
		fi
	done
	__flush

	# ensure subsequent `__is_fs_tests__print_root_or_nonroot` are running with intended elevation
	eval-helper --invalidate-elevation

	# result
	if [[ $result -ne 0 ]]; then
		if [[ -n $group ]]; then
			__print_style --e2="$group"
		fi
		return "$result"
	fi
	if [[ -n $group ]]; then
		__print_style --g2="$group"
	fi
	return 0
}
