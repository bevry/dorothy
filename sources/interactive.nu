#!/usr/bin/env nu

# Load the configuration for interactive shells
source ../state/interactive.nu

# Continue with the shell extras
source ./history.nu
source ./theme.nu
source ./ssh.nu
source ./autocomplete.nu

# Shoutouts
command-exists -- 'shuf' | complete; if $env.LAST_EXIT_CODE == 0 {
	shuf -n1 $'($env.DOROTHY)/sources/shoutouts.txt'
}
dorothy-warnings warn
