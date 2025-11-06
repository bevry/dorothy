#!/usr/bin/env elvish

# @todo: couldn't get this going

# for scripts and sources to load a configuration file
# load_dorothy_config [--first] [--silent] [--] ...<filename>
fn load_dorothy_config {
	# process arguments
	var only_first = $false
	var optional = $false
	while (count $args > 0) {
		if (eq $args[0] '--first') {
			set args = (drop $args 1)
			set only_first $true
		} elif (eq $args[0] '--optional') {
			set args = (drop $args 1)
			set optional $true
		} elif (eq $args[0] '--') {
			set args = (drop $args 1)
			break
		} else {
			break
		}
	}

	# for each filename, load a single config file
	var filename
	var loaded = $false
	for filename $args {
		if ?(test -f $E:DOROTHY'/user/config.local/'$filename) {
			# load user/config.local/*
			eval (cat $E:DOROTHY'/user/config.local/'$filename | slurp)
			set loaded = $true
		} elif ?(test -f $E:DOROTHY'/user/config/'$filename) {
			# load user/config/*
			eval (cat $E:DOROTHY'/user/config/'$filename | slurp)
			set loaded = $true
		}
		if (and (eq $only_first $true) (eq $loaded $true)) {
			break
		}
	}
	if (eq $loaded $false) {
		for filename $filenames {
			if ?(test -f $E:DOROTHY'/config/'$filename) {
				# load default configuration
				eval (cat $E:DOROTHY'/config/'$filename | slurp)
				set loaded = $true
			}
			if (and (eq $only_first $true) (eq $loaded $true)) {
				break
			}
		}
	}

	# if nothing was loaded, then fail
	if (eq loaded $false) {
		if (eq $optional $false) {
			echo-style --stderr --error="Missing the configuration file: $argv"
			return 2  # ENOENT 2 No such file or directory
		}
	}
	return 0
}
