#!/usr/bin/env bash
# shellcheck disable=SC2034
# do not use `export` keyword in this file

# apk
APK_INSTALL=()

# apt
APT_REMOVE=()
APT_ADD=()

# snap
SNAP_INSTALL=()

# brew
HOMEBREW_TAPS=()
HOMEBREW_INSTALL=()
HOMEBREW_INSTALL_SLOW=()
HOMEBREW_INSTALL_CASK=()
HOMEBREW_INSTALL_ENCODING='' # yes/no
HOMEBREW_UNINSTALL=()

# go
GO_INSTALL=()

# node
# CLEAN_NVM='yes' # yes/no
NODE_INSTALL=()

# python
PYTHON_INSTALL=()
PIP_INSTALL=()
PYTHON2_PIP_INSTALL=()
PYTHON3_PIP_INSTALL=()
PIPX_INSTALL=()

# ruby
RUBY_INSTALL=()

# cargo
RUST_INSTALL=()

# setup-util-*
SETUP_UTILS=()
