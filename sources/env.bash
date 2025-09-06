#!/usr/bin/env bash

# This command is another piece of pure magic by @balupton
# It outputs the differences in environment variables from sourcing to exit

# IMPORTED BY SOURCE STATEMENT
# $option_shell - the current shell name, e.g. `fish` or `bash` or `zsh`
#
# NOTES
# echos should suffix with ; otherwise fish will break

function __env_parse {
	REPLY=() # [name, value], [name, value], ...
	local env line name value found
	local -i index size
	env="$(env | sort)" || return $? # maybe `declare -p` and filtering for `declare -x` would be faster???
	__dump --debug --value='== ENV ==' {env} || :
	while read -r line; do
		name='' value='' size=${#line} found=no
		for ((index = 0; index < size; index++)); do
			if [[ ${line:index:1} == '=' ]]; then
				name="${line:0:index}"
				value="${line:index+1}"
				REPLY+=("$name" "$value")
				found=yes
				break
			fi
		done
		if [[ $found == 'no' ]]; then
			# no equals sign, so an environment variable has outputted outputted a newline and messed everything up
			env="$(env)"
			__dump --value='== LAST ENV ENTRY IS MISSING ASSIGNMENT ==' {env} {REPLY} {line} >&2 || :
			return 22 # EINVAL 22 Invalid argument
		fi
	done <<<"$env"
}

if __has_array_capability 'associative'; then
	declare -A inherited
	function __env_inherited {
		local REPLY name value
		local -i index
		__env_parse || return
		for ((index = 0; index < ${#REPLY[@]}; index += 2)); do
			name="${REPLY[index]}"
			value="${REPLY[index + 1]}"
			inherited["$name"]="$value"
		done
	}
else
	inherited=() # [name, value, name, value, ...]
	function __env_inherited {
		local REPLY
		__env_parse || return
		# trunk-ignore(shellcheck/SC2190)
		inherited=("${REPLY[@]}")
	}
fi
__env_inherited || exit

# final scanning of environment, and output results
function __on_env_finish {
	# ignore failure conditions
	local -i last_status=$?
	if [[ $last_status -ne 0 ]]; then
		return "$last_status"
	fi

	local -i index inherited_size=${#inherited[@]}
	local REPLY name value delimiter values=() is_path results=() original_value
	__env_parse || return
	set -- "${REPLY[@]}"
	while [[ $# -ne 0 ]]; do
		name="$1" value="$2"
		shift 2

		# ignore shell level
		# fixes: [set: Tried to change the read-only variable 'SHLVL'] on fish shell
		if [[ $name == 'SHLVL' ]]; then
			continue
		fi

		# adjust
		delimiter='' is_path='no'
		if [[ $name =~ (PATH|DIRS)$ ]]; then
			delimiter=':' is_path='yes'
		elif [[ $name =~ FLAGS$ ]]; then
			delimiter=' '
		fi

		# de-duplicate split values
		if [[ -n $delimiter ]]; then
			# trunk-ignore(shellcheck/SC2034)
			original_value="$value" values=()
			__split --source={value} --delimiter="$delimiter" --target={values} --no-zero-length || return
			__unique --source+target={values} || return
			__join --source={values} --delimiter="$delimiter" --target={value} || return
			if [[ -z $value && $name == 'PATH' ]]; then
				__dump --value='== DE-DUPLICATION FAILED ==' {name} {original_value} {delimiter} {values} {value} {is_path} >&2 || :
				return 22 # EINVAL 22 Invalid argument
			fi
			__dump --debug --value='== DE-DUPLICATED ==' {name} {original_value} {delimiter} {value} || :
		fi

		# find it in inherited, and check if it is the same if it is the same as inherited
		if __has_array_capability 'associative'; then
			if [[ -n ${inherited["$name"]-} && ${inherited["$name"]} == "$value" ]]; then
				__dump --debug --value='== SKIP INHERITED ==' {name} {value} || :
				continue
			fi
		else
			for ((index = 0; index < inherited_size; index += 2)); do
				if [[ ${inherited[index]} == "$name" ]]; then
					if [[ ${inherited[index + 1]} == "$value" ]]; then
						# is inherited, continue to next item
						__dump --debug --value='== SKIP INHERITED ==' {name} {value} || :
						continue 2
					fi
				fi
			done
		fi

		# output the variable action based on type
		if [[ -z $value ]]; then
			# output var action: delete
			__dump --debug --value='== DELETE ==' {name} {value} || :
			if [[ $option_shell == 'fish' ]]; then
				results+=("set --universal --erase $name;")
			elif [[ $option_shell == 'nu' ]]; then
				results+=("setenv $name")
			elif [[ $option_shell == 'xonsh' ]]; then
				results+=("if \${...}.get('$name') != None:"$'\n\t'"del \$$name")
			elif [[ $option_shell == 'elvish' ]]; then
				# https://elv.sh/ref/builtin.html#unset-env
				results+=("unset-env $name")
			else
				results+=("unset -v $name;")
			fi
		elif [[ $is_path == 'yes' ]]; then
			# output var action: set path
			__dump --debug --value='== SET PATH ==' {name} {value} || :
			if [[ $option_shell == 'fish' ]]; then
				results+=("set --export --path $name '$value';")
			elif [[ $option_shell == 'nu' ]]; then
				results+=("setenv $name $value")
			elif [[ $option_shell == 'xonsh' ]]; then
				results+=('$'"$name = '$value'.split(':')")
			elif [[ $option_shell == 'elvish' ]]; then
				# https://elv.sh/ref/builtin.html#set-env
				results+=("set-env $name '$value'")
			else
				results+=("export $name='$value';")
			fi
		else
			# output var action: set
			__dump --debug --value='== SET ==' {name} {value} || :
			if [[ $option_shell == 'fish' ]]; then
				results+=("set --export $name '$value';")
			elif [[ $option_shell == 'nu' ]]; then
				results+=("setenv $name $value")
			elif [[ $option_shell == 'xonsh' ]]; then
				results+=('$'"$name = '$value'")
			elif [[ $option_shell == 'elvish' ]]; then
				# https://elv.sh/ref/builtin.html#set-env
				results+=("set-env $name '$value'")
			else
				results+=("export $name='$value';")
			fi
		fi
	done

	# xonsh needs a trailing newline, because xonsh, fixes:
	# > xonsh
	# xonsh: For full traceback set: $XONSH_SHOW_TRACEBACK = True
	# SyntaxError: None: no further code
	# syntax error in xonsh run control file '/Users/balupton/.config/xonsh/rc.xsh': None: no further code
	if [[ $option_shell == 'xonsh' ]]; then
		results+=('')
	fi

	# output all the results
	__print_lines "${results[@]}" || return
}
trap __on_env_finish EXIT
