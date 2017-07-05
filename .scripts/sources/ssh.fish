#!/usr/bin/env fish

function addsshkey
	eval (ssh-agent -c)
	ssh-add -K "$HOME/.ssh/$1"
end

function addsshkeys
	eval (ssh-agent -c)
	ssh-add -A
end
