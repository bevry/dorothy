#!/usr/bin/env elvish

# Carapace
# https://carapace-sh.github.io/carapace-bin/setup.html#elvish
if ?( command-exists -- carapace ) {
	eval (carapace _carapace elvish | slurp)
}
