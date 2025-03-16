#!/usr/bin/env xonsh
# @todo THIS IS UNUSED, AS COULD NOT GET IT WORKING AS INTENDED

from os import path

# for scripts and sources to load a configuration file
# load_dorothy_config [--first] [--silent] [--] ...<filename>
def load_dorothy_config(*args):
	# process arguments
	only_first = False
	optional = False
	while len(args) > 0:
		if args[0] == '--first':
			args = args[1:]
			only_first = True
		elif args[0] == '--optional':
			args = args[1:]
			optional = True
		elif args[0] == '--':
			args = args[1:]
			break
		else:
			break

	# load the configuration
	loaded = False
	# for each filename, try user/config.local otherwise user/config
	for filename in args:
		if path.exists($DOROTHY + '/user/config.local/' + filename):
			# load user/config.local/*
			execx(compilex(open($DOROTHY + '/user/config.local/' + filename).read()))
			loaded = True
		elif path.exists($DOROTHY + '/user/config/' + filename):
			# load user/config/*
			execx(compilex(open($DOROTHY + '/user/config/' + filename).read()))
			loaded = True
		if only_first == 'yes' and loaded == 'yes':
			break
	# if no user-defined configuration was provided, try the same filenames, but in the default configuration
	if loaded == False:
		for filename in args:
			if path.exists($DOROTHY + '/config/' + filename):
				# load default configuration
				execx(compilex(open($DOROTHY + '/config/' + filename).read()))
				loaded = True
			if only_first == 'yes' and loaded == 'yes':
				break

	# if nothing was loaded, then fail
	if loaded == False:
		if optional == False:
			echo-style --stderr --error=@('Missing the configuration file: ' + args.join(' '))
			return 2  # ENOENT 2 No such file or directory
	return 0
