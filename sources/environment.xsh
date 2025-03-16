#!/usr/bin/env xonsh

# set the environment variables
evalx(compilex($(@($DOROTHY + '/commands/setup-environment-commands') --shell=xonsh)))
# @todo: someone experienced with xonsh should send a PR to add detection (like fish and bash have) on failures of the above command
