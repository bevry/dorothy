#!/usr/bin/env fish

# Don't check mail
export MAILCHECK=0

# Path
set PATH $PATH $HOME/.scripts/commands

# Fisherman
if is_dir "$HOME/.config/fisherman"
	# Paths
	bass "$HOME/.scripts/sources/paths.bash"

	# Extras
	source "$HOME/.scripts/sources/aliases.sh"
	if is_file "$HOME/.scripts/env.sh"
		source "$HOME/.scripts/env.sh"
	end

	# SSH Keys silently
	silent addsshkeys
else
	echo "setting up fish..."
	curl -Lo ~/.config/fish/functions/fisher.fish --create-dirs git.io/fisher
	fisher edc/bass
	echo "fish setup, load it again"
	exit 0
end
