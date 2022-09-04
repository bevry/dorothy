#!/usr/bin/env fish

# don't check mail
export MAILCHECK=0

# disable welcome greeting
set --universal fish_greeting

# bugfix
function fish_user_key_bindings
end

# essential
source "$DOROTHY/sources/environment.fish"

# Bash & NVM
if not functions -q fundle
	eval (fetch 'https://git.io/fundle-install')
	echo 'fundle had to be installed, reopen your shell'
	return 0
else
	# the install above will run this
	fundle plugin 'edc/bass'
	fundle plugin 'arzig/nvm-fish'

	# determine grep locaiton, as paths are not setup yet
	if test -x /bin/grep
		set GREP /bin/grep
	else if test -x /usr/bin/grep
		set GREP /usr/bin/grep
	else
		set GREP (which grep)
	end

	# initialise
	if fundle init | "$GREP" 'fundle install'
		fundle install
		fundle init
	end

	# erase our grep temp variable
	set --erase GREP
end
