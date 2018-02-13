#!/usr/bin/env fish

# Don't check mail
export MAILCHECK=0

# Disable welcome greeting
set -U fish_greeting

# Paths
source "$HOME/.scripts/sources/var.fish"
source "$HOME/.scripts/sources/paths.fish"

# Fisherman
if test -d "$HOME/.config/fisherman"; else
	echo "setting up fisherman..."
	curl -Lo ~/.config/fish/functions/fisher.fish --create-dirs git.io/fisher
	fisher edc/bass nvm done choices
	echo "...fisherman setup, reload your terminal"
	exit
end

# Editor
eval (setup-editor-commands)
function edit
	if is_ssh
		eval "$TERMINAL_EDITOR" $argv
	else
		eval "$GUI_EDITOR" $argv
	end
end

# Extras
source "$HOME/.scripts/sources/aliases.sh"
source "$HOME/.scripts/sources/ssh.fish"
source "$HOME/.scripts/sources/azure.fish"
source "$HOME/.scripts/sources/secure.fish"
if is_mac
	source "$HOME/.scripts/sources/mac.sh"
else if is_linux
	source "$HOME/.scripts/sources/linux.sh"
end
if is_file "$HOME/.scripts/env.sh"
	source "$HOME/.scripts/env.sh"
end

# Theme
if is_equal "$THEME" "baltheme"
	function fish_prompt
		~/.scripts/themes/baltheme fish
	end
end
