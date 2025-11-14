#!/usr/bin/env bash
# shellcheck disable=SC2034
# Used by `setup-environment-commands`
# Place all export declarations `export VAR` at the start, before their definitions/assignments `VAR=...`, otherwise no bash v3 compatibility

# To enable caching, uncomment the following line:
# __cache || exit $?

# export NVM_DIR HOMEBREW_RUBY_VERSION # ...

# NVM_DIR="$HOME/.nvm"
# ^ Used by: setup-environment-commands, setup-node

# HOMEBREW_RUBY_VERSION='default'
# ^ Used by: setup-environment-commands, setup-ruby
