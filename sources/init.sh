#!/usr/bin/env sh

# don't check mail
export MAILCHECK=0

# silence macos deprecation warning on bash v3
# as dorothy does its own upgrade technique
export BASH_SILENCE_DEPRECATION_WARNING=1

# essential
. "$DOROTHY/sources/environment.sh"
