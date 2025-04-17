#!/usr/bin/env xonsh

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

# Continue with the shell extras
# execx(compilex(open($DOROTHY + '/sources/history.xsh').read()))
execx(compilex(open($DOROTHY + '/sources/theme.xsh').read()))
# execx(compilex(open($DOROTHY + '/sources/ssh.xsh').read()))
execx(compilex(open($DOROTHY + '/sources/autocomplete.xsh').read()))

# @todo someone more experienced with xonsh should get config files loading, and get history, ssh, and autocomplete going

# Shoutouts
if !(command-exists -- shuf).returncode == 0:
	shuf -n1 @($DOROTHY + '/sources/shoutouts.txt')
dorothy-warnings warn
