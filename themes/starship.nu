#!/usr/bin/env nu

command-exists 'starship' | complete
if $env.LAST_EXIT_CODE == 0 {
	setup-util-starship --quiet
}

use ~/.cache/starship/init.nu
