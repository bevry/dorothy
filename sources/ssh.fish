#!/usr/bin/env fish

# do not use sd instead of sed, as our environment is not yet configured

# set --local fish_trace on
set --global SSH_AUTH_SOCK
set --global SSH_AGENT_PID

# gpg
if command-exists -- gpg
	set --export GPG_TTY (tty)
end

# ssh-agent
if command-exists -- ssh-agent
	# start ssh-agent and export SSH_AUTH_SOCK and SSH_AGENT_PID
	if test -z "$SSH_AUTH_SOCK"
		# @todo replace with `echo-regexp` and `echo-write`
		eval (ssh-agent -c | sed -E 's/^setenv /set --global --export /; s/^echo /#echo /')
	end

	# shutdown the ssh-agent when our shell exits
	function on_ssh_finish
		# killall ssh-agent
		# @todo replace with `echo-regexp` and `echo-write`
		eval (ssh-agent -k | sed -E 's/^unset /set --erase /; s/^echo /#echo /')
	end
	trap on_ssh_finish EXIT
end
