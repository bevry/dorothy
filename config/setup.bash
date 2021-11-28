#!/usr/bin/env bash
# shellcheck disable=SC2034
# do not use `export` keyword in this file

# APK
APK_INSTALL=()

# Apt / apt-get
APT_UNINSTALL=()
APT_INSTALL=()

# Snap
SNAP_INSTALL=()

# macOS apps / mas
# https://github.com/mas-cli/mas
# use `mas list` and `mas search` to find apps
MAS_INSTALL=() # tupe array of id, label

# Homebrew / brew
HOMEBREW_FORMULAS=()
HOMEBREW_SLOW_FORMULAS=()
HOMEBREW_ENCODING_INSTALL='' # yes/no
HOMEBREW_UNINSTALL=()
HOMEBREW_TAPS=()
HOMEBREW_CASKS=()
HOMEBREW_FONTS=(
	font-cantarell
	font-cascadia-code
	font-fira-code
	font-fira-code-nerd-font
	font-fira-mono
	font-fira-mono-nerd-font
	font-hack
	font-hasklig
	font-ibm-plex
	font-inconsolata-go-nerd-font
	font-inter
	font-jetbrains-mono
	font-jetbrains-mono-nerd-font
	font-lato
	font-maven-pro
	font-monoid
	font-montserrat
	font-open-sans
	font-oxygen
	font-oxygen-mono
	font-roboto
	font-roboto-mono
	font-source-code-pro
	font-ubuntu
)

# Golang / go
GO_INSTALL=()

# Node.js
# CLEAN_NVM='yes' # yes/no
NPM_INSTALL=()

# Python
PYTHON_INSTALL=()
PIP_INSTALL=()
PYTHON2_PIP_INSTALL=()
PYTHON3_PIP_INSTALL=()
PIPX_INSTALL=()

# Ruby
GEM_INSTALL=()

# Rust / Cargo / Crates.io
CARGO_INSTALL=()

# setup-util-*
SETUP_UTILS=()
