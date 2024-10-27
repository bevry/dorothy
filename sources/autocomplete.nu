#!/usr/bin/env nu

# https://www.nushell.sh/book/custom_completions.html
# https://rsteube.github.io/carapace-bin/setup.html#nushell

# if carapace, then load carapace
command-exists -- 'carapace' | complete; if $env.LAST_EXIT_CODE == 0 {
	source ~/.local/state/dorothy/sources/carapace.nu
}
