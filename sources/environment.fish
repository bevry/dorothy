#!/usr/bin/env fish

# set the environment variables
eval ("$DOROTHY/commands/setup-environment-commands" fish || begin
	echo "DOROTHY FAILED TO SETUP ENVIRONMENT, RUN THIS TO DEBUG: bash -x '$DOROTHY/commands/setup-environment-commands' fish" >/dev/stderr
	return 1
end)
