#!/usr/bin/env fish

# for scripts and sources to load a configuration file
# <filename...>
function load_dorothy_config
	set --local dorothy_config_loaded 'no'

	# for each filename, load a single config file
	for filename in $argv
		if test -f "$DOROTHY/user/config.local/$filename"
			# load user/config.local/*
			source "$DOROTHY/user/config.local/$filename"
			set dorothy_config_loaded 'yes'
		else if test -f "$DOROTHY/user/config/$filename"
			# otherwise load user/config/*
			source "$DOROTHY/user/config/$filename"
			set dorothy_config_loaded 'yes'
		else if test -f "$DOROTHY/config/$filename"
			# otherwise load default configuration
			source "$DOROTHY/config/$filename"
			set dorothy_config_loaded 'yes'
		end
		# otherwise try next filename
	end

	# if nothing was loaded, then fail
	if test "$dorothy_config_loaded" = 'no'
		echo-style --error="Missing the configuration file: $argv" >/dev/stderr
		return 2  # No such file or directory
	end
end
