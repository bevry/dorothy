#!/usr/bin/env fish

# create the environment evaluation
set DOROTHY_ENVIRONMENT_EVAL ( "$DOROTHY/commands/setup-environment-commands" --shell=fish )
if test $status -ne 0
    printf '%s\n' \
        "FAILED TO CREATE DOROTHY ENVIRONMENT SETUP WITH EXIT STATUS $status, RUN THESE TO DEBUG:" \
        "'$DOROTHY/commands/setup-environment-commands' --debug --shell='$ACTIVE_POSIX_SHELL'" \
        "bash -x '$DOROTHY/commands/setup-environment-commands' --shell='$ACTIVE_POSIX_SHELL'" >&2
    if test -n "$CI"
        exit 6 # ENXIO 6 Device not configured
    end
end
# evaluate the environment setup
if test -n "$DOROTHY_ENVIRONMENT_EVAL"
    eval $DOROTHY_ENVIRONMENT_EVAL ; or begin
        printf '%s\n' \
            "FAILED TO EVALUATE DOROTHY ENVIRONMENT SETUP WITH EXIT STATUS $status, SETUP IS BELOW:" >&2
        printf '%s' "$DOROTHY_ENVIRONMENT_EVAL" | cat -vbn >&2
		printf '\n' >&2
        if test -n "$CI"
            exit 6 # ENXIO 6 Device not configured
        end
    end
end
