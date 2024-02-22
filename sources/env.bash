#!/usr/bin/env bash

# This command is another piece of pure magic by @balupton
# It outputs the differences in environment variables from sourcing to exit

# IMPORTED BY SOURCER
# $shell - the current shell name, e.g. `fish` or `bash` or `zsh`
#
# NOTES
# echos should suffix with ; otherwise fish will break

# initial scanning of environment into a tuple]
inherited=() # [name, value], [name, value], ...
while read -r line; do
	for ((i = 0; i < ${#line}; i++)); do
		if test "${line:i:1}" = '='; then
			inherited+=("${line:0:i}") # name
			inherited+=("${line:i+1}") # value
			break
		fi
	done
done < <(env)

# final scanning of environment, and echo results
function on_env_finish {
	# ignore failure conditions
	local last_status=$?
	if test "$last_status" -ne 0; then
		return "$last_status"
	fi

	# success condition, echo var actions
	local name value i items_array items_string item item_last_index item_index item_existing
	while read -r line; do
		# parse line
		name='' value=''
		for ((i = 0; i < ${#line}; i++)); do
			if test "${line:i:1}" = '='; then
				name="${line:0:i}"  # name
				value="${line:i+1}" # value
				break
			fi
		done
		if test -z "$name"; then
			# on fedora, env can output functions, in which case we get garbled data sometimes
			continue
		fi

		# adjust
		if [[ $name == *'PATH' ]] || [[ $name == *'DIRS' ]]; then
			# cycle through each item in the path, removing duplicates and empties
			items_array=()
			items_string=''
			item_last_index=0
			# the <= and -o, is to ensure that the last item is processed, as it does not have a trailing :
			for ((item_index = 0; item_index <= ${#value}; item_index++)); do
				# || is used instead of -o, because of [test '(' = ':' -o 375 -eq 7258] producing [test: `)' expected, found :]
				if test "${value:item_index:1}" = ':' || test "$item_index" -eq "${#value}"; then
					item="${value:item_last_index:item_index-item_last_index}"
					item_last_index="$((item_index + 1))"
					# check if empty
					if test -z "$item"; then
						continue
					fi
					# check if duplicate
					if test "${#items_array[@]}" -ne 0; then # bash v3 compat
						for item_existing in "${items_array[@]}"; do
							if test "$item" = "$item_existing"; then
								# is duplicate, skip
								continue 2
							fi
						done
					fi
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
			if test "${inherited[i]}" = "$name"; then
				if test "${inherited[i + 1]}" = "$value"; then
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
			if test "$shell" = 'fish'; then
				echo "set --universal --erase $name;"
			elif test "$shell" = 'nu'; then
				echo "setenv $name"
			elif test "$shell" = 'xonsh'; then
				echo 'del $'"$name"
			elif test "$shell" = 'elvish'; then
				# https://elv.sh/ref/builtin.html#unset-env
				echo "unset-env $name"
			else
				echo "export $name='';"
			fi
		elif [[ $name == *'PATH' ]] || [[ $name == *'DIRS' ]]; then
			# echo var action: set path
			if test "$shell" = 'fish'; then
				echo "set --export --path $name '$value';"
			elif test "$shell" = 'nu'; then
				echo "setenv $name $value"
			elif test "$shell" = 'xonsh'; then
				echo '$'"$name = '$value'.split(':')"
			elif test "$shell" = 'elvish'; then
				# https://elv.sh/ref/builtin.html#set-env
				echo "set-env $name '$value'"
			else
				echo "export $name='$value';"
			fi
		else
			# echo var action: set
			if test "$shell" = 'fish'; then
				echo "set --export $name '$value';"
			elif test "$shell" = 'nu'; then
				echo "setenv $name $value"
			elif test "$shell" = 'xonsh'; then
				echo '$'"$name = '$value'"
			elif test "$shell" = 'elvish'; then
				# https://elv.sh/ref/builtin.html#set-env
				echo "set-env $name '$value'"
			else
				echo "export $name='$value';"
			fi
		fi
	done < <(env)
}
trap on_env_finish EXIT
