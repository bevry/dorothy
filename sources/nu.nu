#!/usr/bin/env nu

# Enables better UX around mode options, e.g. instead of just `--format=(table|json|seconds)` you can do `--table` or `--json` or `--seconds`.
# ``` nu
# def main [	
# 	--format: string = "" # Output format: table (default), json, or seconds
# 	--seconds(-s) # Alias for --format=seconds
# 	--json(-j) # Alias for --format=json
# 	--table(-t) # Alias for --format=table
# ] {
# 	let format = get_mode_from_options --name=format --default=table {table: $table, json: $json, seconds: $seconds, format: $format}
# ```
export def get_mode_from_options [
	--name: string
	--default: string = ''
	options: record # <string, string|bool>
] {
	# verify name
	if $name == '' {
		error make { msg: "Invalid argument: `--name` is required.", code: "EINVAL", status: 22 }
	}

	# verify options
	let keys = $options | items {|key, value| $key }
	if ($keys | length) == 0 {
		print --stderr ($options)
		print --stderr ($options | describe)
		print --stderr ($options | enumerate | length)
		error make { msg: "Invalid argument: `--options` is required and must be a record of `<string, string|bool>`.", code: "EINVAL", status: 22 }
	}

	# prepare modes
	let modes = $keys | where $it != $name # exclude name from keys to get modes
	mut count: int = 0
	mut mode: string = ''

	# validate the default mode
	if $default != '' and $default not-in $modes {
		error make { msg: $"Invalid argument: Unrecognised `--default=($default)`. The value must be any of `($modes)`", code: "EINVAL", status: 22 }
	}

	# count and validate
	mut specified = {}
	for key in $keys {
		let value = $options | get $key
		if ($value | describe) == "bool" {
			if $value == true {
				$count = $count + 1
				$mode = $key
				$specified = $specified | insert $key $value
			}
		} else if ($value | describe) == "string" {
			if not ($value | is-empty) {
				# verify it is a valid option
				if $value not-in $modes {
					error make { msg: $"Invalid argument: Unrecognised `--($name)=($value)`. The value must be any of `($modes)` which `($value)` is not.", code: "EINVAL", status: 22 }
				}
				$count = $count + 1
				$mode = $value
				$specified = $specified | insert $key $value
			}
		} else {
			error make { msg: $"Invalid argument: Unrecognised `--($key)=($value)`. The value must must be a boolean or string.", code: "EINVAL", status: 22 }
		}
	}

	# verify only one was provided
	if $count > 1 {
		error make { msg: $"Invalid argument: Only 1 ($name) can be specified at a time, you specified ($count) `($specified)`", code: "EINVAL", status: 22 }
	}

	# apply the default
	if $mode == '' and $default != '' {
		$mode = $default
	}

	# return the result
	$mode
}


# Unfortunately, nushell doesn't allow bool/string argument overloading, so you can have `--quiet` and `--quiet=true` but not those with `--quiet=yes`
# As such, this function is of limited value, and should be considered a temporary experimentation.
# ```
# def main [ --quiet(-q): bool|string ] { let quiet = try { is_affirmative $quiet } catch { false }; $quiet }
# ```
# GitHub Issue: https://github.com/nushell/nushell/issues/16787
export def is_affirmative [
    --ignore-empty  # Ignore empty strings instead of treating them as errors
    --stdin # Use STDIN instead of arguments for <values>
    --affirmation: string = "affirmative"  # The affirmation mode: 'affirmative' or 'non-affirmative'
    ...values: string
] {
    # Validate affirmation mode
    if not ($affirmation in ["affirmative", "non-affirmative"]) {
        error make { msg: "Invalid affirmation mode." }
    }
    let values = if ($stdin) { $in | lines } else { $values }
    mut affirmed = false
    for value in $values {
        match $value {
            "yes" | "y" | "true" | "Y" | "YES" | "TRUE" => {
                if $affirmation == "non-affirmative" {
                    return false
                }
                $affirmed = true
            }
            "no" | "n" | "false" | "N" | "NO" | "FALSE" => {
                if $affirmation == "affirmative" {
                    return false
                }
                $affirmed = true
            }
            "" => {
                if $ignore_empty {
                    continue
                } else {
                    error make { msg: "No message of desired type.", code: "ENOMSG", status: 91 }
                }
            }
            _ => { error make { msg: "No message of desired type.", code: "ENOMSG", status: 91 } }
        }
    }
    if $affirmed {
        return true
    } else {
        error make { msg: "No message of desired type.", code: "ENOMSG", status: 91 }
    }
}

