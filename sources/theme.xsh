#!/usr/bin/env xonsh

from os import path

if ${...}.get('DOROTHY_THEME_OVERRIDE') != None:
	$DOROTHY_THEME = $DOROTHY_THEME_OVERRIDE

if ${...}.get('DOROTHY_THEME') != None and ${...}.get('DOROTHY_THEME') != 'system':
	if path.exists($DOROTHY + '/user/themes/' + $DOROTHY_THEME + '.xsh'):
		execx(compilex(open($DOROTHY + '/user/themes/' + $DOROTHY_THEME + '.xsh').read()))
	elif path.exists($DOROTHY + '/themes/' + $DOROTHY_THEME + '.xsh'):
		execx(compilex(open($DOROTHY + '/themes/' + $DOROTHY_THEME + '.xsh').read()))
	else:
		echo-style --stderr --warning=@('Dorothy theme [' + $DOROTHY_THEME + '] is not supported by this shell [xsh]')
