#!/usr/bin/env bash
# do not use `export` keyword in this file:
# shellcheck disable=SC2034

# APK
# Used by `setup-util-apk`
# APK_INSTALL=()

# Apt / apt-get
# Used by `setup-util-apt`
# APT_UNINSTALL=()
# APT_INSTALL=()

# Snap
# Used by `setup-util-snap`
# SNAP_INSTALL=()

# macOS apps / mas / https://github.com/mas-cli/mas
# Used by `setup-mac-apps`
# You can use `mas list` and `mas search` to find apps
# MAS_INSTALL=() # tupe array of id, label

# Homebrew / brew / https://brew.sh
# Used by `setup-mac-brew`
# You can use `setup-mac-brew --configure` to configure some of these.
# HOMEBREW_TAPS=()
# HOMEBREW_FORMULAS=()
# HOMEBREW_SLOW_FORMULAS=()
# HOMEBREW_CASKS=()
HOMEBREW_FONTS=(
	'font-cantarell'
	'font-cascadia-code'
	'font-fira-code'
	'font-fira-code-nerd-font'
	'font-fira-mono'
	'font-fira-mono-nerd-font'
	'font-hack' # many editors require this
	'font-hasklig'
	'font-ibm-plex' # many editors require this
	'font-inconsolata-go-nerd-font'
	'font-inter' # many apps require this
	'font-jetbrains-mono'
	'font-jetbrains-mono-nerd-font'
	'font-lato'
	'font-maven-pro'
	'font-monoid'
	'font-montserrat'
	'font-open-sans'
	'font-oxygen'
	'font-oxygen-mono'
	'font-roboto'
	'font-roboto-mono'
	'font-source-code-pro' # many editors require this
	'font-ubuntu'
)
# HOMEBREW_UNINSTALL=()        # for casks and formulas
# HOMEBREW_ENCODING_INSTALL='' # '', 'yes', 'no'

# Golang / go
# Used by `setup-go`
# GO_LINTING_INSTALL='' # '', 'yes', 'no'
# GO_INSTALL=()

# Node.js
# Used by `setup-node`
# NPM_INSTALL=()

# Python
# Used by `setup-python`
# PYTHON_INSTALL=()
# PIP_INSTALL=()
# PYTHON2_PIP_INSTALL=()
# PYTHON3_PIP_INSTALL=()
# PIPX_INSTALL=()

# Ruby
# Used by `setup-ruby`
# GEM_INSTALL=()

# Rust / Cargo / Crates.io
# Used by `setup-rust`
# CARGO_INSTALL=()

# Utilities to install, these are the [setup-util-*] scripts
# Used by `setup-utils`
# You can use `setup-utils --configure` to configure these.
SETUP_UTILS=(
	'nano'
	'neovim'
	'vim'
)
