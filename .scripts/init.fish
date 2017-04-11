#!/usr/bin/env fish

# Don't check mail
export MAILCHECK=0

# Path
function varadd
	set exists "no"
	for line in $$argv[1]
		echo "[$line] [$argv[2]]"
		if test "$line" = "$argv[2]"
			set exists "yes"
			break
		end
	end
	if test "$exists" = "no"
		set -x "$argv[1]" "$argv[2]" $$argv[1]
	end
end
varadd PATH "$HOME/.scripts/commands"

# Fisherman
if is_dir "$HOME/.config/fisherman"
	# Paths
	eval (varpaths)

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
