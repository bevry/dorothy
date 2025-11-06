#!/usr/bin/env fish

# @note the below code is commented out, as I only discovered I needed the exports after years of it not working
# and as fundle isn't necessary, fundle probably makes more sense inside config/interactive.fish
# which if someone requests it, it can move there

# # set essentials
# set --export XDG_CONFIG_HOME "$XDG_CONFIG_HOME" or "$HOME/.config"
# set --export XDG_CACHE_HOME "$XDG_CACHE_HOME" or "$HOME/.cache"
# set --export XDG_BIN_HOME "$XDG_BIN_HOME" or "$HOME/.local/bin"
# set --export XDG_DATA_HOME "$XDG_DATA_HOME" or "$HOME/.local/share"
# set --export XDG_STATE_HOME "$XDG_STATE_HOME" or "$HOME/.local/state"

# # install fundle
# if not functions -q fundle
# 	if not test -f "$XDG_CONFIG_HOME/fish/functions/fundle.fish"
# 		mkdir -p -- "$XDG_CONFIG_HOME/fish/functions"
# 		curl -sfL https://git.io/fundle > "$XDG_CONFIG_HOME/fish/functions/fundle.fish"
# 	end
# 	source "$XDG_CONFIG_HOME/fish/functions/fundle.fish"
# end

# # install bash and nvm support
# fundle plugin 'edc/bass'
# fundle plugin 'arzig/nvm-fish'

# # initialise
# fundle init || begin
# 	fundle install
# 	fundle init
# end

# essential
source "$DOROTHY/sources/environment.fish"