# Alias for non-affirmative check
export def is_non_affirmative [
    --ignore-empty  # Ignore empty strings instead of treating them as errors
    --stdin # Use STDIN instead of arguments for <values>
    ...values: string
] {
    is_affirmative --affirmation="non-affirmative" --ignore-empty=$ignore_empty --stdin=$stdin ...$values
}

# Terminal title progress bar function with background updater
# Requires /dev/tty to be available, which it needs to be to even see the progress bar.
# ```nu
# #!/usr/bin/env nu
# use ~/.local/share/dorothy/sources/nu.nu terminal_title_progress_bar
# def main [
# 	--start: int = 0
# 	--finish: int = 100
# 	--step: int = 20
# 	--delay: int = 2
# ] {
# 	let progress_id = (terminal_title_progress_bar --create)
# 	mut i = $start
# 	while $i <= $finish {
# 		terminal_title_progress_bar --id $progress_id --progress $i
# 		sleep ($delay * 1sec)
# 		$i = $i + $step
# 	}
# 	terminal_title_progress_bar --id $progress_id --destroy
# }
# ```
export def terminal_title_progress_bar [
	--create                # Create a new Progress Bar and output its <id>.
    --destroy               # Destroy the Progress Bar of <id>.
	--target = '/dev/tty'   # The <target> of Progress Bar updates.
    --id: int = -1          # The Progress Bar identifier. Required for destroy, and for updates if the update is to persist beyond the 15 second timeout.
    --progress: int = -1    # Update the Progress Bar to this integer percentage (0-100).
	--total: int = 100      # Update the Progress Bar relative to to this <total>.
	--remaining: int = -1   # Update the Progress Bar with by this instead of by <progress>.
] {
   if $destroy {
		# Validate <id>	
		if ($id | describe) != "int" or $id < 0 {
			error make {msg: "A valid --id is required to destroy a progress bar."}
		}

        # Kill the Progress Bar's Background Job of <id>
        'destroy' | job send $id | ignore

		# Tell the TTY to destroy the Progress Bar
		$"\e]9;4;0\a" | save --append $target
    } else if $create {
		# Create and output the Progress Bar's Background Job <id>
		job spawn {
			mut ansi = ''
			while true {
				let message = try { job recv --timeout 10sec } catch { '' }
				if not ($message | is-empty) {
					if ($message == 'destroy') {
						# destroy progress bar
						break
					} else {
						# new progress ansi
						$ansi = $message
					}
				}
				if not ($ansi | is-empty) {
					$ansi | save --append $target
				}
			}
		}
	} else {
		# Progress calculation
		mut final_progress = -1
		if ($progress != -1) {
			$final_progress = $progress
		} else if ($remaining != -1) {
			$final_progress = $total - $remaining
		}
		if ($total != 100 and $final_progress != -1) {
			$final_progress = (($final_progress / $total) * 100) | math round
		}

		# Validate progress calculation
		if ( $final_progress < 0 or $final_progress > 100 ) {
			error make {msg: "The --progress or --remaining must be between 0 and the --total to result in a valid integer progress percentage."}
		}

		# Send update
		let $ansi = $"\e]9;4;1;($final_progress)\a"
		if ($id | describe) != "int" or $id < 0 {
			$ansi | save --append $target
		} else {
			$ansi | job send $id
		}
	}
}
