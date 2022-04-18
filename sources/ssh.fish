#!/usr/bin/env fish

# set --local fish_trace on
set --global SSH_AUTH_SOCK
set --global SSH_AGENT_PID

# fix gpg errors, caused by lack of authentication of gpg key, caused by pinentry not being aware of tty
#   error: gpg failed to sign the data
#   fatal: failed to write commit object
# you can test it is working via:
#   setup-git
#   echo "test" | gpg --clearsign
# if you are still getting those errors, check via `gpg-helper list` that your key has not expired
# if it has, then run `gpg-helper extend`
if command-exists gpg
	set --export GPG_TTY (tty)
end

# do not use sd instead of sed for this
# as sd will not be found yet

# only work on environments that have an ssh-agent
if command-exists ssh-agent
	# start the ssh agent
	if test -z "$SSH_AUTH_SOCK"
		eval (ssh-agent -c | sed -E 's/^setenv /set --global --export /; s/^echo /#echo /')
	end

	# kill it when our cli ends
	function finish
		# killall ssh-agent
		eval (ssh-agent -k | sed -E 's/^unset /set --erase /; s/^echo /#echo /')
	end
	trap finish EXIT
end

# set --erase fish_trace

