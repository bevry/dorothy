#!/usr/bin/env bash

# Historical `bash.bash` implementations for usage in testing and comparison for when things break.
# Consumed by `dorothy-internals`

if [[ $BASH_VERSION_MAJOR -gt 4 || ($BASH_VERSION_MAJOR -eq 4 && $BASH_VERSION_MINOR -ge 4) ]]; then
	IS_BASH_VERSION_OUTDATED='no'
else
	IS_BASH_VERSION_OUTDATED='yes'
fi

# function __is_standard_function {
# 	local cmd="$1" inner
# 	inner="$(declare -f "$cmd")"
# 	[[ $inner == "$cmd"$' () \n{ \n    '* && $inner != "$cmd"$' () \n{ \n    ('* ]] || return $? # explicit `|| return` required to prevent ERR trap from firing, which is important here as it is used within our ERR trap
# }

# function __is_safety_function {
# 	local cmd="$1"
# 	[[ $cmd == __* ]] || return $? # explicit `|| return` required to prevent ERR trap from firing, which is important here as it is used within our ERR trap
# }

# function __is_catchable_function {
# 	local cmd="$1"
# 	if __is_safety_function "$cmd" || __is_subshell_function__internal "$cmd"; then
# 		return 0
# 	else
# 		return 1
# 	fi
# }

# function __has_subshell_function_until {
# 	local until="$1"
# 	# if it is only this helper function then skip
# 	if [[ ${#FUNCNAME[@]} -le 1 ]]; then
# 		return 1
# 	fi
# 	for cmd in "${FUNCNAME[@]:1}"; do
# 		if [[ $cmd == "$until" ]]; then
# 			break
# 		fi
# 		if __is_subshell_function__internal "$cmd"; then
# 			return 0
# 		fi
# 	done
# 	return 1
# }

# function __has_catchable_function_until {
# 	local until="$1"
# 	if it is only this helper function then skip
# 	if [[ ${#FUNCNAME[@]} -le 1 ]]; then
# 		return 1
# 	fi
# 	for cmd in "${FUNCNAME[@]:1}"; do
# 		if [[ $cmd == "$until" ]]; then
# 			break
# 		fi
# 		if __is_catchable_function "$cmd"; then
# 			return 0
# 		fi
# 	done
# 	return 1
# }

# now for our implementation overrides
case "$option_implementation" in

# if core, don't do any overrides, as it is already loaded
core) ;;

# 12e208e: Aug 15, 2023: huge reliability improvements
# The first version of the implementation
# https://github.com/bevry/dorothy/commit/12e208eac8423d632250994a53c1c1835c55d6da#diff-fdce5cb2b4ffb7374573ddbe18177d5d871da104db96cce483934d4a0dc50ea6
# https://github.com/bevry/dorothy/blob/12e208eac8423d632250994a53c1c1835c55d6da/sources/bash.bash#L75
1 | i1 | v1 | event-only | 12e208e | 12e208eac8423d632250994a53c1c1835c55d6da)
	# pros:
	# - simple
	# cons:
	# - CHECK NESTED [ERREXIT] <-- fails on bash v3
	# - CHECK NESTED [ERREXIT] [SUBSHELL WITH ERREXIT DISABLED] <-- fails on all bash versions
	function __try {
		# Re-assert the trap such that even subshells are given it
		# The trap is not cleaned up, so we need to support exit status
		trap 'DOROTHY_TRY__TRAP_STATUS=$?; if test "${FUNCNAME-}" = 'dorothy_try__wrapper'; then return 0; elif test -n "${FUNCNAME-}"; then return "$DOROTHY_TRY__TRAP_STATUS"; else exit "$DOROTHY_TRY__TRAP_STATUS"; fi' ERR

		# Process the arguments
		local item cmd=() exit_status_variable_name=''
		while [[ $# -ne 0 ]]; do
			item="$1"
			shift
			case "$item" in
			'--')
				cmd+=("$@")
				shift $#
				break
				;;
			{*}) __dereference --source={item} --name={exit_status_variable_name} || return $? ;;
			*)
				__print_lines "ERROR: __try: An unrecognised flag was provided: $item" >&2 || :
				return 22 # EINVAL 22 Invalid argument
				;;
			esac
		done

		# Wrap the command, such that our trap can identify it
		function dorothy_try__wrapper {
			"${cmd[@]}"
		}
		dorothy_try__wrapper

		# Apply and unset the exit status caught by our trap
		if [[ -n $exit_status_variable_name ]]; then
			eval "${exit_status_variable_name}=${DOROTHY_TRY__TRAP_STATUS:-0}"
		fi
		unset -v DOROTHY_TRY__TRAP_STATUS

		# Return success
		return 0
	}
	;;

# c1fe25b: Jan 16, 2024: eval_capture: subshell and bash v3 compatibility
# Introduces a more complicated trap: supports invoking subshells, now has bash v3 compatibility, doesn't need to alter set/shopt options, and will delete the trap when no longer required
# https://github.com/bevry/dorothy/commit/c1fe25b4a2382fc979dace2d23ee15efd60d8c28
# https://github.com/bevry/dorothy/blob/c1fe25b4a2382fc979dace2d23ee15efd60d8c28/sources/bash.bash
# https://github.com/bevry/dorothy/commit/9b4177f23934de9ab669ed26c15e729a14cedf2b
# https://github.com/bevry/dorothy/blob/9b4177f23934de9ab669ed26c15e729a14cedf2b/sources/bash.bash
# https://github.com/bevry/dorothy/commit/596a6bd2c8558d4c8eb61d128e66d0df5763cf63
# https://github.com/bevry/dorothy/blob/596a6bd2c8558d4c8eb61d128e66d0df5763cf63/sources/bash.bash
2 | i2 | v2 | c1fe25b | c1fe25b4a2382fc979dace2d23ee15efd60d8c28)
	function __try {
		# Process the arguments
		local item cmd=() exit_status_variable_name=''
		while [[ $# -ne 0 ]]; do
			item="$1"
			shift
			case "$item" in
			'--')
				cmd+=("$@")
				shift $#
				break
				;;
			{*}) __dereference --source={item} --name={exit_status_variable_name} || return $? ;;
			*)
				__print_lines "ERROR: __try: An unrecognised flag was provided: $item" >&2 || :
				return 22 # EINVAL 22 Invalid argument
				;;
			esac
		done

		# prepare
		DOROTHY_TRY__COUNT="${DOROTHY_TRY__COUNT:-0}"
		local DOROTHY_TRY__STATUS=
		local DOROTHY_TRY__CONTEXT="$RANDOM"
		local DOROTHY_TRY__COMMAND=("${cmd[@]}")
		local DOROTHY_TRY__SUBSHELL="${BASH_SUBSHELL-}"
		local DOROTHY_TRY__DIR="$TMPDIR/dorothy/try" # don't use mktemp as it requires -s checks, as it actually makes the files, this doesn't make the files
		local DOROTHY_TRY__FILE_STATUS="$DOROTHY_TRY__DIR/$DOROTHY_TRY__CONTEXT.status"
		__mkdirp "$DOROTHY_TRY__DIR"
		function dorothy_try__trap {
			local trap_status="$1" trap_fn="$2" trap_cmd="$3" trap_subshell="$4" trap_context="$5"
			if test "$DOROTHY_TRY__CONTEXT" = "$trap_context"; then
				if test "$DOROTHY_TRY__SUBSHELL" = "$trap_subshell" -o "$trap_fn" = 'dorothy_try__wrapper'; then
					DOROTHY_TRY__STATUS="$trap_status"
					return 0
				elif test "$IS_BASH_VERSION_OUTDATED" = 'yes'; then
					__print_lines "$trap_status" >"$DOROTHY_TRY__FILE_STATUS"
					return "$trap_status"
				fi
			fi
			return "$trap_status"
		}

		# run the command and capture its exit status, and if applicable, capture its stdout
		# - if trapped an error inside this function, it will return this immediately
		# - if trapped an error inside a nested execution, it will run the trap inside that, allowing this function to continue
		# as such, we must cleanup inside the trap and after the trap, and cleanup must work in both contexts
		function dorothy_try__wrapper {
			DOROTHY_TRY__COUNT="$((DOROTHY_TRY__COUNT + 1))"
			# wrap if the $- check, as always returning causes +e to return when it shouldn't
			trap 'DOROTHY_TRY__TRAP_STATUS=$?; if [[ $- = *e* ]]; then dorothy_try__trap "$DOROTHY_TRY__TRAP_STATUS" "${FUNCNAME-}" "${cmd[*]}" "${BASH_SUBSHELL-}" "$DOROTHY_TRY__CONTEXT"; return $?; fi' ERR
			# can't delegate this to a function (e.g. is_subshell_function), as the trap will go to the function
			if test "$IS_BASH_VERSION_OUTDATED" = 'yes' && [[ $- == *e* ]] && [[ "$(declare -f "${cmd[0]}")" == "${cmd[0]}"$' () \n{ \n    ('* ]]; then
				# ALL SUBSHELLS SHOULD RE-ENABLE [set -e]
				set +e
				(
					set -e
					"${cmd[@]}"
				)
				set -e
				return 0
			fi
			"${cmd[@]}"
			return 0
		}
		dorothy_try__wrapper

		# remove the lingering trap
		DOROTHY_TRY__COUNT="$((DOROTHY_TRY__COUNT - 1))"
		if [[ $DOROTHY_TRY__COUNT -eq 0 ]]; then
			trap - ERR
		fi

		# save the exit status, and c_end_field the global value
		if [[ $IS_BASH_VERSION_OUTDATED == 'yes' && -f $DOROTHY_TRY__FILE_STATUS ]]; then
			DOROTHY_TRY__STATUS="$(<"$DOROTHY_TRY__FILE_STATUS")"
			rm -f -- "$DOROTHY_TRY__FILE_STATUS"
		fi
		if [[ -n $exit_status_variable_name ]]; then
			eval "$exit_status_variable_name=${DOROTHY_TRY__STATUS:-0}"
		fi

		# return success
		return 0
	}
	;;

