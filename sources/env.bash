#!/usr/bin/env sh

# IMPORTED BY SOURCER
# $shell - the current shell name, e.g. `fish` or `bash` or `zsh`
#
# NOTES
# echos should suffix with ; otherwise fish will break

# initial scanning of environment into a tuple]
inherited=()  # [name, value], [name, value], ...
while read -r line; do
	# shellcheck disable=SC2066
	for ((i=0; i<${#line}; i++)); do
		if test "${line:i:1}" = '='; then
			inherited+=("${line:0:i}")  # name
			inherited+=("${line:i+1}")  # value
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
	local name value i
	while read -r line; do
		# parse line
		name='' value=''

		# shellcheck disable=SC2066
		for ((i=0; i<${#line}; i++)); do
			if test "${line:i:1}" = '='; then
				name="${line:0:i}"   # name
				value="${line:i+1}"  # value
				break
			fi
		done

		# find it in inherited, and check if it is the same if it is the same as inherited
		for ((i=0; i<${#inherited[@]}; i+=2)); do
			if test "${inherited[$i]}" = "${name}"; then
				if test "${inherited[$i+1]}" = "${value}"; then
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
			# delete
			# shellcheck disable=SC2154
			if test "$shell" = 'fish'; then
				echo "set --universal --erase $name;"
			else
				echo "export $name='';"
			fi
		elif [[ "$name" = *'PATH' ]] || [[ "$name" = *'DIRS' ]]; then
			# trim trailing nothing
			separator_index="${#value}"
			if test "${value:separator_index-1:1}" = ':'; then
				value="${value:0:separator_index-1}"
			fi
			if test "$shell" = 'fish'; then
				echo "set --export --path $name '$value';"
			else
				echo "export $name='$value';"
			fi
		else
			if test "$shell" = 'fish'; then
				echo "set --export $name '$value';"
			else
				echo "export $name='$value';"
			fi
		fi
	done < <(env)
}
trap finish EXIT
