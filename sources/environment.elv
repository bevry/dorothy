#!/usr/bin/env elvish

# set the environment variables
eval ($E:DOROTHY'/commands/setup-environment-commands' --shell=elvish | slurp)
# @todo: someone experienced with elvish should send a PR to add detection (like fish and bash have) on failures of the above command
