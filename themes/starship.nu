#!/usr/bin/env nu

command-exists 'starship' | complete
if $env.LAST_EXIT_CODE == 0 {
	setup-util-starship --quiet
}
starship init nu | save -f ~/.cache/starship/init.nu
if ( echo ~/.cache/starship/init.nu | path exists ) {
	use ~/.cache/starship/init.nu
}
