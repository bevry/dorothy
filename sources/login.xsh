#!/usr/bin/env xonsh

# essential
execx(compilex(open($DOROTHY + '/sources/environment.xsh').read()))

# clear the theme cache
get-terminal-theme --clear-cache
