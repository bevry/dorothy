#!/usr/bin/env sh

# Extras
. "$HOME/.scripts/sources/aliases.sh"
. "$HOME/.scripts/sources/functions.sh"
. "$HOME/.scripts/sources/ssh.sh"
if is-string "${ZSH_VERSION:-}"; then
	. "$HOME/.scripts/sources/zsh.zsh"
	. "$HOME/.scripts/sources/azure.zsh"
else
	. "$HOME/.scripts/sources/azure.bash"
fi
. "$HOME/.scripts/sources/gcloud.sh"
. "$HOME/.scripts/sources/completions.sh"
. "$HOME/.scripts/sources/theme.sh"
