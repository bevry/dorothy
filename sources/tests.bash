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
		"$root/targets/subdir/empty-dir" \
		"$root/targets/non-readable-dir/subdir/empty-dir" \
		"$root/targets/non-executable-dir/subdir/empty-dir" \
		"$root/targets/non-writable-dir/subdir/empty-dir" \
		"$root/targets/non-accessible-dir/subdir/empty-dir"

	touch \
		"$root/targets/subdir/empty-file" \
		"$root/targets/subdir/file" \
		"$root/targets/non-readable-file" \
		"$root/targets/non-readable-empty-file" \
		"$root/targets/non-executable-file" \
		"$root/targets/non-executable-empty-file" \
		"$root/targets/non-writable-file" \
		"$root/targets/non-writable-empty-file" \
		"$root/targets/non-accessible-file" \
		"$root/targets/non-accessible-empty-file" \
		"$root/targets/non-readable-dir/subdir/file" \
		"$root/targets/non-readable-dir/subdir/empty-file" \
		"$root/targets/non-executable-dir/subdir/file" \
		"$root/targets/non-executable-dir/subdir/empty-file" \
		"$root/targets/non-writable-dir/subdir/file" \
		"$root/targets/non-writable-dir/subdir/empty-file" \
		"$root/targets/non-accessible-dir/subdir/file" \
		"$root/targets/non-accessible-dir/subdir/empty-file"

	__print_lines 'content' >"$root/targets/subdir/file"
	__print_lines 'content' >"$root/targets/non-readable-file"
	__print_lines 'content' >"$root/targets/non-executable-file"
	__print_lines 'content' >"$root/targets/non-writable-file"
	__print_lines 'content' >"$root/targets/non-accessible-file"
	__print_lines 'content' >"$root/targets/non-readable-dir/subdir/file"
	__print_lines 'content' >"$root/targets/non-executable-dir/subdir/file"
	__print_lines 'content' >"$root/targets/non-writable-dir/subdir/file"
	__print_lines 'content' >"$root/targets/non-accessible-dir/subdir/file"

	# symlinks
	symlink-helper --quiet --symlink="$root/symlinks/empty-dir" --target="$root/targets/subdir/empty-dir"
	symlink-helper --quiet --symlink="$root/symlinks/empty-file" --target="$root/targets/subdir/empty-file"
	symlink-helper --quiet --symlink="$root/symlinks/file" --target="$root/targets/subdir/file"
	symlink-helper --quiet --symlink="$root/symlinks/subdir" --target="$root/targets/subdir"

	symlink-helper --quiet --symlink="$root/symlinks/non-accessible-dir" --target="$root/targets/non-accessible-dir"
	symlink-helper --quiet --symlink="$root/symlinks/non-accessible-empty-file" --target="$root/targets/non-accessible-empty-file"
	symlink-helper --quiet --symlink="$root/symlinks/non-accessible-file" --target="$root/targets/non-accessible-file"
	symlink-helper --quiet --symlink="$root/symlinks/non-accessible-subdir-empty-dir" --target="$root/targets/non-accessible-dir/subdir/empty-dir"
	symlink-helper --quiet --symlink="$root/symlinks/non-accessible-subdir-empty-file" --target="$root/targets/non-accessible-dir/subdir/empty-file"
	symlink-helper --quiet --symlink="$root/symlinks/non-accessible-subdir-file" --target="$root/targets/non-accessible-dir/subdir/file"
	symlink-helper --quiet --symlink="$root/symlinks/non-accessible-subdir" --target="$root/targets/non-accessible-dir/subdir"

	symlink-helper --quiet --symlink="$root/symlinks/non-executable-dir" --target="$root/targets/non-executable-dir"
	symlink-helper --quiet --symlink="$root/symlinks/non-executable-empty-file" --target="$root/targets/non-executable-empty-file"
	symlink-helper --quiet --symlink="$root/symlinks/non-executable-file" --target="$root/targets/non-executable-file"
	symlink-helper --quiet --symlink="$root/symlinks/non-executable-subdir-empty-dir" --target="$root/targets/non-executable-dir/subdir/empty-dir"
	symlink-helper --quiet --symlink="$root/symlinks/non-executable-subdir-empty-file" --target="$root/targets/non-executable-dir/subdir/empty-file"
	symlink-helper --quiet --symlink="$root/symlinks/non-executable-subdir-file" --target="$root/targets/non-executable-dir/subdir/file"
	symlink-helper --quiet --symlink="$root/symlinks/non-executable-subdir" --target="$root/targets/non-executable-dir/subdir"

	symlink-helper --quiet --symlink="$root/symlinks/non-readable-dir" --target="$root/targets/non-readable-dir"
	symlink-helper --quiet --symlink="$root/symlinks/non-readable-empty-file" --target="$root/targets/non-readable-empty-file"
	symlink-helper --quiet --symlink="$root/symlinks/non-readable-file" --target="$root/targets/non-readable-file"
	symlink-helper --quiet --symlink="$root/symlinks/non-readable-subdir-empty-dir" --target="$root/targets/non-readable-dir/subdir/empty-dir"
	symlink-helper --quiet --symlink="$root/symlinks/non-readable-subdir-empty-file" --target="$root/targets/non-readable-dir/subdir/empty-file"
	symlink-helper --quiet --symlink="$root/symlinks/non-readable-subdir-file" --target="$root/targets/non-readable-dir/subdir/file"
	symlink-helper --quiet --symlink="$root/symlinks/non-readable-subdir" --target="$root/targets/non-readable-dir/subdir"

	symlink-helper --quiet --symlink="$root/symlinks/non-writable-dir" --target="$root/targets/non-writable-dir"
	symlink-helper --quiet --symlink="$root/symlinks/non-writable-empty-file" --target="$root/targets/non-writable-empty-file"
	symlink-helper --quiet --symlink="$root/symlinks/non-writable-file" --target="$root/targets/non-writable-file"
	symlink-helper --quiet --symlink="$root/symlinks/non-writable-subdir-empty-dir" --target="$root/targets/non-writable-dir/subdir/empty-dir"
	symlink-helper --quiet --symlink="$root/symlinks/non-writable-subdir-empty-file" --target="$root/targets/non-writable-dir/subdir/empty-file"
	symlink-helper --quiet --symlink="$root/symlinks/non-writable-subdir-file" --target="$root/targets/non-writable-dir/subdir/file"
	symlink-helper --quiet --symlink="$root/symlinks/non-writable-subdir" --target="$root/targets/non-writable-dir/subdir"

	# adjust
	chmod +rwx "$root/targets/subdir" "$root/targets/subdir/empty-dir" "$root/targets/subdir/file" "$root/targets/subdir/empty-file"
	chmod a-r "$root/targets/non-readable-dir" "$root/targets/non-readable-file" "$root/targets/non-readable-empty-file"
	chmod a-x "$root/targets/non-executable-dir" "$root/targets/non-executable-file" "$root/targets/non-executable-empty-file"
	chmod a-w "$root/targets/non-writable-dir" "$root/targets/non-writable-file" "$root/targets/non-executable-empty-file"
	sudo-helper -- chown 'root:' "$root/targets/non-accessible-dir" "$root/targets/non-accessible-file" "$root/targets/non-accessible-empty-file"
	sudo-helper -- chmod a-xrw,u+xrw "$root/targets/non-accessible-dir" "$root/targets/non-accessible-file" "$root/targets/non-accessible-empty-file"

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
