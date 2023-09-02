#!/usr/bin/env nu

# ensure starship
mut reload_required_for_starship = false
command-exists 'starship' | complete
if $env.LAST_EXIT_CODE != 0 {
	# starship is missing, install it
	setup-util-starship --quiet
	$reload_required_for_starship = true
}
if ( open ~/.local/state/starship/init.nu | length ) == 0 {
	# init script is placeholder, update it
	starship init nu | save --force ~/.local/state/starship/init.nu
	$reload_required_for_starship = true
}
if $reload_required_for_starship == true {
	# reload the shell to ensure starship is loaded
	echo-style --notice='Starship installed, reload your terminal.'
	exit 35 # EAGAIN 35 Resource temporarily unavailable
}

# load the actual starship init script
use ~/.local/state/starship/init.nu
