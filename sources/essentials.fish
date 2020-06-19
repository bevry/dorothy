#!/usr/bin/env fish

# Don't check mail
export MAILCHECK=0

# Disable welcome greeting
set -U fish_greeting

# Bugfix
function fish_user_key_bindings
end

# Essential
source "$BDIR/sources/paths.fish"
source "$BDIR/sources/user.fish"

# Bash & NVM
if not functions -q fundle
	eval (curl -sfL https://git.io/fundle-install)
	fundle plugin 'edc/bass'
	fundle plugin 'arzig/nvm-fish'
	fundle install
	exit
else
	fundle plugin 'edc/bass'
	fundle plugin 'arzig/nvm-fish'
	fundle init
end
