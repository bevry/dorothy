#!/usr/bin/env fish

# set --local fish_trace on
set --global SSH_AUTH_SOCK
set --global SSH_AGENT_PID

# only work on environments that have an ssh-agent
if command-exists ssh-agent
	# start the ssh agent
	if test -z "$SSH_AUTH_SOCK"
		eval (ssh-agent -c | sed -E 's/^setenv /set --global --export /; s/^echo /#echo /')
		# ssh-add-all
	end

	# kill it when our cli ends
	function finish
		# killall ssh-agent
		eval (ssh-agent -k | sed -E 's/^unset /set --erase /; s/^echo /#echo /')
	end
	trap finish EXIT
end

# set --erase fish_trace

