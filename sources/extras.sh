#!/usr/bin/env sh

# NVM is an extra for shell, as for bash it cannot be
# however that is fine, as we probably aren't using fish for commands
# so the speed of fish doesn't matter
. "$BDIR/sources/nvm.bash"

# Extras
. "$BDIR/sources/edit.sh"
. "$BDIR/sources/aliases.sh"
. "$BDIR/sources/functions.sh"
. "$BDIR/sources/ssh.sh"
if is-string "${ZSH_VERSION-}"; then
	. "$BDIR/sources/zsh.zsh"
	. "$BDIR/sources/azure.zsh"
else
	. "$BDIR/sources/azure.bash"
fi
. "$BDIR/sources/gcloud.sh"
. "$BDIR/sources/completions.sh"
. "$BDIR/sources/theme.sh"
