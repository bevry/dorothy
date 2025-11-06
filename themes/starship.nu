#!/usr/bin/env nu

# ensure starship
mut reload_required_for_starship = false
command-exists -- 'starship' | complete; if $env.LAST_EXIT_CODE != 0 {
	# starship is missing, install it
	setup-util-starship --quiet
	# must reload the shell to ensure starship is loaded
	echo-style --notice='Starship installed, reload your terminal.'
	exit 35 # EAGAIN 35 Resource temporarily unavailable
}

# starship exists, load starship
source ~/.local/state/dorothy/starship.nu
