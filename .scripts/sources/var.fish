#!/usr/bin/env fish

function var_set
	set -U $argv[1] "$argv[2]"
end

function var_add
	set exists "no"
	for line in $$argv[1]
		if test "$line" = "$argv[2]"
			set exists "yes"
			break
		end
	end
	if test "$exists" = "no"
		set -x $argv[1] "$argv[2]" $$argv[1]
	end
end