# 5c44792: Jan 17, 2024: dorothy: curl bash.bash, eval_capture: fix set +e
# Introduces exit status capture within the wrapper, and breaks saving of the exit status to a temp file
# https://github.com/bevry/dorothy/commit/5c44792a6c46950cb74dee03383efdbe8018ebec#diff-fdce5cb2b4ffb7374573ddbe18177d5d871da104db96cce483934d4a0dc50ea6
# https://github.com/bevry/dorothy/blob/5c44792a6c46950cb74dee03383efdbe8018ebec/sources/bash.bash

# 43abfda: Feb 2, 2024: setup-server, mount-helper: bugfixes
# Introduces aliases for arguments
# https://github.com/bevry/dorothy/commit/43abfda157514f63a285ea10a51366aceff9505d#diff-fdce5cb2b4ffb7374573ddbe18177d5d871da104db96cce483934d4a0dc50ea6

# c4d1e1f: Oct 28, 2024: ask, choose, confirm: comprehensive support of TTY modes and capabilities (#254)
# Changes from `test` to `[[`
# https://github.com/bevry/dorothy/commit/c4d1e1fb92eb60e82a5501b4c017e58d81c364ce#diff-fdce5cb2b4ffb7374573ddbe18177d5d871da104db96cce483934d4a0dc50ea6

# 622311f: Jan 30, 2025: bash.bash:  increase entropy for context, simpler eval statements for easier human parsing
# Increases entropy of context identifier
# https://github.com/bevry/dorothy/commit/622311fe525550dc4a2c6eaf76e16f1b9ab61d68
# Attempts to fix:
# https://github.com/bevry/dorothy/actions/runs/13038210988/job/36373738417#step:2:7505
# https://github.com/bevry/dorothy/actions/runs/13038210988/job/36373738417#step:2:12541

# 3f47d47: Feb 3, 2025: remove unnecessary $? in return and exit calls
# Breaks eval_capture for a day as the trap return requires `$?``
# https://github.com/bevry/dorothy/commit/3f47d4702560c40cb9f6d82b31be572f10dbbfee#diff-fdce5cb2b4ffb7374573ddbe18177d5d871da104db96cce483934d4a0dc50ea6

# d377355: Feb 3, 2025: bash.bash: eval-capture: fix regression from 3f47d47
# Works around the bug of `return` needing to be `return $?` inside the traps
# https://github.com/bevry/dorothy/commit/d37735588a39ee768ed7717a3a8ba45e8d6f9590
# Fixes:
# https://github.com/bevry/dorothy/actions/runs/13102792036
3 | i3 | v3 | d377355 | d37735588a39ee768ed7717a3a8ba45e8d6f9590)
	function __try {
		# Process the arguments
		local item cmd=() exit_status_variable_name=''
		while [[ $# -ne 0 ]]; do
			item="$1"
			shift
			case "$item" in
			'--')
				cmd+=("$@")
				shift $#
				break
				;;
			{*}) __dereference --source={item} --name={exit_status_variable_name} || return $? ;;
			*)
				__print_lines "ERROR: __try: An unrecognised flag was provided: $item" >&2 || :
				return 22 # EINVAL 22 Invalid argument
				;;
			esac
		done

		# prepare
		DOROTHY_TRY__COUNT="${DOROTHY_TRY__COUNT:-0}"
		local DOROTHY_TRY__STATUS=
		local DOROTHY_TRY__CONTEXT="$RANDOM$RANDOM$RANDOM"
		local DOROTHY_TRY__SUBSHELL="${BASH_SUBSHELL-}"
		local DOROTHY_TRY__DIR="$TMPDIR/dorothy/try" # don't use mktemp as it requires -s checks, as it actually makes the files, this doesn't make the files
		local DOROTHY_TRY__FILE_STATUS="$DOROTHY_TRY__DIR/$DOROTHY_TRY__CONTEXT.status"
		__mkdirp "$DOROTHY_TRY__DIR"
		function dorothy_try__trap {
			# trunk-ignore(shellcheck/SC2034)
			local trap_status="$1" trap_fn="$2" trap_cmd="$3" trap_subshell="$4" trap_context="$5"
			if [[ $DOROTHY_TRY__CONTEXT == "$trap_context" ]]; then
				if [[ $DOROTHY_TRY__SUBSHELL == "$trap_subshell" || $trap_fn == 'dorothy_try__wrapper' ]]; then
					DOROTHY_TRY__STATUS="$trap_status"
					return 0
				elif [[ $IS_BASH_VERSION_OUTDATED == 'yes' ]]; then
					# __print_lines "$trap_status" >"$DOROTHY_TRY__FILE_STATUS"
					return "$trap_status"
				fi
			fi
			return "$trap_status"
		}

		# execute the command within our wrapper, such that we can handle edge cases, and identify it inside our trap
		function dorothy_try__wrapper {
			local continued_status
			DOROTHY_TRY__COUNT="$((DOROTHY_TRY__COUNT + 1))"
			trap 'DOROTHY_TRY__TRAP_STATUS=$?; if [[ $- = *e* ]]; then dorothy_try__trap "$DOROTHY_TRY__TRAP_STATUS" "${FUNCNAME-}" "${cmd[*]}" "${BASH_SUBSHELL-}" "$DOROTHY_TRY__CONTEXT"; return $?; fi' ERR # the [$?] in [return $?] is necessary: https://github.com/bevry/dorothy/actions/runs/13102792036
			# can't delegate this to a function (e.g. is_subshell_function), as the trap will go to the function
			if [[ $IS_BASH_VERSION_OUTDATED == 'yes' && $- == *e* && "$(declare -f "${cmd[0]}")" == "${cmd[0]}"$' () \n{ \n    ('* ]]; then
				# ALL SUBSHELLS SHOULD RE-ENABLE [set -e]
				# __print_lines "SUBSHELL $-" >/dev/tty
				set +e
				(
					set -e
					"${cmd[@]}"
				)
				continued_status=$?
				set -e
			else
				"${cmd[@]}"
				continued_status=$?
			fi
			# capture status in case of set +e
			if [[ $continued_status -ne 0 ]]; then
				DOROTHY_TRY__STATUS="$continued_status"
			fi
			# we've stored the status, we return success
			return 0
		}
		dorothy_try__wrapper

		# remove the lingering trap
		DOROTHY_TRY__COUNT="$((DOROTHY_TRY__COUNT - 1))"
		if [[ $DOROTHY_TRY__COUNT -eq 0 ]]; then
			trap - ERR
		fi

		# load the exit status if necessary, this will never occur as this version has the saving commented out
		if [[ $IS_BASH_VERSION_OUTDATED == 'yes' && -f $DOROTHY_TRY__FILE_STATUS ]]; then
			DOROTHY_TRY__STATUS="$(cat -- "$DOROTHY_TRY__FILE_STATUS")"
			rm -f -- "$DOROTHY_TRY__FILE_STATUS"
		fi
		if [[ -n $exit_status_variable_name ]]; then
			eval "${exit_status_variable_name}=${DOROTHY_TRY__STATUS:-0}"
		fi

		# return success
		return 0
	}
	;;

