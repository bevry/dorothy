#!/usr/bin/env bash

# dorothy ecosystem
# export GIT_PROTOCOL="ssh"
# export GIT_DEFAULT_BRANCH="main"
export SECRETS="$DOROTHY/user/secrets"
export DOROTHY_THEME='oz'

# uncomment the line the below to load a env.sh file where you can put your secret exports
# however, make sure that exists: `touch "$DOROTHY/user/env.sh"`
# and is inside your `.gitignore` file: `edit "$DOROTHY/user/.gitignore"`
# . "$DOROTHY/user/env.sh"
