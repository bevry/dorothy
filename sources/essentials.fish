#!/usr/bin/env fish

# Don't check mail
export MAILCHECK=0

# Disable welcome greeting
set -U fish_greeting

# Bugfix
function fish_user_key_bindings
end

# Essential
source "$DOROTHY/sources/paths.fish"
source "$DOROTHY/sources/user.fish"

# Bash & NVM
if not functions -q fundle
	eval (fetch https://git.io/fundle-install)
	echo 'fundle had to be installed, reopen your shell'
	exit
else
	# the install above will run this
	fundle plugin 'edc/bass'
	fundle plugin 'arzig/nvm-fish'
	# /usr/bin/grep is needed, as paths are not setup yet
	if fundle init | /usr/bin/grep 'fundle install'
		fundle install
		fundle init
	end
end
