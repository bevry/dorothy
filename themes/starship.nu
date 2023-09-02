#!/usr/bin/env nu

# ensure starship
command-exists 'starship' | complete
if $env.LAST_EXIT_CODE == 0 {
	setup-util-starship --quiet
}

# ensure starship nushell <-- no point, as nushell requires everything to already be as intended at compile-time
# if ( ~/.local/state/starship/init.nu | path exists ) == false {
# 	mkdir ~/.local/state/starship
# 	starship init nu | save ~/.local/state/starship/init.nu
# fi

# load starship nushell
use ~/.local/state/starship/init.nu
