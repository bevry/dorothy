#!/usr/bin/env sh

# NVM is an extra for shell, as for bash it cannot be
# however that is fine, as we probably aren't using fish for commands
# so the speed of fish doesn't matter
. "$DOROTHY/sources/nvm.bash"

# Additional extras for an interactive shell
. "$DOROTHY/sources/edit.sh"
. "$DOROTHY/sources/aliases.sh"
. "$DOROTHY/sources/functions.sh"
if is-string "${ZSH_VERSION-}"; then
	. "$DOROTHY/sources/zsh.zsh"
	. "$DOROTHY/sources/azure.zsh"
else
	. "$DOROTHY/sources/azure.bash"
fi
. "$DOROTHY/sources/gcloud.sh"
. "$DOROTHY/sources/completions.sh"
. "$DOROTHY/sources/theme.sh"
. "$DOROTHY/sources/ssh.sh"
