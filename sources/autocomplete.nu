#!/usr/bin/env nu

# https://www.nushell.sh/book/custom_completions.html

# Carapace
# https://carapace-sh.github.io/carapace-bin/setup.html#nushell
command-exists -- 'carapace' | complete; if $env.LAST_EXIT_CODE == 0 {
	source ~/.local/state/dorothy/carapace.nu
}
