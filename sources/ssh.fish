#!/usr/bin/env fish

function ssh-start-helper
	# http://rabexc.org/posts/pitfalls-of-ssh-agents
	if is-empty-string "$SSH_AUTH_SOCK"
		eval (ssh-agent -c)
	end
end
