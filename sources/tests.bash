source "$DOROTHY/sources/bash.bash"

function fs_tests__prep {
	local command="$1" root
	root="$(fs-temp --directory="$command")"
	# if [[ -d $root ]]; then
	# 	__print_lines "$root"
	# 	return 0
	# fi
	sudo-helper -- rm -rf "$root"

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

	# symlinks
	symlink-helper --quiet --target="$root/targets/empty-dir" --symlink="$root/symlinks/empty-dir"
	symlink-helper --quiet --target="$root/targets/empty-file" --symlink="$root/symlinks/empty-file"
	symlink-helper --quiet --target="$root/targets/filled-dir/empty-subfile" --symlink="$root/symlinks/filled-dir--empty-subfile"
	symlink-helper --quiet --target="$root/targets/filled-dir/filled-subdir" --symlink="$root/symlinks/filled-dir--filled-subdir"
	symlink-helper --quiet --target="$root/targets/filled-dir/filled-subdir/empty-subdir" --symlink="$root/symlinks--filled-dir--filled-subdir--empty-subdir"
	symlink-helper --quiet --target="$root/targets/filled-dir/filled-subfile" --symlink="$root/symlinks--filled-dir--filled-subfile"
	symlink-helper --quiet --target="$root/targets/filled-file" --symlink="$root/symlinks--filled-file"
	symlink-helper --quiet --target="$root/targets/unaccessible-empty-dir" --symlink="$root/symlinks/unaccessible-empty-dir"
	symlink-helper --quiet --target="$root/targets/unaccessible-empty-file" --symlink="$root/symlinks/unaccessible-empty-file"
	symlink-helper --quiet --target="$root/targets/unaccessible-filled-dir" --symlink="$root/symlinks/unaccessible-filled-dir"
	symlink-helper --quiet --target="$root/targets/unaccessible-filled-dir/empty-subfile" --symlink="$root/symlinks/unaccessible-filled-dir--empty-subfile"
	symlink-helper --quiet --target="$root/targets/unaccessible-filled-dir/filled-subdir" --symlink="$root/symlinks/unaccessible-filled-dir--filled-subdir"
	symlink-helper --quiet --target="$root/targets/unaccessible-filled-dir/filled-subdir/empty-subdir" --symlink="$root/symlinks/unaccessible-filled-dir--filled-subdir--empty-subdir"
	symlink-helper --quiet --target="$root/targets/unaccessible-filled-dir/filled-subfile" --symlink="$root/symlinks/unaccessible-filled-dir--filled-subfile"
	symlink-helper --quiet --target="$root/targets/unaccessible-filled-file" --symlink="$root/symlinks/unaccessible-filled-file"
	symlink-helper --quiet --target="$root/targets/unexecutable-empty-dir" --symlink="$root/symlinks/unexecutable-empty-dir"
	symlink-helper --quiet --target="$root/targets/unexecutable-empty-file" --symlink="$root/symlinks/unexecutable-empty-file"
	symlink-helper --quiet --target="$root/targets/unexecutable-filled-dir" --symlink="$root/symlinks/unexecutable-filled-dir"
	symlink-helper --quiet --target="$root/targets/unexecutable-filled-dir/empty-subfile" --symlink="$root/symlinks/unexecutable-filled-dir--empty-subfile"
	symlink-helper --quiet --target="$root/targets/unexecutable-filled-dir/filled-subdir" --symlink="$root/symlinks/unexecutable-filled-dir--filled-subdir"
	symlink-helper --quiet --target="$root/targets/unexecutable-filled-dir/filled-subdir/empty-subdir" --symlink="$root/symlinks/unexecutable-filled-dir--filled-subdir--empty-subdir"
	symlink-helper --quiet --target="$root/targets/unexecutable-filled-dir/filled-subfile" --symlink="$root/symlinks/unexecutable-filled-dir--filled-subfile"
	symlink-helper --quiet --target="$root/targets/unexecutable-filled-file" --symlink="$root/symlinks/unexecutable-filled-file"
	symlink-helper --quiet --target="$root/targets/unreadable-empty-dir" --symlink="$root/symlinks/unreadable-empty-dir"
	symlink-helper --quiet --target="$root/targets/unreadable-empty-file" --symlink="$root/symlinks/unreadable-empty-file"
	symlink-helper --quiet --target="$root/targets/unreadable-filled-dir" --symlink="$root/symlinks/unreadable-filled-dir"
	symlink-helper --quiet --target="$root/targets/unreadable-filled-dir/empty-subfile" --symlink="$root/symlinks/unreadable-filled-dir--empty-subfile"
	symlink-helper --quiet --target="$root/targets/unreadable-filled-dir/filled-subdir" --symlink="$root/symlinks/unreadable-filled-dir--filled-subdir"
	symlink-helper --quiet --target="$root/targets/unreadable-filled-dir/filled-subdir/empty-subdir" --symlink="$root/symlinks/unreadable-filled-dir--filled-subdir--empty-subdir"
	symlink-helper --quiet --target="$root/targets/unreadable-filled-dir/filled-subfile" --symlink="$root/symlinks/unreadable-filled-dir--filled-subfile"
	symlink-helper --quiet --target="$root/targets/unreadable-filled-file" --symlink="$root/symlinks/unreadable-filled-file"
	symlink-helper --quiet --target="$root/targets/unwritable-empty-dir" --symlink="$root/symlinks/unwritable-empty-dir"
	symlink-helper --quiet --target="$root/targets/unwritable-empty-file" --symlink="$root/symlinks/unwritable-empty-file"
	symlink-helper --quiet --target="$root/targets/unwritable-filled-dir" --symlink="$root/symlinks/unwritable-filled-dir"
	symlink-helper --quiet --target="$root/targets/unwritable-filled-dir/empty-subfile" --symlink="$root/symlinks/unwritable-filled-dir--empty-subfile"
	symlink-helper --quiet --target="$root/targets/unwritable-filled-dir/filled-subdir" --symlink="$root/symlinks/unwritable-filled-dir--filled-subdir"
	symlink-helper --quiet --target="$root/targets/unwritable-filled-dir/filled-subdir/empty-subdir" --symlink="$root/symlinks/unwritable-filled-dir--filled-subdir--empty-subdir"
	symlink-helper --quiet --target="$root/targets/unwritable-filled-dir/filled-subfile" --symlink="$root/symlinks/unwritable-filled-dir--filled-subfile"
	symlink-helper --quiet --target="$root/targets/unwritable-filled-file" --symlink="$root/symlinks/unwritable-filled-file"

	# adjust
	chmod +rwx \
		"$root/targets/empty-dir" \
		"$root/targets/empty-file" \
		"$root/targets/filled-dir" \
		"$root/targets/filled-file"
	chmod a-r \
		"$root/targets/unreadable-empty-dir" \
		"$root/targets/unreadable-empty-file" \
		"$root/targets/unreadable-filled-dir" \
		"$root/targets/unreadable-filled-file"
	chmod a-x \
		"$root/targets/unexecutable-empty-dir" \
		"$root/targets/unexecutable-empty-file" \
		"$root/targets/unexecutable-filled-dir" \
		"$root/targets/unexecutable-filled-file"
	chmod a-w \
		"$root/targets/unwritable-empty-dir" \
		"$root/targets/unwritable-empty-file" \
		"$root/targets/unwritable-filled-dir" \
		"$root/targets/unwritable-filled-file"
	sudo-helper -- chown 'root:' \
		"$root/targets/unaccessible-empty-dir" \
		"$root/targets/unaccessible-empty-file" \
		"$root/targets/unaccessible-filled-dir" \
		"$root/targets/unaccessible-filled-file"
	sudo-helper -- chmod a-xrw,u+xrw \
		"$root/targets/unaccessible-empty-dir" \
		"$root/targets/unaccessible-empty-file" \
		"$root/targets/unaccessible-filled-dir" \
		"$root/targets/unaccessible-filled-file"

	__print_lines "$root"
}

function fs_tests__root_status {
	local status="$1"
	if is-root --quiet; then
		__print_lines "$status"
	else
		__print_lines '13'
	fi
}
function fs_tests__tuples {
	local group='' command args=() tuples=()

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
				args+=("$item")
			fi
			;;
		esac
	done

	# process
	root="$(fs-temp --directory="$command")"

	# tests
	if [[ -n $group ]]; then
		echo-style --h2="$group"
	fi
	local index status path total="${#tuples[@]}" result=0
	for ((index = 0; index < total; index += 2)); do
		status="${tuples[index]}"
		path="${tuples[index + 1]}"
		if [[ ${#args[@]} -eq 0 ]]; then
			eval-tester --name="$index / $total" --status="$status" -- "$command" -- "$path" || result=$?
		else
			eval-tester --name="$index / $total" --status="$status" -- "$command" "${args[@]}" -- "$path" || result=$?
		fi
	done
	if [[ $result -ne 0 ]]; then
		if [[ -n $group ]]; then
			echo-style --e2="$group"
		fi
		return 1
	fi
	if [[ -n $group ]]; then
		echo-style --g2="$group"
	fi
	return 0
}
