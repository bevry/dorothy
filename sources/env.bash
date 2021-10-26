#!/usr/bin/env sh

# NOTES
# $shell is defined by sourcer
# echos should suffix with ; otherwise fish support breaks

# initial scanning of environment
inherited=()
while read -r line; do
	# parse
	IFS='=' read -ra fodder <<<"$line"
	name="${fodder[0]}"
	# process
	inherited+=("$name")
done < <(env)

# final scanning of environment, and echo results
function finish() {
	while read -r line; do
		# parse
		IFS='=' read -ra fodder <<<"$line"
		name="${fodder[0]}"
		# discard inherited
		for i in "${inherited[@]}"; do
			if test "$name" = "$i"; then
				continue 2
			fi
		done
		# process remaining
		if test "${#fodder[@]}" -gt 1; then
			value="${fodder[1]}"
			for i in "${fodder[@]:2}"; do
				value="$value=$i"
			done
		fi
		# type
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
			c="${#value}"
			if test "${value:c-1:1}" = ':'; then
				value="${value:0:c-1}"
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
