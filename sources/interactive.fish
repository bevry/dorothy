#!/usr/bin/env fish

# source our ability to load configuration files
source "$DOROTHY/sources/config.fish"

# load each filename
# passes if one or more were loaded
# fails if none were loaded (all were missing)
load_dorothy_config 'interactive.fish' 'interactive.sh'
source "$DOROTHY/sources/history.fish"
source "$DOROTHY/sources/theme.fish"
source "$DOROTHY/sources/ssh.fish"
source "$DOROTHY/sources/autocomplete.fish"
