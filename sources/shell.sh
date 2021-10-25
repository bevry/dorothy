#!/usr/bin/env sh

# scripts in here are especially unnecessary for commands, and are often slow
# they are generally only useful for user interactive environments
# if a command does need one of these, then the command can source it directly

# additional extras for an interactive shell
. "$DOROTHY/sources/config.sh"
load_dorothy_config 'shell.sh'
. "$DOROTHY/sources/nvm.sh"
. "$DOROTHY/sources/edit.sh"
. "$DOROTHY/sources/history.sh"
if test -n "${ZSH_VERSION-}"; then
	. "$DOROTHY/sources/zsh.zsh"
	. "$DOROTHY/sources/azure.zsh"
else
	. "$DOROTHY/sources/azure.bash"
fi
. "$DOROTHY/sources/gcloud.sh"
. "$DOROTHY/sources/completions.sh"
. "$DOROTHY/sources/theme.sh"
. "$DOROTHY/sources/ssh.sh"