# never committed to master, was only in dev
# 3842e0f: Feb 10, 2025: improve eval_capture and test on all bash versions
# Use two randoms for entropy, restore status writing to file, use functions in errexit and subshell check now that they use `[[` instead of `test`, introduces semaphores for stdout/stderr/output files (now handled by `__do`)
# https://github.com/bevry/dorothy/commit/3842e0f09b0493a6e2c374e0c071d7390f2fe0f1
# https://github.com/bevry/dorothy/blob/3842e0f09b0493a6e2c374e0c071d7390f2fe0f1/sources/bash.bash
4 | i4 | v4 | 4a | i4a | v4a | 3842e0f)
	function __try {
		# Process the arguments
		local item cmd=() exit_status_variable_name=''
		while [[ $# -ne 0 ]]; do
			item="$1"
			shift
			case "$item" in
			'--')
				cmd+=("$@")
				shift $#
				break
				;;
			{*}) __dereference --source={item} --name={exit_status_variable_name} || return $? ;;
			*)
				__print_lines "ERROR: __try: An unrecognised flag was provided: $item" >&2 || :
				return 22 # EINVAL 22 Invalid argument
				;;
			esac
		done

		# prepare
		DOROTHY_TRY__COUNT="${DOROTHY_TRY__COUNT:-0}"
		local DOROTHY_TRY__STATUS=
		local DOROTHY_TRY__CONTEXT="$RANDOM$RANDOM"
		# ^ two randoms, as before `eval_capture_wait` solved the race condition, it could be that the temp files were not detected in the tail of this script and as such were not removed, and could persist, which would cause the below failures, now that `eval_capture_wait` is used, a single random should be sufficient, however we won't know until later

		local DOROTHY_TRY__COMMAND=("${cmd[@]}")
		local DOROTHY_TRY__SUBSHELL="${BASH_SUBSHELL-}"
		local DOROTHY_TRY__DIR="$TMPDIR/dorothy/try" # mktemp requires -s checks, as it actually makes the files, this doesn't make the files
		local DOROTHY_TRY__FILE_STATUS="$DOROTHY_TRY__DIR/$DOROTHY_TRY__CONTEXT.status"
		__mkdirp "$DOROTHY_TRY__DIR"
		function dorothy_try__trap {
			local trap_status="$1" trap_fn="$2" trap_location="$3" trap_subshell="$4" trap_context="$5"
			if [[ $DOROTHY_TRY__CONTEXT == "$trap_context" ]]; then
				if [[ $DOROTHY_TRY__SUBSHELL == "$trap_subshell" || $trap_fn == 'dorothy_try__wrapper' ]]; then
					dorothy_try__context_lines "SHARE: $trap_status" "LOCATION: $trap_location" || :
					DOROTHY_TRY__STATUS="$trap_status"
					return 0
				elif [[ $IS_BASH_VERSION_OUTDATED == 'yes' ]]; then
					dorothy_try__context_lines "SAVE: $trap_status" "LOCATION: $trap_location" || :
					__print_lines "$trap_status" >"$DOROTHY_TRY__FILE_STATUS"
					return "$trap_status"
				fi
			else
				dorothy_try__dump_lines "INVALID CONTEXT [$trap_context]" || :
			fi
			dorothy_try__context_lines "RETURN: $trap_status" "LOCATION: $trap_location" || :
			return "$trap_status"
		}

		# execute the command within our wrapper, such that we can handle edge cases, and identify it inside our trap
		function dorothy_try__wrapper {
			local continued_status
			DOROTHY_TRY__COUNT="$((DOROTHY_TRY__COUNT + 1))"

			# wrap the $- check, as always returning causes +e to return when it shouldn't
			# the [$?] in [return $?] in the trap is necessary: https://github.com/bevry/dorothy/actions/runs/13102792036
			trap 'DOROTHY_TRY__TRAP_STATUS=$?; if [[ $- = *e* ]]; then dorothy_try__trap "$DOROTHY_TRY__TRAP_STATUS" "${FUNCNAME-}" "${BASH_SOURCE[0]}:${LINENO}:${FUNCNAME-}:$-:$BASH_VERSION" "${BASH_SUBSHELL-}" "$DOROTHY_TRY__CONTEXT"; return $?; fi' ERR

			# if `__is_subshell_function__internal` uses test instead of [[, then under bash v3 with `set -e` then `__is_subshell_function__internal` will cause ERR to fire within the context of ${DOROTHY_TRY__COMMAND[0]} and will skip everything bel
			if [[ $IS_BASH_VERSION_OUTDATED == 'yes' ]] && __is_errexit && __is_subshell_function__internal "${DOROTHY_TRY__COMMAND[0]}"; then
				set +e
				(
					set -e
					"${DOROTHY_TRY__COMMAND[@]}"
				)
				continued_status=$?
				dorothy_try__context_lines "WORKAROUND: $continued_status" || :
				set -e
			else
				"${DOROTHY_TRY__COMMAND[@]}"
				continued_status=$?
				dorothy_try__context_lines "CONTINUED: $continued_status" || :
			fi

			# capture status in case of set +e
			if [[ $continued_status -ne 0 ]]; then
				DOROTHY_TRY__STATUS="$continued_status"
			fi

			# we've stored the status, we return success
			return 0
		}
		dorothy_try__wrapper

		# remove the lingering trap
		DOROTHY_TRY__COUNT="$((DOROTHY_TRY__COUNT - 1))"
		if [[ $DOROTHY_TRY__COUNT -eq 0 ]]; then
			trap - ERR
		fi

		# save the exit status, and reset the global value
		if [[ $IS_BASH_VERSION_OUTDATED == 'yes' && -f $DOROTHY_TRY__FILE_STATUS ]]; then
			local loaded_status
			loaded_status="$(cat -- "$DOROTHY_TRY__FILE_STATUS")"
			if [[ $loaded_status -ne $DOROTHY_TRY__STATUS ]]; then
				dorothy_try__context_lines "LOADED: $loaded_status    PRIOR: $DOROTHY_TRY__STATUS    NEEDED" || :
			else
				dorothy_try__context_lines "LOADED: $loaded_status    PRIOR: $DOROTHY_TRY__STATUS    SAME" || :
			fi
			DOROTHY_TRY__STATUS="$loaded_status"
			rm -f -- "$DOROTHY_TRY__FILE_STATUS"
		fi
		dorothy_try__context_lines "RESULT: ${DOROTHY_TRY__STATUS:-0}" || :
		if [[ -n $exit_status_variable_name ]]; then
			eval "${exit_status_variable_name}=${DOROTHY_TRY__STATUS:-0}"
		fi

		# return success
		return 0
	}
	;;

