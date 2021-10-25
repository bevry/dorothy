#!/usr/bin/env fish

function load_dorothy_config
	filename=$argv[1]
	if test -f "$DOROTHY_USER_HOME/config.local/$filename"
		# source user local configuration
		source "$DOROTHY_USER_HOME/config.local/$filename"
	else if test -f "$DOROTHY_USER_HOME/config/$filename"
		# source user standard configuration
		source "$DOROTHY_USER_HOME/config/$filename"
	else
		# source default configuration
		source "$DOROTHY/config/$filename"
	end
end
