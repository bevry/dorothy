#!/usr/bin/env fish
# set --local fish_trace on

# =====================================
# Visuals

# Shoutouts
if command-exists -- shuf
	shuf -n1 "$DOROTHY/sources/shoutouts.txt"
end
dorothy-warnings warn

# =====================================
# Configuration

# Source our ability to load configuration files
source "$DOROTHY/sources/config.fish"

# Load the configuration for interactive shells
load_dorothy_config --first --optional -- 'interactive.fish' 'interactive.sh'

# =====================================
# Theme

source "$DOROTHY/sources/theme.fish"

# =====================================
# SSH

set --global SSH_AUTH_SOCK
set --global SSH_AGENT_PID

# gpg
if command-exists -- gpg
	set --export GPG_TTY (tty)
end

# ssh-agent
# do not use sd instead of sed, as our environment is not yet configured
if command-exists -- ssh-agent
	# start ssh-agent and export SSH_AUTH_SOCK and SSH_AGENT_PID
	if test -z "$SSH_AUTH_SOCK"
		eval (ssh-agent -c | sed -E 's/^setenv /set --global --export /; s/^echo /#echo /')
	end

	# shutdown the ssh-agent when our shell exits
	function on_ssh_finish
		# killall ssh-agent
		eval (ssh-agent -k | sed -E 's/^unset /set --erase /; s/^echo /#echo /')
	end
	trap on_ssh_finish EXIT
end

# =====================================
# Autocomplete

# Visual Studio Code Terminal Shell Integration
# https://code.visualstudio.com/docs/terminal/shell-integration#_manual-installation
if test "$TERM_PROGRAM" = 'vscode' && command-exists -- code
	. (code --locate-shell-integration-path fish)
end

# Carapace
# https://carapace-sh.github.io/carapace-bin/setup.html#fish
if command-exists -- carapace
	carapace _carapace fish | source
end
