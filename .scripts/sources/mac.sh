#!/usr/bin/env sh

# https://github.com/caskroom/homebrew-cask/blob/master/USAGE.md#options
# uses env to make sure that HOMEBREW_CASK_OPTS is set regardless of shell
# as doing a set via fish does not expose it in brew which is bash
alias brew="env HOMEBREW_CASK_OPTS='--appdir=$HOME/Applications --caskroom=$HOME/.cache/Caskroom' brew"

# Mac specific aliases
alias md5sum='md5 -r'
alias edithosts='sudo edit /etc/hosts'
alias lock='/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend'

# Setup
alias install='setup-mac-install'
alias update='setup-mac-update'
