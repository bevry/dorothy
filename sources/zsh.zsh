#!/usr/bin/env zsh

# https://zsh.sourceforge.io/Doc/Release/Conditional-Expressions.html#Conditional-Expressions

# =============================================================================
# Print Helpers

# These should be the same in [bash.bash] and [zsh.zsh].
# They exist because [echo] has flaws, notably [v='-n'; echo "$v"] will not output [-n].
# In UNIX there is no difference between an empty string and no input:
# empty stdin:  printf '' | wc
#               wc < <(printf '')
#    no stdin:  : | wc
#               wc < <(:)

# print each argument concatenated together with no spacing, if no arguments, do nothing
function __print_string { # b/c alias for __print_strings_or_nothing
	if [[ "$#" -ne 0 ]] then
		printf '%s' "$@"
	fi
}
function __print_strings { # b/c alias for __print_strings_or_nothing
	if [[ "$#" -ne 0 ]] then
		printf '%s' "$@"
	fi
}
function __print_strings_or_nothing {
	if [[ "$#" -ne 0 ]] then
		printf '%s' "$@"
	fi
}

# print each argument on its own line, if no arguments, print a line
function __print_line {
	printf '\n'
}
function __print_lines_or_line {
	# equivalent to [printf '\n'] if no arguments
	printf '%s\n' "$@"
}

# print each argument on its own line, if no arguments, do nothing
function __print_lines { # b/c alias for __print_lines_or_nothing
	if [[ "$#" -ne 0 ]] then
		printf '%s\n' "$@"
	fi
}
function __print_lines_or_nothing {
	if [[ "$#" -ne 0 ]] then
		printf '%s\n' "$@"
	fi
}

# print only arguments that are non-empty, concatenated together with no spacing, if no arguments, do nothing
function __print_value_strings_or_nothing {
	local values=()
	while [[ "$#" -ne 0 ]] do
		if [[ -n "$1" ]] then
			values+=("$1")
		fi
		shift
	done
	if [[ "${#values[@]}" -ne 0 ]] then
		printf '%s' "${values[@]}"
	fi
}

# print only arguments that are non-empty on their own line, if no arguments, do nothing
function __print_value_lines_or_nothing {
	local values=()
	while [[ "$#" -ne 0 ]] do
		if [[ -n "$1" ]] then
			values+=("$1")
		fi
		shift
	done
	if [[ "${#values[@]}" -ne 0 ]] then
		printf '%s\n' "${values[@]}"
	fi
}

# print only arguments that are non-empty on their own line, if no arguments, print a line
function __print_value_lines_or_line {
	local values=()
	while [[ "$#" -ne 0 ]] do
		if [[ -n "$1" ]] then
			values+=("$1")
		fi
		shift
	done
	if [[ "${#values[@]}" -eq 0 ]] then
		printf '\n'
	else
		printf '%s\n' "${values[@]}"
	fi
}
