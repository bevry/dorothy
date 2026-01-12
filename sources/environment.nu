#!/usr/bin/env nu

# set the environment variables
setup-environment-commands --shell=nu
	| lines
	| parse -r 'setenv (?P<name>\w+) *(?P<value>.*)'
	| transpose -r
	| into record
	| load-env
# @todo: someone experienced with nu should send a PR to add detection (like fish and bash have) on failures of the above command
