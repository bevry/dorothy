#!/usr/bin/env bash

# https://www.gnu.org/software/bash/manual/bash.html#Shell-Parameter-Expansion

if [[ "$BASH_VERSION" = "4."* || "$BASH_VERSION" = "5."* ]]; then
	# test variable is defined
	function testv() {
		test -v "$1"
	}
	# upper case first letter
	function ucf() {
		echo "${1@u}"
	}
	# lower case all
	function lc() {
		echo "${1@L}"
	}
else
	# test variable is defined
	function testv() {
		test -n "${!1-}"
	}
	# upper case first letter
	function ucf() {
		echo "$1" # not important, implement later
	}
	# lower case all
	function lc() {
		echo "$1" # not important, implement later
	}
fi

# does it have elements, as for loop of an empty array in bash v3 breaks
# function full() {
# 	local a="${!a-}"
# 	test "${#a[@]}" -ne 0
# }
