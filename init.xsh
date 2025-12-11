#!/usr/bin/env xonsh

# https://xon.sh/bash_to_xsh.html?highlight=function
# https://github.com/anki-code/xonsh-cheatsheet

# this should be consistent with:
# $DOROTHY/init.*
# $DOROTHY/commands/dorothy
if ${...}.get('DOROTHY') == None:
	$DOROTHY = $HOME + '/.local/share/dorothy'

if $XONSH_LOGIN == True:
	execx(compilex(open($DOROTHY + '/sources/environment.xsh').read()))
	if $XONSH_INTERACTIVE == True:
		execx(compilex(open($DOROTHY + '/sources/interactive.xsh').read()))
