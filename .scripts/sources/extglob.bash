#!/usr/bin/env bash

if [[ "$BASH_VERSION" = "4."* || "$BASH_VERSION" = "5."* ]]; then
	shopt -s extglob
else
	stderr echo 'bash version is too old'
	exit 1
fi