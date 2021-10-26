#!/usr/bin/env fish

function load_dorothy_config
	set found 'no'

	# load user/config.local
	for filename in $argv
		if test -f "$DOROTHY_USER_HOME/config.local/$filename"
			source "$DOROTHY_USER_HOME/config.local/$filename"
			set found 'yes'
		end
	end

	# load user/config
	for filename in $argv
		if test -f "$DOROTHY_USER_HOME/config/$filename"
			source "$DOROTHY_USER_HOME/config/$filename"
			set found 'yes'
		end
	end

	# load default if no user config was found
	if test "$found" = 'no'
		if test -f "$DOROTHY/config/$filename"
			source "$DOROTHY/config/$filename"
		end
	end

end
