#!/usr/bin/env nu

# https://www.nushell.sh/book/custom_completions.html
# https://rsteube.github.io/carapace-bin/setup.html#nushell

# if carapace, then source carapace
if (command-exists 'carapace' | complete).LAST_EXIT_CODE == 0 {
	# use state instead of cache, as state is the correct place for it
	if ( open ~/.local/state/carapace/init.nu | length ) == 0 {
		# init script is placeholder, so replace it
		carapace _carapace nushell  | save --force ~/.local/state/carapace/init.nu
	}
	source ~/.local/state/carapace/init.nu
}
