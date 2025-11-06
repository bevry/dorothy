#!/usr/bin/env bash
# shellcheck disable=SC2034
# Used by `setup-environment-commands`
# Place all export declarations `export VAR` at the start, before their definitions/assignments `VAR=...`, otherwise no bash v3 compatibility

# To enable caching, uncomment the following line:
# __cache || exit

# export NVM_DIR HOMEBREW_ARCH PYENV_VERSION HOMEBREW_RUBY_VERSION # ...

# NVM_DIR="$HOME/.nvm"
# ^ Used by: setup-environment-commands, setup-node

# HOMEBREW_ARCH='x86_64' # 'arm64e'
# ^ If you are on Apple Silicon, use 'x86_64' to have Homebrew installed and run as if it were on Apple Intel.
# ^ Used by: setup-environment-commands, setup-mac-brew, brew

# PYENV_VERSION='3.10.0'  # only accepts full versions
# ^ Not currently used by: setup-environment-commands, setup-python

# HOMEBREW_RUBY_VERSION='default'
# ^ Used by: setup-environment-commands, setup-ruby
