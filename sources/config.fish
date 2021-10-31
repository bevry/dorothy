#!/usr/bin/env fish

function load_dorothy_config
	set --local loaded_at_least_one_filename 'no'

	# load each provided filename
	for filename in $argv
		if test -f "$DOROTHY/user/config.local/$filename"
			# load user/config.local
			source "$DOROTHY/user/config.local/$filename"
			set loaded_at_least_one_filename 'yes'
		else if test -f "$DOROTHY/user/config/$filename"
			# otherwise load user/config
			source "$DOROTHY/user/config/$filename"
			set loaded_at_least_one_filename 'yes'
		else if test -f "$DOROTHY/config/$filename"
			# otherwise load default
			source "$DOROTHY/config/$filename"
			set loaded_at_least_one_filename 'yes'
		end
		# otherwise try next filename
	end

	# if no filename was loaded, then fail and report
	if test "$loaded_at_least_one_filename" = 'no'
		echo "configuration file $filename was not able to be found" >&2  # stderr
		return 2  # No such file or directory
	end
end
