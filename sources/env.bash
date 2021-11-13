#!/usr/bin/env sh

# IMPORTED BY SOURCER
# $shell - the current shell name, e.g. `fish` or `bash` or `zsh`
#
# NOTES
# echos should suffix with ; otherwise fish will break

# initial scanning of environment into a tuple]
inherited=() # [name, value], [name, value], ...
while read -r line; do
	# shellcheck disable=SC2066
	for ((i = 0; i < ${#line}; i++)); do
		if test "${line:i:1}" = '='; then
			inherited+=("${line:0:i}") # name
			inherited+=("${line:i+1}") # value
			break
		fi
	done
done < <(env)

# final scanning of environment, and echo results
function finish() {
	# ignore failure conditions
	local ec="$?"
	if test "$ec" -ne 0; then
		return "$ec"
	fi

	# success condition, echo var actions
	local name value i items_array items_string item item_last_index item_index item_existing
	while read -r line; do
		# parse line
		name='' value=''
		# shellcheck disable=SC2066
		for ((i = 0; i < ${#line}; i++)); do
			if test "${line:i:1}" = '='; then
				name="${line:0:i}"  # name
				value="${line:i+1}" # value
				break
			fi
		done

		# adjust
		if [[ "$name" = *'PATH' ]] || [[ "$name" = *'DIRS' ]]; then
			# cycle through each item in the path, removing duplicates and empties
			items_array=()
			items_string=''
			item_last_index=0
			# the <= and -o, is to ensure that the last item is processed, as it does not have a trailing :
			# shellcheck disable=SC2066
			for ((item_index = 0; item_index <= ${#value}; item_index++)); do
				if test "${value:item_index:1}" = ':' -o "$item_index" = "${#value}"; then
					item="${value:item_last_index:item_index-item_last_index}"
					item_last_index="$((item_index + 1))"
					# check if empty
					if test -z "$item"; then
						continue
					fi
					# check if duplicate
					# bash v3 compat: `test ... && for ...`
					test "${#items_array[@]}" -ne 0 && for item_existing in "${items_array[@]}"; do
						if test "$item" = "$item_existing"; then
							# is duplicate, skip
							continue 2
						fi
					done
					# add
					items_array+=("$item")
					if test -z "$items_string"; then
						items_string="$item"
					else
						items_string="$items_string:$item"
					fi
				fi
			done
			value="$items_string"
		fi

		# find it in inherited, and check if it is the same if it is the same as inherited
		for ((i = 0; i < ${#inherited[@]}; i += 2)); do
			if test "${inherited[$i]}" = "${name}"; then
				if test "${inherited[$i + 1]}" = "${value}"; then
					# is inherited, continue to next item
					continue 2
				fi
			fi
		done

		# echo the variable action based on type
		# if test "$shell" = 'fish'; then
		# 	echo "set --universal --erase $name;"
		# fi
		if test -z "$value"; then
			# echo var action: delete
			# shellcheck disable=SC2154
			if test "$shell" = 'fish'; then
				echo "set --universal --erase $name;"
			else
				echo "export $name='';"
			fi
		elif [[ "$name" = *'PATH' ]] || [[ "$name" = *'DIRS' ]]; then
			# echo var action: set path
			if test "$shell" = 'fish'; then
				echo "set --export --path $name '$value';"
			else
				echo "export $name='$value';"
			fi
		else
			# echo var action: set
			if test "$shell" = 'fish'; then
				echo "set --export $name '$value';"
			else
				echo "export $name='$value';"
			fi
		fi
	done < <(env)
}
trap finish EXIT
