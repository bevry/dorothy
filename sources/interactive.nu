#!/usr/bin/env nu

source ./config.nu

if ( echo $'($env.DOROTHY)/user/config.local/interactive.nu' | path exists ) {
	source ../user/config.local/interactive.nu
} else if ( echo $'($env.DOROTHY)/user/config/interactive.nu' | path exists ) {
	source ../user/config/interactive.nu
} else if ( echo $'($env.DOROTHY)/config/interactive.nu' | path exists ) {
	source ../config/interactive.nu
}

source ./history.nu
source ./theme.nu
# source ./ssh.nu
# source ./autocomplete.nu
