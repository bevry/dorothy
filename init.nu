#!/usr/bin/env nu

$env.DOROTHY = $'($env.HOME)/.local/share/dorothy'

$env.PATH = ($env.PATH | split row (char esep) | prepend $'($env.HOME)/.local/share/dorothy/commands')

if $nu.is-login {
	source ./sources/login.nu
	source ./sources/interactive.nu
}
