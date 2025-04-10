#!/usr/bin/env fish

# for scripts and sources to load a configuration file
# load_dorothy_config [--first] [--silent] [--] ...<filename>
function load_dorothy_config
	# process arguments
	set --local only_first 'no'
	set --local optional 'no'
	while test (count $argv) -ne 0
		switch $argv[1]
			case '--first'
				set -e argv[1]
				set only_first 'yes'
			case '--optional'
				set -e argv[1]
				set optional 'yes'
			case '--'
				set -e argv[1]
				break
			case '*'
				break
		end
	end

	# load the configuration
	set --local filename
	set --local loaded 'no'
	# for each filename, try user/config.local otherwise user/config
	for filename in $argv
		if test -f "$DOROTHY/user/config.local/$filename"
			# load user/config.local/*
			source "$DOROTHY/user/config.local/$filename"
			set loaded 'yes'
		else if test -f "$DOROTHY/user/config/$filename"
			# load user/config/*
			source "$DOROTHY/user/config/$filename"
			set loaded 'yes'
		end
		if test "$only_first" = 'yes' -a "$loaded" = 'yes'
			break
		end
	end
	# if no user-defined configuration was provided, try the same filenames, but in the default configuration
	if test "$loaded" = 'no'
		for filename in $argv
			if test -f "$DOROTHY/config/$filename"
				# load default configuration
				source "$DOROTHY/config/$filename"
				set loaded 'yes'
			end
			if test "$only_first" = 'yes' -a "$loaded" = 'yes'
				break
			end
		end
	end

	# if nothing was loaded, then fail
	if test "$loaded" = 'no'
		if test "$optional" = 'no'
			echo-style --stderr --error="Missing the configuration file: $argv"
			return 2  # ENOENT 2 No such file or directory
		end
	end
	return 0
end