# never committed, improved version of the above for debugging, discovers that i4 worked better on old versions that i5 because of a throw-in-subshell coincidence in the trap
4b | i4b | v4b)
	# function dorothy_try__trap {
	# 	local trap_status="$1"
	# 	local trap_fn="$2"
	# 	local trap_location="$3"
	# 	if [[ -z ${DOROTHY_TRY__CONTEXT-} ]]; then
	# 		dorothy_try__dump_lines 'NO CONTEXT' || :
	# 	else
	# 		if [[ $DOROTHY_TRY__SUBSHELL == "${BASH_SUBSHELL-}" || $trap_fn == 'dorothy_try__wrapper' ]]; then
	# 			dorothy_try__context_lines "SHARE: $trap_status" "LOCATION: $trap_location" || :
	# 			DOROTHY_TRY__STATUS="$trap_status"
	# 			return 0
	# 		elif [[ $IS_BASH_VERSION_OUTDATED == 'yes' ]]; then
	# 			dorothy_try__context_lines "SAVE: $trap_status" "LOCATION: $trap_location" || :
	# 			__print_lines "$trap_status" >"$DOROTHY_TRY__FILE_STATUS"
	# 			return "$trap_status"
	# 		fi
	# 	fi
	# 	dorothy_try__context_lines "RETURN: $DOROTHY_TRY__TRAP_STATUS" "LOCATION: $trap_location" || :
	# 	return "$trap_status"
	# }
	function dorothy_try__trap {
		# do not use local, as this is not executed as a function
		local trap_status="$1"
		local trap_fn="$2"
		local trap_location="$3"

		# if we are applicable, necessary for `do recursed [subshell]` when not using --no-status
		if [[ -z ${DOROTHY_TRY__CONTEXT-} ]]; then
			dorothy_try__dump_lines 'NO CONTEXT' || :
		else
			# if [[ $DOROTHY_TRY__SUBSHELL == "${BASH_SUBSHELL-}" || $trap_fn == 'dorothy_try__wrapper' ]]; then
			# 	dorothy_try__context_lines "SHARE: $trap_status" "LOCATION: $trap_location" || :
			# 	DOROTHY_TRY__STATUS="$trap_status"
			# 	trap_status=0
			# 	# return 0
			# else
			# 	dorothy_try__context_lines "SAVE: $trap_status" "LOCATION: $trap_location" || :
			# 	__print_lines "$trap_status" >"$DOROTHY_TRY__FILE_STATUS"
			# 	# return "$trap_status"
			# fi

			# check subshell
			if [[ $DOROTHY_TRY__SUBSHELL != "${BASH_SUBSHELL-}" ]]; then
				dorothy_try__context_lines "SAVE: $trap_status" "LOCATION: $trap_location" || :
				__print_lines "$trap_status" >"$DOROTHY_TRY__FILE_STATUS"
			elif [[ $trap_fn == 'dorothy_try__wrapper' ]]; then
				dorothy_try__context_lines "SKIP: $trap_status" "LOCATION: $trap_location" || :
				DOROTHY_TRY__STATUS="$trap_status"
				trap_status=0
			else
				# we are in the same subshell, so our changes to DOROTHY_TRY__STATUS will persist
				dorothy_try__context_lines "SHARE: $trap_status" "LOCATION: $trap_location" || :
				DOROTHY_TRY__STATUS="$trap_status"
				trap_status=0
			fi

			# return the status accordingly
			dorothy_try__context_lines "RETURN: $trap_status" "LOCATION: $trap_location" || :
			return "$trap_status"

			# if [[ $trap_fn == 'dorothy_try__wrapper' ]]; then
			# 	dorothy_try__context_lines "SKIP: $DOROTHY_TRY__TRAP_STATUS" || :
			# 	return 0
			# elif [[ -n $trap_fn ]]; then
			# 	dorothy_try__context_lines "RETURN: $trap_status" "LOCATION: $trap_location" || :
			# 	return "$trap_status"
			# else
			# 	dorothy_try__context_lines "EXIT: $trap_status" "LOCATION: $trap_location" || :
			# 	exit "$trap_status"
			# fi
		fi
	}
	function dorothy_try__trap_outer {
		# $- check as always returning causes +e to return when it shouldn't
		# the [$?] in [return $?] in the trap is necessary: https://github.com/bevry/dorothy/actions/runs/13102792036
		DOROTHY_TRY__TRAP_STATUS=$?
		if __is_errexit; then
			dorothy_try__trap "$DOROTHY_TRY__TRAP_STATUS" "${FUNCNAME-}" "${BASH_SOURCE[0]}:${LINENO}:${FUNCNAME-}:$-:$BASH_VERSION"
			return $?
		fi
	}
	# function dorothy_try__trap_outer {
	# 	trap_status=$?
	# 	trap_fn="${FUNCNAME-}"
	# 	if [[ $- == *e* ]]; then
	# 		if [[ -z ${DOROTHY_TRY__CONTEXT-} ]]; then
	# 			dorothy_try__dump_lines 'NO CONTEXT' || :
	# 		else
	# 			if [[ $DOROTHY_TRY__SUBSHELL == "${BASH_SUBSHELL-}" || $trap_fn == 'dorothy_try__wrapper' ]]; then
	# 				dorothy_try__context_lines "SHARE: $trap_status" "LOCATION: ${BASH_SOURCE[0]}:${LINENO}:${FUNCNAME-}:$-:$BASH_VERSION" || :
	# 				DOROTHY_TRY__STATUS="$trap_status"
	# 				return 0
	# 			elif [[ $IS_BASH_VERSION_OUTDATED == 'yes' ]]; then
	# 				dorothy_try__context_lines "SAVE: $trap_status" "LOCATION: ${BASH_SOURCE[0]}:${LINENO}:${FUNCNAME-}:$-:$BASH_VERSION" || :
	# 				__print_lines "$trap_status" >"$DOROTHY_TRY__FILE_STATUS"
	# 				return "$trap_status"
	# 			fi
	# 		fi
	# 		dorothy_try__context_lines "RETURN: $DOROTHY_TRY__TRAP_STATUS" "LOCATION: ${BASH_SOURCE[0]}:${LINENO}:${FUNCNAME-}:$-:$BASH_VERSION" || :
	# 		return "$trap_status"
	# 	fi
	# }
	dorothy_try__trap_inner="$(__get_function_inner dorothy_try__trap_outer)"
	function dorothy_try__wrapper {
		local continued_status
		DOROTHY_TRY__COUNT="$((DOROTHY_TRY__COUNT + 1))"

		# trunk-ignore(shellcheck/SC2064)
		trap "$dorothy_try__trap_inner" ERR

		# if `__is_subshell_function__internal` uses test instead of [[, then under bash v3 with `set -e` then `__is_subshell_function__internal` will cause ERR to fire within the context of ${DOROTHY_TRY__COMMAND[0]} and will skip everything bel
		if [[ $IS_BASH_VERSION_OUTDATED == 'yes' ]] && __is_errexit && __is_subshell_function__internal "${DOROTHY_TRY__COMMAND[0]}"; then
			set +e
			(
				set -e
				"${DOROTHY_TRY__COMMAND[@]}"
			)
			continued_status=$?
			dorothy_try__context_lines "WORKAROUND: $continued_status" || :
			set -e
		else
			"${DOROTHY_TRY__COMMAND[@]}"
			continued_status=$?
			dorothy_try__context_lines "CONTINUED: $continued_status" || :
		fi

		# capture status in case of set +e
		if [[ $continued_status -ne 0 ]]; then
			DOROTHY_TRY__STATUS="$continued_status"
		fi

		# we've stored the status, we return success
		return 0
	}
	function __try {
		# Process the arguments
		local item cmd=() exit_status_variable_name=''
		while [[ $# -ne 0 ]]; do
			item="$1"
			shift
			case "$item" in
			'--')
				cmd+=("$@")
				shift $#
				break
				;;
			{*}) __dereference --source={item} --name={exit_status_variable_name} || return $? ;;
			*)
				__print_lines "ERROR: __try: An unrecognised flag was provided: $item" >&2 || :
				return 22 # EINVAL 22 Invalid argument
				;;
			esac
		done

		# prepare
		DOROTHY_TRY__COUNT="${DOROTHY_TRY__COUNT:-0}"
		local DOROTHY_TRY__STATUS=
		local DOROTHY_TRY__CONTEXT="$RANDOM$RANDOM"
		# ^ two randoms, as before `eval_capture_wait` solved the race condition, it could be that the temp files were not detected in the tail of this script and as such were not removed, and could persist, which would cause the below failures, now that `eval_capture_wait` is used, a single random should be sufficient, however we won't know until later

		local DOROTHY_TRY__COMMAND=("${cmd[@]}")
		local DOROTHY_TRY__SUBSHELL="${BASH_SUBSHELL-}"
		local DOROTHY_TRY__DIR="$TMPDIR/dorothy/try" # mktemp requires -s checks, as it actually makes the files, this doesn't make the files
		local DOROTHY_TRY__FILE_STATUS="$DOROTHY_TRY__DIR/$DOROTHY_TRY__CONTEXT.status"
		__mkdirp "$DOROTHY_TRY__DIR"

		# execute the command within our wrapper, such that we can handle edge cases, and identify it inside our trap
		dorothy_try__wrapper

		DOROTHY_TRY__COUNT="$((DOROTHY_TRY__COUNT - 1))"
		if [[ $DOROTHY_TRY__COUNT -eq 0 ]]; then
			# remove the lingering trap
			trap - ERR
		fi

		# save the exit status, and reset the global value
		if [[ $IS_BASH_VERSION_OUTDATED == 'yes' && -f $DOROTHY_TRY__FILE_STATUS ]]; then
			local loaded_status
			loaded_status="$(cat -- "$DOROTHY_TRY__FILE_STATUS")"
			if [[ $loaded_status -ne $DOROTHY_TRY__STATUS ]]; then
				dorothy_try__context_lines "LOADED: $loaded_status    PRIOR: $DOROTHY_TRY__STATUS    NEEDED" || :
			else
				dorothy_try__context_lines "LOADED: $loaded_status    PRIOR: $DOROTHY_TRY__STATUS    SAME" || :
			fi
			DOROTHY_TRY__STATUS="$loaded_status"
			rm -f -- "$DOROTHY_TRY__FILE_STATUS"
		fi
		dorothy_try__context_lines "RESULT: ${DOROTHY_TRY__STATUS:-0}" || :
		if [[ -n $exit_status_variable_name ]]; then
			eval "${exit_status_variable_name}=${DOROTHY_TRY__STATUS:-0}"
		fi

		# return success
		return 0
	}
	;;

