#!/usr/bin/env nu

# nu does set the standard version variable, so we should do so
let NU_VERSION: string = (version | get version)

# set the environment variables
setup-environment-commands 'nu'
	| lines
	| parse -r 'setenv (?P<name>\w+) *(?P<value>.*)'
	| transpose -r
	| into record
	| load-env
