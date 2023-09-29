#!/usr/bin/env nu

# Source our ability to load configuration files
source ./config.nu

# Load the configuration for interactive shells
source ../user/config.local/interactive.nu
source ../user/config/interactive.nu
source ../config/interactive.nu

# Continue with the shell extras
source ./history.nu
source ./theme.nu
source ./ssh.nu
source ./autocomplete.nu
