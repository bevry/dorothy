#!/usr/bin/env fish

# Source our ability to load configuration files
source "$DOROTHY/sources/config.fish"

# Load the configuration for interactive shells
load_dorothy_config --first --optional -- 'interactive.fish' 'interactive.sh'

# Continue with the shell extras
source "$DOROTHY/sources/history.fish"
source "$DOROTHY/sources/theme.fish"
source "$DOROTHY/sources/ssh.fish"
source "$DOROTHY/sources/autocomplete.fish"

# Shoutouts
if command-exists -- shuf
	shuf -n1 "$DOROTHY/sources/shoutouts.txt"
end
dorothy-warnings warn
