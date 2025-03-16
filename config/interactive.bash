#!/usr/bin/env bash
# shellcheck disable=SC2034
# Used by `interactive.sh`
# Do whatever you want in this file

# Enable fancier bash options, sorted by rarest last
shopt -s nullglob extglob globstar &>/dev/null || :

# Inherited into `theme.sh` to load the desired theme, use `dorothy theme` to (re)configure this
# export DOROTHY_THEME=''