# i5 was a multi-week effort on a dev branch, that the i4b backports some of its discoveries
# i5 has these improvements over i4:
# The trap no longer calls a function that may return a non-zero exit status, as if we are in the same shell context, then doing so would cause ERR to be attempted to be fired again but as ERR is already firing, that will cause a crash: https://stackoverflow.com/a/35399258/130638
# Instead, we only have a trap now, and it source is fetched from a function inner as this enables syntax highlighting.
# This revealed that the CONTEXT check was unnecessary, as it will always be the same.
# i5 has these regressions over i4:
# There are increased failures on v3.2 to v4.3, as it does not have the throw-in-subshell workaround necessary for those
5 | i5 | v5 | 5a | i5a | v5a)
	function dorothy_try__trap_outer {
		# do not use local, as this is not executed as a function
		DOROTHY_TRY__TRAP_STATUS=$?
		DOROTHY_TRY__TRAP_LOCATION="${BASH_SOURCE[0]}:${LINENO}:${FUNCNAME-}:$-:$BASH_VERSION"

		# if we are applicable, necessary for `do recursed [subshell]` when not using --no-status
		if [[ -z ${DOROTHY_TRY__CONTEXT-} ]]; then
			dorothy_try__dump_lines 'NO CONTEXT' || :
		elif __is_not_errexit; then
			# not applicable, as we are not in errexit, so want to continue as usual
			dorothy_try__dump_lines "NO ERREXIT $-" || :
		else
			# we are in errexit, we caught a thrown exception, a crash will occur and EXIT will fire, unless we return anything
			# returning a non-zero exit status in bash v4.4 and up causes the non-zero exit status to be returned to the caller
			# returning a non-zero exit status in bash versions earlier that v4.4 will cause 0 to be returned to the caller
			# I have been unable to find a way for a non-zero exit status to propagate to the caller in bash versions earlier than v4.4
			# using [__return ...] instead of [return ...] just causes the crash to occur

			# check subshell
			if [[ $DOROTHY_TRY__SUBSHELL == "${BASH_SUBSHELL-}" ]]; then
				# we are in the same subshell, so our changes to DOROTHY_TRY__STATUS will persist
				dorothy_try__context_lines "SHARE: $DOROTHY_TRY__TRAP_STATUS" "LOCATION: $DOROTHY_TRY__TRAP_LOCATION" || :
				DOROTHY_TRY__STATUS="$DOROTHY_TRY__TRAP_STATUS"
			else
				# lacking this causes nearly all subshell executions to fail on 3.2, 4.0, 4.2
				dorothy_try__context_lines "SAVE: $DOROTHY_TRY__TRAP_STATUS" "LOCATION: $DOROTHY_TRY__TRAP_LOCATION" || :
				{ __mkdirp "$DOROTHY_TRY__DIR" && __print_lines "$DOROTHY_TRY__TRAP_STATUS" >"$DOROTHY_TRY__FILE_STATUS"; } || :
			fi

			# return the status accordingly
			if [[ ${FUNCNAME-} == 'dorothy_try__wrapper' ]]; then
				dorothy_try__context_lines "SKIP: $DOROTHY_TRY__TRAP_STATUS" || :
				return 0
			elif [[ -n ${FUNCNAME-} ]]; then
				dorothy_try__context_lines "RETURN: $DOROTHY_TRY__TRAP_STATUS" "LOCATION: $DOROTHY_TRY__TRAP_LOCATION" || :
				return "$DOROTHY_TRY__TRAP_STATUS"
			else
				dorothy_try__context_lines "EXIT: $DOROTHY_TRY__TRAP_STATUS" "LOCATION: $DOROTHY_TRY__TRAP_LOCATION" || :
				exit "$DOROTHY_TRY__TRAP_STATUS"
			fi
		fi
	}
	dorothy_try__trap_inner="$(__get_function_inner dorothy_try__trap_outer)"
	function dorothy_try__wrapper {
		local continued_status
		# trunk-ignore(shellcheck/SC2064)
		trap "$dorothy_try__trap_inner" ERR

		# workaround
		if [[ $BASH_VERSION_MAJOR -lt 4 ]] && __is_errexit && __is_subshell_function__internal "${DOROTHY_TRY__COMMAND[0]}"; then
			# this workaround is necessary to prevent macos bash v3.2 from crashing on `try __solo[subshell]`
			# compiled bash v3.2 does not have this issue, and is not harmed by this logic path
			set +e
			(
				set -e
				"${DOROTHY_TRY__COMMAND[@]}"
			)
			continued_status=$?
			dorothy_try__context_lines "WORKAROUND: $continued_status" || :
			set -e
		else
			"${DOROTHY_TRY__COMMAND[@]}"
			# if errexit is enabled, we depend on the trap, if it is disabled, this will also be the status in addition to the trap
			continued_status=$?
			dorothy_try__context_lines "CONTINUED: $continued_status" || :
		fi

		# capture status in case of set +e
		if [[ $continued_status -ne 0 ]]; then
			DOROTHY_TRY__STATUS="$continued_status"
		fi

		# we've stored the status, we return success
		return 0
	}
	function __try {
		# Process the arguments
		local item cmd=() exit_status_variable_name=''
		while [[ $# -ne 0 ]]; do
			item="$1"
			shift
			case "$item" in
			'--')
				cmd+=("$@")
				shift $#
				break
				;;
			{*}) __dereference --source={item} --name={exit_status_variable_name} || return $? ;;
			*)
				__print_lines "ERROR: __try: An unrecognised flag was provided: $item" >&2 || :
				return 22 # EINVAL 22 Invalid argument
				;;
			esac
		done

		# prepare globals
		DOROTHY_TRY__COUNT="${DOROTHY_TRY__COUNT:-0}" # so we can remove our trap once all tries are finished

		# prepare locals specific to our context
		local DOROTHY_TRY__STATUS=
		local DOROTHY_TRY__CONTEXT="$RANDOM$RANDOM"
		local DOROTHY_TRY__COMMAND=("${cmd[@]}")
		local DOROTHY_TRY__SUBSHELL="${BASH_SUBSHELL-}"
		local DOROTHY_TRY__DIR="$TMPDIR/dorothy/try"
		local DOROTHY_TRY__FILE_STATUS="$DOROTHY_TRY__DIR/$DOROTHY_TRY__CONTEXT.status"

		# execute the command within our wrapper, such that we can handle edge cases, and identify it inside our trap
		DOROTHY_TRY__COUNT="$((DOROTHY_TRY__COUNT + 1))" # increment the count
		dorothy_try__wrapper
		DOROTHY_TRY__COUNT="$((DOROTHY_TRY__COUNT - 1))"
		if [[ $DOROTHY_TRY__COUNT -eq 0 ]]; then
			# if all our tries have now finished, remove the lingering trap
			trap - ERR
		fi

		# load the exit status if necessary
		if [[ -f $DOROTHY_TRY__FILE_STATUS ]]; then
			local loaded_status
			loaded_status="$(<"$DOROTHY_TRY__FILE_STATUS")"
			if [[ $loaded_status -ne $DOROTHY_TRY__STATUS ]]; then
				dorothy_try__context_lines "LOADED: $loaded_status    PRIOR: $DOROTHY_TRY__STATUS    NEEDED" || :
			else
				dorothy_try__context_lines "LOADED: $loaded_status    PRIOR: $DOROTHY_TRY__STATUS    SAME" || :
			fi
			DOROTHY_TRY__STATUS="$loaded_status"
			rm -f -- "$DOROTHY_TRY__FILE_STATUS" || :
		fi

		# apply the exit status
		dorothy_try__context_lines "RESULT: ${DOROTHY_TRY__STATUS:-0}" || :
		if [[ -n $exit_status_variable_name ]]; then
			eval "$exit_status_variable_name=${DOROTHY_TRY__STATUS:-0}"
		fi

		# return success
		return 0
	}
	;;

# this is i5a with the throw-in-subshell workaround
v5b | 5b)
	function dorothy_try__trap_outer {
		# do not use local, as this is not executed as a function
		DOROTHY_TRY__TRAP_STATUS=$?
		DOROTHY_TRY__TRAP_LOCATION="${BASH_SOURCE[0]}:${LINENO}:${FUNCNAME-}:$-:$BASH_VERSION"
		if [[ $DOROTHY_TRY__TRAP_STATUS -eq 1 && -f $DOROTHY_TRY__FILE_STATUS ]]; then
			# Bash versions 4.2 and 4.3 will change a caught but thrown or continued exit status to 1
			DOROTHY_TRY__TRAP_STATUS="$(<"$DOROTHY_TRY__FILE_STATUS")"
			dorothy_try__context_lines "REPLACED: $DOROTHY_TRY__TRAP_STATUS" "LOCATION: $DOROTHY_TRY__TRAP_LOCATION" || :
		fi

		# if we are applicable, necessary for `do recursed [subshell]` when not using --no-status
		if [[ -z ${DOROTHY_TRY__CONTEXT-} ]]; then
			dorothy_try__dump_lines 'NO CONTEXT' || :
		elif __is_not_errexit; then
			# not applicable, as we are not in errexit, so want to continue as usual
			dorothy_try__dump_lines "NO ERREXIT $-" || :
		else
			# we are in errexit, we caught a thrown exception, a crash will occur and EXIT will fire, unless we return anything
			# returning a non-zero exit status in bash v4.4 and up causes the non-zero exit status to be returned to the caller
			# returning a non-zero exit status in bash versions earlier that v4.4 will cause 0 to be returned to the caller
			# I have been unable to find a way for a non-zero exit status to propagate to the caller in bash versions earlier than v4.4
			# using [__return ...] instead of [return ...] just causes the crash to occur

			# check subshell
			if [[ $DOROTHY_TRY__SUBSHELL == "${BASH_SUBSHELL-}" ]]; then
				# we are in the same subshell, so our changes to DOROTHY_TRY__STATUS will persist
				dorothy_try__context_lines "SHARE: $DOROTHY_TRY__TRAP_STATUS" "LOCATION: $DOROTHY_TRY__TRAP_LOCATION" || :
				DOROTHY_TRY__STATUS="$DOROTHY_TRY__TRAP_STATUS"
			else
				# lacking this causes nearly all subshell executions to fail on 3.2, 4.0, 4.2
				dorothy_try__context_lines "SAVE: $DOROTHY_TRY__TRAP_STATUS" "LOCATION: $DOROTHY_TRY__TRAP_LOCATION" || :
				{ __mkdirp "$DOROTHY_TRY__DIR" && __print_lines "$DOROTHY_TRY__TRAP_STATUS" >"$DOROTHY_TRY__FILE_STATUS"; } || :
			fi

			# return the status accordingly
			if [[ ${FUNCNAME-} == 'dorothy_try__wrapper' ]]; then
				dorothy_try__context_lines "SKIP: $DOROTHY_TRY__TRAP_STATUS" || :
				return 0
			elif [[ -n ${FUNCNAME-} ]]; then
				if [[ $DOROTHY_TRY__SUBSHELL == "${BASH_SUBSHELL-}" ]]; then
					dorothy_try__context_lines "RETURN: $DOROTHY_TRY__TRAP_STATUS" "LOCATION: $DOROTHY_TRY__TRAP_LOCATION" || :
					return "$DOROTHY_TRY__TRAP_STATUS"
				else
					dorothy_try__context_lines "THROW: $DOROTHY_TRY__TRAP_STATUS" "LOCATION: $DOROTHY_TRY__TRAP_LOCATION" || :
					__wait_for_semaphores "$DOROTHY_TRY__FILE_STATUS"
					# __return "$DOROTHY_TRY__TRAP_STATUS"
				fi
			else
				dorothy_try__context_lines "EXIT: $DOROTHY_TRY__TRAP_STATUS" "LOCATION: $DOROTHY_TRY__TRAP_LOCATION" || :
				# exit "$DOROTHY_TRY__TRAP_STATUS"
				# ^ by not returning or exiting, we allow the caller to exit itself
			fi
		fi
	}
	dorothy_try__trap_inner="$(__get_function_inner dorothy_try__trap_outer)"
	function dorothy_try__wrapper {
		local continued_status
		# trunk-ignore(shellcheck/SC2064)
		trap "$dorothy_try__trap_inner" ERR

		# workaround
		if [[ $BASH_VERSION_MAJOR -lt 4 ]] && __is_errexit && __is_subshell_function__internal "${DOROTHY_TRY__COMMAND[0]}"; then
			# this workaround is necessary to prevent macos bash v3.2 from crashing on `try __solo[subshell]`
			# compiled bash v3.2 does not have this issue, and is not harmed by this logic path
			set +e
			(
				set -e
				"${DOROTHY_TRY__COMMAND[@]}"
			)
			continued_status=$?
			dorothy_try__context_lines "WORKAROUND: $continued_status" || :
			set -e
		else
			"${DOROTHY_TRY__COMMAND[@]}"
			# if errexit is enabled, we depend on the trap, if it is disabled, this will also be the status in addition to the trap
			continued_status=$?
			dorothy_try__context_lines "CONTINUED: $continued_status" || :
		fi

		# capture status in case of set +e
		if [[ $continued_status -ne 0 ]]; then
			DOROTHY_TRY__STATUS="$continued_status"
		fi

		# we've stored the status, we return success
		return 0
	}
	function __try {
		# Process the arguments
		local item cmd=() exit_status_variable_name=''
		while [[ $# -ne 0 ]]; do
			item="$1"
			shift
			case "$item" in
			'--')
				cmd+=("$@")
				shift $#
				break
				;;
			{*}) __dereference --source={item} --name={exit_status_variable_name} || return $? ;;
			*)
				__print_lines "ERROR: __try: An unrecognised flag was provided: $item" >&2 || :
				return 22 # EINVAL 22 Invalid argument
				;;
			esac
		done

		# prepare globals
		DOROTHY_TRY__COUNT="${DOROTHY_TRY__COUNT:-0}" # so we can remove our trap once all tries are finished

		# prepare locals specific to our context
		local DOROTHY_TRY__STATUS=
		local DOROTHY_TRY__CONTEXT="$RANDOM$RANDOM"
		local DOROTHY_TRY__COMMAND=("${cmd[@]}")
		local DOROTHY_TRY__SUBSHELL="${BASH_SUBSHELL-}"
		local DOROTHY_TRY__DIR="$TMPDIR/dorothy/try"
		local DOROTHY_TRY__FILE_STATUS="$DOROTHY_TRY__DIR/$DOROTHY_TRY__CONTEXT.status"

		# execute the command within our wrapper, such that we can handle edge cases, and identify it inside our trap
		DOROTHY_TRY__COUNT="$((DOROTHY_TRY__COUNT + 1))" # increment the count
		dorothy_try__wrapper
		DOROTHY_TRY__COUNT="$((DOROTHY_TRY__COUNT - 1))"
		if [[ $DOROTHY_TRY__COUNT -eq 0 ]]; then
			# if all our tries have now finished, remove the lingering trap
			trap - ERR
		fi

		# load the exit status if necessary
		if [[ -f $DOROTHY_TRY__FILE_STATUS ]]; then
			local loaded_status
			loaded_status="$(<"$DOROTHY_TRY__FILE_STATUS")"
			if [[ $loaded_status -ne $DOROTHY_TRY__STATUS ]]; then
				dorothy_try__context_lines "LOADED: $loaded_status    PRIOR: $DOROTHY_TRY__STATUS    NEEDED" || :
			else
				dorothy_try__context_lines "LOADED: $loaded_status    PRIOR: $DOROTHY_TRY__STATUS    SAME" || :
			fi
			DOROTHY_TRY__STATUS="$loaded_status"
			rm -f -- "$DOROTHY_TRY__FILE_STATUS" || :
		fi

		# apply the exit status
		dorothy_try__context_lines "RESULT: ${DOROTHY_TRY__STATUS:-0}" || :
		if [[ -n $exit_status_variable_name ]]; then
			eval "$exit_status_variable_name=${DOROTHY_TRY__STATUS:-0}"
		fi

		# return success
		return 0
	}
	;;

