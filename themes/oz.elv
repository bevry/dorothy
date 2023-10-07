#!/usr/bin/env elvish

# taken from starship
var cmd-status-code = 0
fn starship-after-command-hook {|m|
    var error = $m[error]
    if (is $error $nil) {
        set cmd-status-code = 0
    } else {
        try {
            set cmd-status-code = $error[reason][exit-status]
        } catch {
            # The error is from the built-in commands and they have no status code.
            set cmd-status-code = 1
        }
    }
}
set edit:after-command = [ $@edit:after-command $starship-after-command-hook~ ]

# our customisation
set edit:prompt = {
	if ?(test -d &follow-symlink=$true $E:DOROTHY) {
		printf '%s\n' 'DOROTHY has been moved, please re-open your shell'
		return 1
	}
	$E:DOROTHY'/themes/oz' elvish $cmd-status-code
}
