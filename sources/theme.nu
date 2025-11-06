#!/usr/bin/env nu

# if ( scope variables | where name == "$DOROTHY_THEME_OVERRIDE" ) {
# 	let DOROTHY_THEME: string = $DOROTHY_THEME_OVERRIDE
# }

#  if "$DOROTHY_THEME" in (scope variables | get name) {
	# can't do this as nushell doesn't support dynamic sources
	# if $DOROTHY_THEME != 'system' {
	# 	if $"../user/themes/($DOROTHY_THEME).nu" {
	# 		source $"../user/themes/($DOROTHY_THEME).nu"
	# 	} else if test -f $"../themes/($DOROTHY_THEME).nu" {
	# 		source $"../themes/($DOROTHY_THEME).nu"
	# 	} else {
	# 		echo-style --stderr $"--warning=Dorothy theme [($DOROTHY_THEME)] is not supported by this shell [nu]"
	# 	}
	# }
	# instead do it manually

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
		echo-style --stderr $'--warning=Dorothy theme [($env.DOROTHY_THEME)] is not supported by this shell [nu]'
	}
}