# this is i5b but where we always try to use the throw-in-subshell workaround for affected bash versions
# however, while this does solve exit statuses, it now inhibits side effects
5c | i5c | v5c)
	function dorothy_try__trap_outer {
		# do not use local, as this is not executed as a function
		DOROTHY_TRY__TRAP_STATUS=$?
		DOROTHY_TRY__TRAP_LOCATION="${BASH_SOURCE[0]}:${LINENO}:${FUNCNAME-}:$DOROTHY_TRY__SUBSHELL:${BASH_SUBSHELL-}:$-:$BASH_VERSION"
		if [[ $DOROTHY_TRY__TRAP_STATUS -eq 1 && -f $DOROTHY_TRY__FILE_STATUS ]]; then
			# Bash versions 4.2 and 4.3 will change a caught but thrown or continued exit status to 1
			# So we have to restore our saved one from the throw-in-trap-subshell workaround
			DOROTHY_TRY__TRAP_STATUS="$(<"$DOROTHY_TRY__FILE_STATUS")"
			dorothy_try__context_lines "REPLACED: $DOROTHY_TRY__TRAP_STATUS" "LOCATION: $DOROTHY_TRY__TRAP_LOCATION" || :
		fi

		# if we are applicable, necessary for `do recursed [subshell]` when not using --no-status
		if [[ -z ${DOROTHY_TRY__CONTEXT-} ]]; then
			dorothy_try__dump_lines 'NO CONTEXT' || :
		elif __is_not_errexit; then
			# not applicable, as we are not in errexit, so want to continue as usual
			dorothy_try__dump_lines "NO ERREXIT $-" || :
		else
			# we are in errexit, we caught a thrown exception, a crash will occur and EXIT will fire, unless we return anything
			# returning a non-zero exit status in bash v4.4 and up causes the non-zero exit status to be returned to the caller
			# returning a non-zero exit status in bash versions earlier that v4.4 will cause 0 to be returned to the caller
			# I have been unable to find a way for a non-zero exit status to propagate to the caller in bash versions earlier than v4.4
			# using [__return ...] instead of [return ...] just causes the crash to occur

			# check subshell
			# in theory, a subshell check only matters if the current subshell is deeper than the original subshell
			# if our subshell is higher, then it doesn't matter... in theory, however if we are in a higher subshell, it means something has gone terribly wrong, as it means our trap is firing in contexts it should not be
			if [[ $DOROTHY_TRY__SUBSHELL == "${BASH_SUBSHELL-}" ]]; then
				# we are in the same subshell, so our changes to DOROTHY_TRY__STATUS will persist
				dorothy_try__context_lines "SHARE: $DOROTHY_TRY__TRAP_STATUS" "LOCATION: $DOROTHY_TRY__TRAP_LOCATION" || :
				DOROTHY_TRY__STATUS="$DOROTHY_TRY__TRAP_STATUS"
			else
				# lacking this causes nearly all subshell executions to fail on 3.2, 4.0, 4.2
				dorothy_try__context_lines "SAVE: $DOROTHY_TRY__TRAP_STATUS" "LOCATION: $DOROTHY_TRY__TRAP_LOCATION" || :
				{ __mkdirp "$DOROTHY_TRY__DIR" && __print_lines "$DOROTHY_TRY__TRAP_STATUS" >"$DOROTHY_TRY__FILE_STATUS"; } || :
			fi

			# return the status accordingly
			if [[ ${FUNCNAME-} == 'dorothy_try__wrapper' ]]; then
				dorothy_try__context_lines "SKIP: $DOROTHY_TRY__TRAP_STATUS" "LOCATION: $DOROTHY_TRY__TRAP_LOCATION" || :
				return 0
			elif [[ -n ${FUNCNAME-} ]]; then
				# Only return the status on if we are the same subshell, or we are on bash v4.4 and up
				# Earlier versions of bash will turn a `return <non-zero>` into a `return 0`: https://stackoverflow.com/q/79495360/130638
				# As such for earlier versions of bash, we have to either:
				# - use `__return <non-zero>` to throw
				# - or not do any action, allowing the default action to propagate
				# In bash v4.2 and v4.3 both of these two options will change the behaviour to `return 1`, as such we have to ensure our status file is written before we continue
				if [[ $DOROTHY_TRY__SUBSHELL == "${BASH_SUBSHELL-}" || ($BASH_VERSION_MAJOR -gt 4 || ($BASH_VERSION_MAJOR -eq 4 && $BASH_VERSION_MINOR -ge 4)) ]]; then
					dorothy_try__context_lines "RETURN: $DOROTHY_TRY__TRAP_STATUS" "LOCATION: $DOROTHY_TRY__TRAP_LOCATION" || :
					return "$DOROTHY_TRY__TRAP_STATUS"
				else
					dorothy_try__context_lines "THROW: $DOROTHY_TRY__TRAP_STATUS" "LOCATION: $DOROTHY_TRY__TRAP_LOCATION" || :
					if [[ $BASH_VERSION_MAJOR -eq 4 && ($BASH_VERSION_MINOR -eq 2 || $BASH_VERSION_MINOR -eq 3) ]]; then
						__wait_for_semaphores "$DOROTHY_TRY__FILE_STATUS"
					fi
				fi
			else
				dorothy_try__context_lines "EXIT: $DOROTHY_TRY__TRAP_STATUS" "LOCATION: $DOROTHY_TRY__TRAP_LOCATION" || :
				# exit "$DOROTHY_TRY__TRAP_STATUS"
				# ^ by not returning or exiting, we allow the caller to exit itself
			fi
		fi
	}
	dorothy_try__trap_inner="$(__get_function_inner dorothy_try__trap_outer)"
	function dorothy_try__wrapper {
		local continued_status
		# trunk-ignore(shellcheck/SC2064)
		trap "$dorothy_try__trap_inner" ERR

		# handle accordingly to bash version
		if [[ $BASH_VERSION_MAJOR -gt 4 || ($BASH_VERSION_MAJOR -eq 4 && $BASH_VERSION_MINOR -ge 4) ]]; then
			# bash version 4.4 and up
			dorothy_try__context_lines "DIRECT" || :
			"${DOROTHY_TRY__COMMAND[@]}"
			# if errexit is enabled, we depend on the trap, and would not have reached here, which is fine
			# if errexit is disabled, the trap may or may not have fired, depending on the bash version, in which we need the status via the technique below
			continued_status=$?
		else
			# bash version 4.3 and below
			# here we are now experimenting with always enforcing a subshell, such that the throw-in-trap workaround for bash 4.3 and below can be used
			if ! __is_subshell_function__internal "${DOROTHY_TRY__COMMAND[0]}"; then
				__print_lines 'WARNING: __try: subshell was not detected, side effects will be disabled as we are enforcing a subshell' >&2
			fi
			if __is_errexit; then
				# this workaround is necessary to prevent macos bash v3.2 from crashing on `try __solo[subshell]`
				# compiled bash v3.2 does not have this issue, and is not harmed by this logic path
				set +e
				(
					set -e
					"${DOROTHY_TRY__COMMAND[@]}"
				)
				continued_status=$?
				set -e
				dorothy_try__context_lines "ERREXIT SUBSHELL: $continued_status" || :
			else
				(
					"${DOROTHY_TRY__COMMAND[@]}"
				)
				continued_status=$?
				dorothy_try__context_lines "NO-ERREXIT SUBSHELL: $continued_status" || :
			fi
		fi

		# capture status in case of set +e
		dorothy_try__context_lines "WRAPPER: $continued_status" || :
		if [[ $continued_status -ne 0 ]]; then
			DOROTHY_TRY__STATUS="$continued_status"
		fi

		# we've stored the status, we return success
		return 0
	}
	function __try {
		# Process the arguments
		local item cmd=() exit_status_variable_name=''
		while [[ $# -ne 0 ]]; do
			item="$1"
			shift
			case "$item" in
			'--')
				cmd+=("$@")
				shift $#
				break
				;;
			{*}) __dereference --source={item} --name={exit_status_variable_name} || return $? ;;
			*)
				__print_lines "ERROR: __try: An unrecognised flag was provided: $item" >&2 || :
				return 22 # EINVAL 22 Invalid argument
				;;
			esac
		done

		# prepare globals
		DOROTHY_TRY__COUNT="${DOROTHY_TRY__COUNT:-0}" # so we can remove our trap once all tries are finished

		# prepare locals specific to our context
		local DOROTHY_TRY__STATUS=
		local DOROTHY_TRY__CONTEXT="$RANDOM$RANDOM"
		local DOROTHY_TRY__COMMAND=("${cmd[@]}")
		local DOROTHY_TRY__SUBSHELL="${BASH_SUBSHELL-}"
		local DOROTHY_TRY__DIR="$TMPDIR/dorothy/try"
		local DOROTHY_TRY__FILE_STATUS="$DOROTHY_TRY__DIR/$DOROTHY_TRY__CONTEXT.status"

		# execute the command within our wrapper, such that we can handle edge cases, and identify it inside our trap
		DOROTHY_TRY__COUNT="$((DOROTHY_TRY__COUNT + 1))" # increment the count
		dorothy_try__wrapper
		DOROTHY_TRY__COUNT="$((DOROTHY_TRY__COUNT - 1))"
		if [[ $DOROTHY_TRY__COUNT -eq 0 ]]; then
			# if all our tries have now finished, remove the lingering trap
			trap - ERR
		fi

		# load the exit status if necessary
		if [[ -f $DOROTHY_TRY__FILE_STATUS ]]; then
			local loaded_status
			loaded_status="$(<"$DOROTHY_TRY__FILE_STATUS")"
			if [[ $loaded_status -ne $DOROTHY_TRY__STATUS ]]; then
				dorothy_try__context_lines "LOADED: $loaded_status    PRIOR: $DOROTHY_TRY__STATUS    NEEDED" || :
			else
				dorothy_try__context_lines "LOADED: $loaded_status    PRIOR: $DOROTHY_TRY__STATUS    SAME" || :
			fi
			DOROTHY_TRY__STATUS="$loaded_status"
			rm -f -- "$DOROTHY_TRY__FILE_STATUS" || :
		fi

		# apply the exit status
		dorothy_try__context_lines "RESULT: ${DOROTHY_TRY__STATUS:-0}" || :
		if [[ -n $exit_status_variable_name ]]; then
			eval "$exit_status_variable_name=${DOROTHY_TRY__STATUS:-0}"
		fi

		# return success
		return 0
	}
	;;

