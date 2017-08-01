#!/usr/bin/env fish

function addsshkey
	eval (ssh-agent -c)
	ssh-add -K "$HOME/.ssh/$argv[1]"
end

function addsshkeys
	eval (ssh-agent -c)
	ssh-add -A
	echo 'If your keys were not added, you may need to re-add them to the keychain via: addsshkey <name>'
end
