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
	# remove the : prefix on each argument to work around nushell's arg issues
	mut $args = $args | each { |arg| $arg | str replace --regex '^:' '' }
	# action
    if $action == 'make' {
        if ($args | length) mod 2 != 0 {
            error make { msg: '<make> requires an even number of <key> <value> pairs.' }
        }
        mut rec = {}
        mut index = 0
        while $index < ($args | length) {
            let key = $args | get $index
            let val = $args | get ($index + 1)
            let val = try { $val | from json } catch { $val }
            $rec = ($rec | insert $key $val)
            $index = $index + 2
        }
        print ($rec | to json -r)
        return $?
    }
    for input in $args {
		match $action {
			'stringify' => { print ($input | into string | to json -r) }
			'encode' => {
				let value = try { $input | from json } catch { $input }
				print ($value | to json -r)
			}
			'decode' => {
				let value = try { $input | from json } catch { $input }
				if ($value | describe) == 'string' {
					print $value
				} else {
					print ($value | to json -r)
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
