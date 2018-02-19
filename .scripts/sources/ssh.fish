#!/usr/bin/env fish

function startssh
	# http://rabexc.org/posts/pitfalls-of-ssh-agents
	if test -z "$SSH_AUTH_SOCK"
		eval (ssh-agent -c)
	end
end

function addsshkey
	startssh
	ssh-add -K "$HOME/.ssh/$argv[1]"
end

function addsshkeys
	startssh
	ssh-add -A
	echo 'If your keys were not added, you may need to re-add them to the keychain via: addsshkey <name>'
end
