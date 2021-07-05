#!/usr/bin/env fish

# only work on environments that have an ssh-agent
if command-exists ssh-agent
	# start the ssh agent
	if test -z "$SSH_AUTH_SOCK"
		eval (ssh-agent -c)
		# ssh-add-all
	end

	# kill it when our cli ends
	function finish
		# killall ssh-agent
		eval (ssh-agent -k)
	end
	trap finish EXIT
end
