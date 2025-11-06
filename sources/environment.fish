#!/usr/bin/env fish

# set the environment variables
eval ("$DOROTHY/commands/setup-environment-commands" --shell=fish || begin
	printf '%s\n' "DOROTHY FAILED TO SETUP ENVIRONMENT, RUN THIS TO DEBUG: bash -x '$DOROTHY/commands/setup-environment-commands' fish" >&2
	return 1
end)