# this combines all of the above into a new version, which is now the latest core
# it now adapts specifically for all the v4.3 and earlier versions, and will crash where consistency cannot be guaranteed
# There are still more optimisations that can be made:
# 1. Determine when exactly saving exit status is actually needed
# 2. Is waiting for the exit status file actually needed, or is it always waited for inherently?
# 3. Detect within the __try function when loading the exit status, if there is a conflict, in which a crash should occur
# 4. Output a human message when such a crash occurs, so the user knows what to do
6 | i6 | v6 | 6a | i6a | v6a)
	function dorothy_try__trap_outer {
		# do not use local, as this is not executed as a function
		DOROTHY_TRY__TRAP_STATUS=$?
		DOROTHY_TRY__TRAP_LOCATION="${BASH_SOURCE[0]}:${LINENO}:${FUNCNAME-}:$DOROTHY_TRY__SUBSHELL:${BASH_SUBSHELL-}:$-:$BASH_VERSION"
		if [[ $DOROTHY_TRY__TRAP_STATUS -eq 1 && -f $DOROTHY_TRY__FILE_STATUS ]]; then
			# Bash versions 4.2 and 4.3 will change a caught but thrown or continued exit status to 1
			# So we have to restore our saved one from the throw-in-trap-subshell workaround
			DOROTHY_TRY__TRAP_STATUS="$(<"$DOROTHY_TRY__FILE_STATUS")"
			dorothy_try__context_lines "REPLACED: $DOROTHY_TRY__TRAP_STATUS" "LOCATION: $DOROTHY_TRY__TRAP_LOCATION" || :
		fi

		# if we are applicable, necessary for `do recursed [subshell]` when not using --no-status
		if [[ -z ${DOROTHY_TRY__CONTEXT-} ]]; then
			dorothy_try__dump_lines 'NO CONTEXT' || :
		elif __is_not_errexit; then
			# not applicable, as we are not in errexit, so want to continue as usual
			dorothy_try__dump_lines "NO ERREXIT $-" || :
		else
			# we are in errexit, we caught a thrown exception, a crash will occur and EXIT will fire, unless we return anything
			# returning a non-zero exit status in bash v4.4 and up causes the non-zero exit status to be returned to the caller
			# returning a non-zero exit status in bash versions earlier that v4.4 will cause 0 to be returned to the caller
			# I have been unable to find a way for a non-zero exit status to propagate to the caller in bash versions earlier than v4.4
			# using [__return ...] instead of [return ...] just causes the crash to occur

			# check subshell
			# in theory, a subshell check only matters if the current subshell is deeper than the original subshell
			# if our subshell is higher, then it doesn't matter... in theory, however if we are in a higher subshell, it means something has gone terribly wrong, as it means our trap is firing in contexts it should not be
			if [[ $DOROTHY_TRY__SUBSHELL == "${BASH_SUBSHELL-}" ]]; then
				# we are in the same subshell, so our changes to DOROTHY_TRY__STATUS will persist
				dorothy_try__context_lines "SHARE: $DOROTHY_TRY__TRAP_STATUS" "LOCATION: $DOROTHY_TRY__TRAP_LOCATION" || :
				DOROTHY_TRY__STATUS="$DOROTHY_TRY__TRAP_STATUS"
			else
				# lacking this causes nearly all subshell executions to fail on 3.2, 4.0, 4.2
				dorothy_try__context_lines "SAVE: $DOROTHY_TRY__TRAP_STATUS" "LOCATION: $DOROTHY_TRY__TRAP_LOCATION" || :
				{ __mkdirp "$DOROTHY_TRY__DIR" && __print_lines "$DOROTHY_TRY__TRAP_STATUS" >"$DOROTHY_TRY__FILE_STATUS"; } || :
				# wait for semaphores if needed
				if [[ $BASH_VERSION_MAJOR -eq 4 && ($BASH_VERSION_MINOR -eq 2 || $BASH_VERSION_MINOR -eq 3) ]]; then
					__wait_for_semaphores "$DOROTHY_TRY__FILE_STATUS"
				fi
			fi

			# return the status accordingly
			if [[ ${FUNCNAME-} == 'dorothy_try__wrapper' ]]; then
				dorothy_try__context_lines "SKIP: $DOROTHY_TRY__TRAP_STATUS" "LOCATION: $DOROTHY_TRY__TRAP_LOCATION" || :
				return 0
			elif [[ -n ${FUNCNAME-} ]]; then
				# Only return the status on if we are the same subshell, or we are on bash v4.4 and up
				# Earlier versions of bash will turn a `return <non-zero>` into a `return 0`: https://stackoverflow.com/q/79495360/130638
				# As such for earlier versions of bash, we have to either:
				# - use `__return <non-zero>` to throw
				# - or not do any action, allowing the default action to propagate
				# In bash v4.2 and v4.3 both of these two options will change the behaviour to `return 1`, as such we have to ensure our status file is written before we continue
				if [[ $BASH_VERSION_MAJOR -gt 4 || ($BASH_VERSION_MAJOR -eq 4 && $BASH_VERSION_MINOR -ge 4) ]]; then
					dorothy_try__context_lines "RETURN NEW BASH: $DOROTHY_TRY__TRAP_STATUS" "LOCATION: $DOROTHY_TRY__TRAP_LOCATION" "FUNCNAME: ${FUNCNAME[*]}" || :
					return "$DOROTHY_TRY__TRAP_STATUS"
				elif [[ "$(__get_index_of_parent_function 'dorothy_try__wrapper' || :)" -eq 1 ]]; then
					# this is useful regardless of subshell same or same shell, as it will still return us to the wrapper which is what we want
					dorothy_try__context_lines "RETURN SKIPS TO TRY: $DOROTHY_TRY__TRAP_STATUS" "LOCATION: $DOROTHY_TRY__TRAP_LOCATION" "FUNCNAME: ${FUNCNAME[*]}" || :
					return "$DOROTHY_TRY__TRAP_STATUS" # bash v3.2, 4.0 will turn this into [return 0]; bash v4.2, 4.3 will turn this into [return 1]
				elif [[ $DOROTHY_TRY__SUBSHELL != "${BASH_SUBSHELL-}" ]]; then
					# throw to any effective subshell
					dorothy_try__context_lines "THROW TO SUBSHELL OLD BASH: $DOROTHY_TRY__TRAP_STATUS" "LOCATION: $DOROTHY_TRY__TRAP_LOCATION" "FUNCNAME: ${FUNCNAME[*]}" || :
					# Bash 3.2, 4.0 will crash
					# Bash 4.2, 4.3 will be ok
				elif [[ "$(__get_index_of_parent_function 'dorothy_try__wrapper' '__do' '__try' || :)" -eq 1 ]]; then
					dorothy_try__context_lines "RETURN TO PARENT SUBSHELL OLD BASH: $DOROTHY_TRY__TRAP_STATUS" "LOCATION: $DOROTHY_TRY__TRAP_LOCATION" "FUNCNAME: ${FUNCNAME[*]}" || :
					return "$DOROTHY_TRY__TRAP_STATUS" # for some reason this changes to [return 0] even on 4.2 and 4.3, however this is going to one of our functions, which will load the STORE or SAVED value
					# on bash 3.2 and 4.0 this still results in a crash on: do recursed[subshell] --no-status
					# however that is mitigated by the [RETURN SKIPS TO TRY] functionality earlier, except on macos bash 3.2 which behaves differently and still crashes
					# however on 4.2 and 4.3 it lets it pass
					# note that the crashes are still the correct exit status and are not continuing
				else
					if [[ $BASH_VERSION_MAJOR -eq 4 && ($BASH_VERSION_MINOR -eq 2 || $BASH_VERSION_MINOR -eq 3) ]]; then
						dorothy_try__context_lines "THROW TO UN-CATCHABLE OLD BASH: $DOROTHY_TRY__TRAP_STATUS" "LOCATION: $DOROTHY_TRY__TRAP_LOCATION" "FUNCNAME: ${FUNCNAME[*]}" || :
						# return "$DOROTHY_TRY__TRAP_STATUS" # for some reason this gets converted into `return 0` here, despite typical behaviour of bash 4.2 and 4.3 converting this to a `return 1` instead
					else
						dorothy_try__context_lines "CRASH TO UN-CATCHABLE OLD BASH: $DOROTHY_TRY__TRAP_STATUS" "LOCATION: $DOROTHY_TRY__TRAP_LOCATION" "FUNCNAME: ${FUNCNAME[*]}" || :
					fi
				fi
			else
				dorothy_try__context_lines "EXIT: $DOROTHY_TRY__TRAP_STATUS" "LOCATION: $DOROTHY_TRY__TRAP_LOCATION" || :
				# exit "$DOROTHY_TRY__TRAP_STATUS"
				# ^ by not returning or exiting, we allow the caller to exit itself
			fi
		fi
	}
	dorothy_try__trap_inner="$(__get_function_inner dorothy_try__trap_outer)"
	function dorothy_try__wrapper {
		local continued_status
		# trunk-ignore(shellcheck/SC2064)
		trap "$dorothy_try__trap_inner" ERR

		# handle accordingly to bash version
		if [[ $BASH_VERSION_MAJOR -gt 4 || ($BASH_VERSION_MAJOR -eq 4 && $BASH_VERSION_MINOR -ge 4) ]]; then
			# bash version 4.4 and up
			dorothy_try__context_lines "DIRECT: ${DOROTHY_TRY__COMMAND[0]}" || :
			"${DOROTHY_TRY__COMMAND[@]}"
			# if errexit is enabled, we depend on the trap, and would not have reached here, which is fine
			# if errexit is disabled, the trap may or may not have fired, depending on the bash version, in which we need the status via the technique below
			continued_status=$?
		elif __is_subshell_function__internal "${DOROTHY_TRY__COMMAND[0]}"; then
			if __is_errexit; then
				# this workaround is necessary to prevent macos bash v3.2 from crashing on `try __solo[subshell]`
				# compiled bash v3.2 does not have this issue, and is not harmed by this logic path
				# this has no effect on the macos bash v3.2 crash of: do recursed[subshell] --no-status
				dorothy_try__context_lines "ERREXIT SUBSHELL WORKAROUND: ${DOROTHY_TRY__COMMAND[0]}" || :
				set +e
				(
					set -e
					"${DOROTHY_TRY__COMMAND[@]}"
				)
				continued_status=$?
				set -e
			else
				dorothy_try__context_lines "SUBSHELL: ${DOROTHY_TRY__COMMAND[0]}" || :
				"${DOROTHY_TRY__COMMAND[@]}"
				continued_status=$?
			fi
		else
			# yolo it, and detect failure within the trap
			dorothy_try__context_lines "YOLO: ${DOROTHY_TRY__COMMAND[0]}" || :
			"${DOROTHY_TRY__COMMAND[@]}"
			continued_status=$?
		fi

		# capture status in case of set +e
		dorothy_try__context_lines "CONTINUED: ${DOROTHY_TRY__COMMAND[0]}: $continued_status" || :
		if [[ $continued_status -ne 0 ]]; then
			DOROTHY_TRY__STATUS="$continued_status"
		fi

		# we've stored the status, we return success
		return 0
	}
	function __try {
		# Process the arguments
		local item cmd=() exit_status_variable_name=''
		while [[ $# -ne 0 ]]; do
			item="$1"
			shift
			case "$item" in
			'--')
				cmd+=("$@")
				shift $#
				break
				;;
			{*}) __dereference --source={item} --name={exit_status_variable_name} || return $? ;;
			*)
				__print_lines "ERROR: __try: An unrecognised flag was provided: $item" >&2 || :
				return 22 # EINVAL 22 Invalid argument
				;;
			esac
		done

		# prepare globals
		DOROTHY_TRY__COUNT="${DOROTHY_TRY__COUNT:-0}" # so we can remove our trap once all tries are finished

		# prepare locals specific to our context
		local DOROTHY_TRY__STATUS=
		local DOROTHY_TRY__CONTEXT="$RANDOM$RANDOM"
		local DOROTHY_TRY__COMMAND=("${cmd[@]}")
		local DOROTHY_TRY__SUBSHELL="${BASH_SUBSHELL-}"
		local DOROTHY_TRY__DIR="$TMPDIR/dorothy/try"
		local DOROTHY_TRY__FILE_STATUS="$DOROTHY_TRY__DIR/$DOROTHY_TRY__CONTEXT.status"

		# execute the command within our wrapper, such that we can handle edge cases, and identify it inside our trap
		DOROTHY_TRY__COUNT="$((DOROTHY_TRY__COUNT + 1))" # increment the count
		dorothy_try__wrapper
		DOROTHY_TRY__COUNT="$((DOROTHY_TRY__COUNT - 1))"
		if [[ $DOROTHY_TRY__COUNT -eq 0 ]]; then
			# if all our tries have now finished, remove the lingering trap
			trap - ERR
		fi

		# load the exit status if necessary
		if [[ -f $DOROTHY_TRY__FILE_STATUS ]]; then
			local loaded_status
			loaded_status="$(<"$DOROTHY_TRY__FILE_STATUS")"
			if [[ $loaded_status -ne $DOROTHY_TRY__STATUS ]]; then
				dorothy_try__context_lines "LOADED: $loaded_status    PRIOR: $DOROTHY_TRY__STATUS    NEEDED" || :
			else
				dorothy_try__context_lines "LOADED: $loaded_status    PRIOR: $DOROTHY_TRY__STATUS    SAME" || :
			fi
			DOROTHY_TRY__STATUS="$loaded_status"
			rm -f -- "$DOROTHY_TRY__FILE_STATUS" || :
		fi

		# apply the exit status
		dorothy_try__context_lines "RESULT: ${DOROTHY_TRY__STATUS:-0}" || :
		if [[ -n $exit_status_variable_name ]]; then
			eval "$exit_status_variable_name=${DOROTHY_TRY__STATUS:-0}"
		fi

		# return success
		return 0
	}
	;;

# never committed to master, was only in dev, no need to implement
# 331cca2: Feb 12, 2025: eval_capture: solve failing tests on linux
# https://github.com/bevry/dorothy/commit/331cca22b7ec24cb4721f8bc2b05178b83308e54
# Only change was to the __do side of things, where `>>` is used instead of `>`, for linux compat

*) help "$0: An unrecognised try implementation was provided: $option_implementation" ;;
esac
