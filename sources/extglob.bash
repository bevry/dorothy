#!/usr/bin/env bash

# bash v5 extglob If set, the extended pattern matching features described above (see Pattern Matching) are enabled.
shopt -s extglob || {
	echo-style --error="Missing extglob support:"
	source "$DOROTHY/sources/bash.bash"
	require_latest_bash
}
