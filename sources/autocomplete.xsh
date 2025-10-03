#!/usr/bin/env xonsh

# Carapace
# https://carapace-sh.github.io/carapace-bin/setup.html#xonsh
if !(command-exists -- carapace).returncode == 0:
	COMPLETIONS_CONFIRM=True
	exec($(carapace _carapace xonsh))
