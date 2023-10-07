#!/usr/bin/env elvish

# @todo: couldn't get this going

# for scripts and sources to load a configuration file
# load_dorothy_config ...<filename>
fn load_dorothy_config {|@filenames|
	var dorothy_config_loaded = $false

	# for each filename, load a single config file
	for filename filenames {
		if ?(test -f $E:DOROTHY'/user/config.local/'$filename) {
			# load user/config.local/*
			eval (cat $E:DOROTHY'/user/config.local/'$filename | slurp)
			set dorothy_config_loaded = $true
		} elif ?(test -f $E:DOROTHY'/user/config/'$filename) {
			# otherwise load user/config/*
			eval (cat $E:DOROTHY'/user/config/'$filename | slurp)
			set dorothy_config_loaded = $true
		} elif ?(test -f $E:DOROTHY'/config/'$filename) {
			# otherwise load default configuration
			eval (cat $E:DOROTHY'/config/'$filename | slurp)
			set dorothy_config_loaded = $true
		}
		# otherwise try next filename
	}

	# if nothing was loaded, then fail
	if (eq dorothy_config_loaded $false) {
		echo-style --error="Missing the configuration file: $argv" >/dev/stderr
		return 2  # No such file or directory
	}
}
