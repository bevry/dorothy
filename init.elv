#!/usr/bin/env elvish
use runtime

# this should be consistent with:
# $DOROTHY/init.*
# $DOROTHY/commands/dorothy
if (not (has-env 'DOROTHY')) {
	set-env 'DOROTHY' $E:HOME'/.local/share/dorothy'
}

# https://elv.sh/ref/command.html#rc-file
# https://elv.sh/ref/runtime.html
# https://github.com/elves/elvish/issues/1726
eval (cat $E:DOROTHY'/sources/environment.elv' | slurp)
if (not-eq $runtime:effective-rc-path $nil) {
	eval (cat $E:DOROTHY'/sources/interactive.elv' | slurp)
}
