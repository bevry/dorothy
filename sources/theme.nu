#!/usr/bin/env nu

if 'DOROTHY_THEME_OVERRIDE' in $env and $env.DOROTHY_THEME_OVERRIDE != '' {
	$env.DOROTHY_THEME = $env.DOROTHY_THEME_OVERRIDE
}

if 'DOROTHY_THEME' in $env and $env.DOROTHY_THEME != '' {
	if $env.DOROTHY_THEME == 'oz' {
		source ../themes/oz.nu
	} else if $env.DOROTHY_THEME == 'starship' {
		source ../themes/starship.nu
	} else if $env.DOROTHY_THEME == 'demo' {
		source ../themes/demo.nu
	} else {
		echo-style --stderr $'--warning=WARNING:' ' ' $'Dorothy theme `($env.DOROTHY_THEME)` is not supported by this shell `nu`'
	}
}
