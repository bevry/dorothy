#!/usr/bin/env bash

if [[ "$BASH_VERSION" = "4."* || "$BASH_VERSION" = "5."* ]]; then
	function testv() {
		test -v "$1"
	}
	function ucf() {
		echo "${1@u}"
	}
else
	function testv() {
		test -n "${!1-}"
	}
	function ucf() {
		echo "${!1}" # not important, implement later
	}
fi

# does it have elements, as for loop of an empty array in bash v3 breaks
# function full() {
# 	local a="${!a-}"
# 	test "${#a[@]}" -ne 0
# }
