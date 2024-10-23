#!/usr/bin/env nu

# Load the configuration for interactive shells
# We load all in nu, as there is no way to just load one, as they must all exist, and existence has been how we determine what to load
source ../state/config.local/interactive.nu
source ../state/config/interactive.nu
source ../config/interactive.nu

# Continue with the shell extras
source ./history.nu
source ./theme.nu
source ./ssh.nu
source ./autocomplete.nu

# Shoutouts
command-exists -- 'shuf' | complete; if $env.LAST_EXIT_CODE == 0 {
	shuf -n1 $'($env.DOROTHY)/sources/shoutouts.txt'
}
dorothy-warnings
