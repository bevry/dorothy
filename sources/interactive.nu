#!/usr/bin/env nu

# Load the configuration for interactive shells
# We load all in nu, as there is no way to just load one, as they must all exist, and existence has been how we determine what to load
source ../user/config.local/interactive.nu
source ../user/config/interactive.nu
source ../config/interactive.nu

# Continue with the shell extras
source ./history.nu
source ./theme.nu
source ./ssh.nu
source ./autocomplete.nu
