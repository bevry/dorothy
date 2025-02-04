#!/usr/bin/env bash

# This command is another piece of pure magic by @balupton
# It outputs the differences in environment variables from sourcing to exit

# IMPORTED BY SOURCE STATEMENT
# $shell - the current shell name, e.g. `fish` or `bash` or `zsh`
#
# NOTES
# echos should suffix with ; otherwise fish will break

# initial scanning of environment into a tuple]
inherited=() # [name, value], [name, value], ...
while read -r line; do
	for ((i = 0; i < ${#line}; i++)); do
		if [[ ${line:i:1} == '=' ]]; then
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
	if [[ $last_status -ne 0 ]]; then
		return "$last_status"
	fi

	# success condition, echo var actions
	local name value i items_array items_string item item_last_index item_index item_existing split_char is_path
	while read -r line; do
		# parse line
		name='' value=''
		for ((i = 0; i < ${#line}; i++)); do
			if [[ ${line:i:1} == '=' ]]; then
				name="${line:0:i}"  # name
				value="${line:i+1}" # value
				break
			fi
		done
		if [[ -z $name ]]; then
			# on fedora, env can output functions, in which case we get garbled data sometimes
			continue
		fi
		if [[ $name == 'SHLVL' ]]; then
			# ignore shell level, fixes: [set: Tried to change the read-only variable 'SHLVL'] on fish shell
			continue
		fi

		# adjust
		split_char=''
		is_path='no'
		if [[ $name =~ (PATH|DIRS)$ ]]; then
			split_char=':'
			is_path='yes'
		elif [[ $name =~ FLAGS$ ]]; then
			split_char=' '
		fi
		if [[ -n $split_char ]]; then
			# cycle through each item in the path, removing duplicates and empties
			items_array=()
			items_string=''
			item_last_index=0
			# the <= and -o, is to ensure that the last item is processed, as it does not have a trailing :
			for ((item_index = 0; item_index <= ${#value}; item_index++)); do
				# || is used instead of -o, because of `[[ '(' = ':' -o 375 -eq 7258 ]]` producing `test: `)' expected, found :`
				if [[ ${value:item_index:1} == "$split_char" || $item_index -eq ${#value} ]]; then
					item="${value:item_last_index:item_index-item_last_index}"
					item_last_index="$((item_index + 1))"
					# check if empty
					if [[ -z $item ]]; then
						continue
					fi
					# check if duplicate
					if [[ ${#items_array[@]} -ne 0 ]]; then # bash v3 compat
						for item_existing in "${items_array[@]}"; do
							if [[ $item == "$item_existing" ]]; then
								# is duplicate, skip
								continue 2
							fi
						done
					fi
					# add
					items_array+=("$item")
					if [[ -z $items_string ]]; then
						items_string="$item"
					else
						items_string="$items_string$split_char$item"
					fi
				fi
			done
			value="$items_string"
		fi

		# find it in inherited, and check if it is the same if it is the same as inherited
		for ((i = 0; i < ${#inherited[@]}; i += 2)); do
			if [[ ${inherited[i]} == "$name" ]]; then
				if [[ ${inherited[i + 1]} == "$value" ]]; then
					# is inherited, continue to next item
					continue 2
				fi
			fi
		done

		# echo the variable action based on type
		# if [[ "$shell" = 'fish' ]]; then
		# 	echo "set --universal --erase $name;"
		# fi
		if [[ -z $value ]]; then
			# echo var action: delete
			if [[ $shell == 'fish' ]]; then
				echo "set --universal --erase $name;"
			elif [[ $shell == 'nu' ]]; then
				echo "setenv $name"
			elif [[ $shell == 'xonsh' ]]; then
				echo 'del $'"$name"
			elif [[ $shell == 'elvish' ]]; then
				# https://elv.sh/ref/builtin.html#unset-env
				echo "unset-env $name"
			else
				echo "unset -v $name;"
			fi
		elif [[ $is_path == 'yes' ]]; then
			# echo var action: set path
			if [[ $shell == 'fish' ]]; then
				echo "set --export --path $name '$value';"
			elif [[ $shell == 'nu' ]]; then
				echo "setenv $name $value"
			elif [[ $shell == 'xonsh' ]]; then
				echo '$'"$name = '$value'.split(':')"
			elif [[ $shell == 'elvish' ]]; then
				# https://elv.sh/ref/builtin.html#set-env
				echo "set-env $name '$value'"
			else
				echo "export $name='$value';"
			fi
		else
			# echo var action: set
			if [[ $shell == 'fish' ]]; then
				echo "set --export $name '$value';"
			elif [[ $shell == 'nu' ]]; then
				echo "setenv $name $value"
			elif [[ $shell == 'xonsh' ]]; then
				echo '$'"$name = '$value'"
			elif [[ $shell == 'elvish' ]]; then
				# https://elv.sh/ref/builtin.html#set-env
				echo "set-env $name '$value'"
			else
				echo "export $name='$value';"
			fi
		fi
	done < <(env)
}
trap on_env_finish EXIT
