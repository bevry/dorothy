#!/usr/bin/env fish

# Don't check mail
export MAILCHECK=0

# Paths
source "$HOME/.scripts/sources/var.fish"
var_add PATH "$HOME/.scripts/commands"
function paths_init
	eval (paths_commands)
end
paths_init

# Fisherman
if test -d "$HOME/.config/fisherman"; else
	echo "setting up fisherman..."
	curl -Lo ~/.config/fish/functions/fisher.fish --create-dirs git.io/fisher
	# fisher edc/bass <-- bass doesn't work well
	echo "...fisherman setup"
end

# Extras
eval (editor_commands)
source "$HOME/.scripts/sources/aliases.sh"
if is_file "$HOME/.scripts/env.sh"
	source "$HOME/.scripts/env.sh"
end

# SSH Keys silently
silent addsshkeys
