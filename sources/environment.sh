#!/usr/bin/env sh

eval "$(env -i DOROTHY="$DOROTHY" DOROTHY_USER_HOME="$DOROTHY_USER_HOME" USER="$USER" HOME="$HOME" "$DOROTHY/commands/setup-environment-commands")"
