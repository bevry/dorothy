#!/usr/bin/env fish

# start the ssh agent
if is-empty-string "$SSH_AUTH_SOCK"
	eval (ssh-agent -c)
	# ssh-add-all
end

# kill it when our cli ends
function finish
	eval "$(ssh-agent -k)"
end
trap finish EXIT