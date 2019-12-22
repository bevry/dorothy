#!/usr/bin/env sh

export THEME='baltheme'
export SHELLCHECK_OPTS="-e SC2096 -e SC1090 -e SC1091 -e SC1071"
export USER_SHELL="fish"
export GIT_PROTOCOL="ssh"
export KRYPTON_GPG="no"
export GITHUB_API="https://bevry.me/api/github"

alias go-open="open -a /Applications/GoLand.app ."
alias nrp="ghauth -- npm run our:release:prepare"
alias nr="ghauth -- npm run our:release"
alias np='nr'
alias npp='nrp'
alias nt='npm run our:compile && npm test'