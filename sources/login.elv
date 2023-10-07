#!/usr/bin/env elvish

# essential
eval (cat $E:DOROTHY'/sources/environment.elv' | slurp)

# clear the theme cache
get-terminal-theme --clear-cache
