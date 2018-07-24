#!/usr/bin/env fish

# Don't check mail
export MAILCHECK=0

# Disable welcome greeting
set -U fish_greeting

# Essential
source "$HOME/.scripts/sources/var.fish"
source "$HOME/.scripts/sources/user.fish"
source "$HOME/.scripts/sources/paths.fish"
if test -d "$HOME/.config/fisherman"; else
	echo "setting up fisherman..."
	curl -Lo ~/.config/fish/functions/fisher.fish --create-dirs git.io/fisher
	fisher edc/bass nvm done choices
	echo "...fisherman setup, reload your terminal"
	exit
end
source "$HOME/.scripts/sources/edit.fish"
