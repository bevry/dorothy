#!/usr/bin/env sh

# Extras
. "$BDIR/sources/aliases.sh"
. "$BDIR/sources/functions.sh"
. "$BDIR/sources/ssh.sh"
if is-string "${ZSH_VERSION:-}"; then
	. "$BDIR/sources/zsh.zsh"
	. "$BDIR/sources/azure.zsh"
else
	. "$BDIR/sources/azure.bash"
fi
. "$BDIR/sources/gcloud.sh"
. "$BDIR/sources/completions.sh"
. "$BDIR/sources/theme.sh"
