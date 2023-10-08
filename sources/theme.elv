#!/usr/bin/env elvish

if (has-env DOROTHY_THEME_OVERRIDE) {
	set-env DOROTHY_THEME $E:DOROTHY_THEME_OVERRIDE
}

if (and (has-env DOROTHY_THEME) (not-eq $E:DOROTHY_THEME 'system')) {
	if ?(test -f $E:DOROTHY'/user/themes/'$E:DOROTHY_THEME'.elv') {
		eval (cat $E:DOROTHY'/user/themes/'$E:DOROTHY_THEME'.elv' | slurp)
	} elif ?(test -f $E:DOROTHY'/themes/'$E:DOROTHY_THEME'.elv') {
		eval (cat $E:DOROTHY'/themes/'$E:DOROTHY_THEME'.elv' | slurp)
	} else {
		echo-style --warning='Dorothy theme ['$E:DOROTHY_THEME'] is not supported by this shell [elvish]' >/dev/stderr
	}
}
