#!/usr/bin/env nu

def main [
	action: string
	...args
] {
    let actions = [make stringify encode decode json pretty table csv tsv stream]
	# validate
    if $action not-in $actions {
        error make { msg: $"An unrecognised <action> was provided: ($action)" }
    }
	# parse [...options] ...<input>
	mut properties = []
	mut inputs = []
	mut done_options = false
	for arg in $args {
		let cleaned = ($arg | str replace --regex '^:' '')
		if $done_options {
			$inputs = ($inputs | append $cleaned)
		} else if $cleaned == '--' {
			$done_options = true
		} else if ($cleaned | str starts-with '--property=') {
			let prop_value = ($cleaned | str replace '--property=' '')
			$properties = ($properties | append $prop_value)
		} else {
			$inputs = ($inputs | append $cleaned)
		}
	}
	# action
    if $action == 'make' {
        if ($inputs | length) mod 2 != 0 {
            error make { msg: '<make> requires an even number of <key> <value> pairs.' }
        }
        mut rec = {}
        mut index = 0
        while $index < ($inputs | length) {
            let key = $inputs | get $index
            let val = $inputs | get ($index + 1)
            let val = try { $val | from json } catch { $val }
            $rec = ($rec | insert $key $val)
            $index = $index + 2
        }
        print ($rec | to json -r)
        return
    }
    for input in $inputs {
		match $action {
			'stringify' => { print ($input | into string | to json -r) }
			'encode' => {
				let value = try { $input | from json } catch { $input }
				print ($value | to json -r)
			}
			'decode' => {
				let value = try { $input | from json } catch { $input }
				if ($properties | is-empty) {
					if ($value | describe) == 'string' {
						print $value
					} else {
						print ($value | to json -r)
					}
				} else {
					let outputs = ($properties | each { |property|
						let keys = ($property | split row '.')
						mut diver = $value
						for key in $keys {
							$diver = ($diver | get $key)
						}
						if ($diver | describe) == 'string' {
							$diver
						} else {
							$diver | to json -r
						}
					})
					print ($outputs | str join "\n")
				}
			}
			'json' => {
				let parsed = $input | from json
				print ($parsed | to json -r)
			}
			'pretty' => {
				let parsed = $input | from json
				print ($parsed | to nuon)
			}
			'table' => {
				let parsed = $input | from json
				print ($parsed | table)
			}
			'csv' => {
				let parsed = $input | from json
				print ($parsed | to csv)
			}
			'tsv' => {
				let parsed = $input | from json
				print ($parsed | to tsv)
			}
		}
    }
}
