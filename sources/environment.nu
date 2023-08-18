#!/usr/bin/env nu

# set the environment variables
setup-environment-commands 'nu'
	| lines
	| parse -r 'setenv (?P<name>\w+) *(?P<value>.*)'
	| transpose -r
	| into record
	| load-env
