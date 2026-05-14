#!/usr/bin/env xsh

if !(command-missing -- starship).returncode == 0:
	setup-util-starship --dependency

execx($(starship init xonsh))
