#!/usr/bin/env elvish

# https://rsteube.github.io/carapace-bin/setup.html#elvish
if ?( command-exists carapace ) {
	eval (carapace _carapace | slurp)
}
