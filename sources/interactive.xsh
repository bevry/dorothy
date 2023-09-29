#!/usr/bin/env xonsh

# Source our ability to load configuration files
evalx(compilex(open($DOROTHY + '/sources/config.xsh').read()))

# Load the configuration for interactive shells
# load_dorothy_config('interactive.xsh') # <-- this isn't availiable for some reason

# Continue with the shell extras
# execx(compilex(open($DOROTHY + '/sources/history.xsh').read()))
execx(compilex(open($DOROTHY + '/sources/theme.xsh').read()))
# execx(compilex(open($DOROTHY + '/sources/ssh.xsh').read()))
# execx(compilex(open($DOROTHY + '/sources/autocomplete.xsh').read()))

# @todo someone more experienced with xonsh should get config files loading, and get history, ssh, and autocomplete going
