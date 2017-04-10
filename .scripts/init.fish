#!/bin/fish

# Don't check mail
export MAILCHECK=0

# Path
set PATH $PATH $HOME/.scripts/commands

# Fisherman
if is_dir "$HOME/.config/fisherman"; else
	curl -Lo ~/.config/fish/functions/fisher.fish --create-dirs git.io/fisher
end
if is_file "$HOME/.config/fish/functions/bass.fish"; else
	fisher edc/bass
end

# Paths
bass "$HOME/.scripts/sources/paths.bash"

# Extras
source "$HOME/.scripts/sources/aliases.sh"

if is_file "$HOME/.scripts/env.sh"
	source "$HOME/.scripts/env.sh"
end

# SSH Keys silently
silent addsshkeys
