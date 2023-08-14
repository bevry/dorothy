#!/usr/bin/env fish

# disable welcome greeting
set --universal fish_greeting

# bugfix
function fish_user_key_bindings
end

# install fundle
if not functions -q fundle
	if not test -f "$XDG_CONFIG_HOME/fish/functions/fundle.fish"
		mkdir -p "$XDG_CONFIG_HOME/fish/functions"
		curl -sfL https://git.io/fundle > "$XDG_CONFIG_HOME/fish/functions/fundle.fish"
	end
	source "$XDG_CONFIG_HOME/fish/functions/fundle.fish"
end

# install bash and nvm support
fundle plugin 'edc/bass'
fundle plugin 'arzig/nvm-fish'

# initialise
fundle init || begin
	fundle install
	fundle init
end

# essential
source "$DOROTHY/sources/environment.fish"
