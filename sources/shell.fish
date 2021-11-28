#!/usr/bin/env fish

# export the active shell as the active login shell
set --export ACTIVE_LOGIN_SHELL fish

# additional extras for an interactive shell
source "$DOROTHY/sources/config.fish"
# load each filename
# passes if one or more were loaded
# fails if none were loaded (all were missing)
load_dorothy_config 'shell.fish' 'shell.sh'
source "$DOROTHY/sources/edit.fish"
source "$DOROTHY/sources/history.fish"
source "$DOROTHY/sources/theme.fish"
source "$DOROTHY/sources/ssh.fish"
