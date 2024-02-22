#!/usr/bin/env bash

source "$DOROTHY/themes/oz"
PROMPT_COMMAND='oztheme bash $?'
# ^ don't export PROMPT_COMMAND, as it will be inherited in subshells
# so: `select-shell bash`
# then open a new terminal
# then enter `bash -i`
# will error with `bash: oztheme: command not found`
