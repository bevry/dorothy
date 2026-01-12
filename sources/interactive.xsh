#!/usr/bin/env xonsh

# =====================================
# Visuals

if !(command-exists -- shuf).returncode == 0:
	shuf -n1 @($DOROTHY + '/sources/shoutouts.txt')
dorothy-warnings warn

# =====================================
# Configuration

# @todo figure out why this doesn't work:
# Source our ability to load configuration files
# evalx(compilex(open($DOROTHY + '/sources/config.xsh').read()))
# Load the configuration for interactive shells
# load_dorothy_config('interactive.xsh')

from os import path

# Load the configuration for interactive shells
if path.exists($DOROTHY + '/user/config.local/interactive.xsh'):
	# load user/config.local/*
	execx(compilex(open($DOROTHY + '/user/config.local/interactive.xsh').read()))
elif path.exists($DOROTHY + '/user/config/interactive.xsh'):
	# otherwise load user/config/*
	execx(compilex(open($DOROTHY + '/user/config/interactive.xsh').read()))
elif path.exists($DOROTHY + '/config/interactive.xsh'):
	# otherwise load default configuration
	execx(compilex(open($DOROTHY + '/config/interactive.xsh').read()))

# =====================================
# Theme

execx(compilex(open($DOROTHY + '/sources/theme.xsh').read()))

# =====================================
# Autocomplete

# Carapace
# https://carapace-sh.github.io/carapace-bin/setup.html#xonsh
if !(command-exists -- carapace).returncode == 0:
	COMPLETIONS_CONFIRM=True
	exec($(carapace _carapace xonsh))
