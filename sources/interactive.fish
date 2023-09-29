#!/usr/bin/env fish

# Source our ability to load configuration files
source "$DOROTHY/sources/config.fish"

# Load the configuration for interactive shells
# load each filename
# passes if one or more were loaded
# fails if none were loaded (all were missing)
load_dorothy_config 'interactive.fish' 'interactive.sh'

# Continue with the shell extras
source "$DOROTHY/sources/history.fish"
source "$DOROTHY/sources/theme.fish"
source "$DOROTHY/sources/ssh.fish"
source "$DOROTHY/sources/autocomplete.fish"
