#!/usr/bin/env fish

function addsshkey
	eval (ssh-agent -s)
	ssh-add -K "$HOME/.ssh/$1"
end

function addsshkeys
	eval (ssh-agent -s)
	ssh-add -A
end
