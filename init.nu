#!/usr/bin/env nu

$env.DOROTHY = $'($env.HOME)/.local/share/dorothy'

$env.PATH = ($env.PATH | split row (char esep) | prepend $'($env.HOME)/.local/share/dorothy/commands')

if $nu.is-login {
	source ./sources/environment.nu
	if $nu.is-interactive {
		source ./sources/interactive.nu
	}
}
