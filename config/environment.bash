#!/usr/bin/env bash
# shellcheck disable=SC2034
# place all `export` keyword declarations at the start for bash v3 compatibility
export NVM_DIR HOMEBREW_ARCH PYENV_VERSION RUBY_VERSION # ...

# NVM_DIR="$HOME/.nvm"
# ^ used by: setup-environment-commands, setup-node

# HOMEBREW_ARCH='x86_64' # 'arm64e'
# ^ choose your architecture for apple silicon
# ^ used by: setup-environment-commands, setup-mac-brew, brew

# PYENV_VERSION='3.10.0'  # only accepts full versions
# ^ not currently used by: setup-environment-commands, setup-python

# RUBY_VERSION='default'
# ^ used by: setup-environment-commands, setup-ruby
