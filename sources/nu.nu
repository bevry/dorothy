#!/usr/bin/env nu

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
