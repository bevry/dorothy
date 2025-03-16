#!/usr/bin/env sh

# silence macos deprecation warning on bash v3
# as dorothy does its own upgrade technique
export BASH_SILENCE_DEPRECATION_WARNING=1

# fix `HISTTIMEFORMAT: unbound variable` on fresh macOS
export HISTTIMEFORMAT='%F %T '

# essential
. "$DOROTHY/sources/environment.sh"
