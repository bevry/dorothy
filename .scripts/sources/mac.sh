#!/usr/bin/env sh

# https://github.com/caskroom/homebrew-cask/blob/master/USAGE.md#options
# uses env to make sure that HOMEBREW_CASK_OPTS is set regardless of shell
# as doing a set via fish does not expose it in brew which is bash
export BREW_APPDIR="$HOME/Applications"
export BREW_CASKROOM="$HOME/.cache/Caskroom"
alias brew="env HOMEBREW_CASK_OPTS='--appdir=$BREW_APPDIR --caskroom=$BREW_CASKROOM' brew"

# Mac specific aliases
alias md5sum='md5 -r'
alias edithosts='sudo edit /etc/hosts'
alias lock='/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend'

# Setup
alias install='setup-mac-install'
alias update='setup-mac-update'
