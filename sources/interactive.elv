#!/usr/bin/env elvish

# use test -f, instead of os builtin, as test -f actually handles /user symlink

# Load the configuration for interactive shells
if ?(test -f $E:DOROTHY'/user/config.local/interactive.elv') {
	eval (cat $E:DOROTHY'/user/config.local/interactive.elv' | slurp)
} elif ?(test -f $E:DOROTHY'/user/config/interactive.elv') {
	eval (cat $E:DOROTHY'/user/config/interactive.elv' | slurp)
} elif ?(test -f $E:DOROTHY'/config/interactive.elv') {
	eval (cat $E:DOROTHY'/config/interactive.elv' | slurp)
}

# Continue with the shell extras
# use ./history.elv
eval (cat $E:DOROTHY'/sources/theme.elv' | slurp)
# use ./ssh.elv
eval (cat $E:DOROTHY'/sources/autocomplete.elv' | slurp)

# Shoutouts
if ?(command-exists -- shuf) {
	shuf -n1 $E:DOROTHY'/sources/shoutouts.txt'
}
dorothy-warnings warn
