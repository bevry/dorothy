#!/usr/bin/env sh

# if you don't use a custom configuration for a particular shell, this file is loaded
# it must be compatible with all the shells you don't have a custom configuration for

export THEME='baltheme'
export SHELLCHECK_OPTS="-e SC2096 -e SC1090 -e SC1091 -e SC1071"
export USER_SHELL="fish"
export GIT_PROTOCOL="ssh"
export GITHUB_API="https://bevry.me/api/github"

alias go-open="open -a /Applications/GoLand.app ."