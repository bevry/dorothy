#!/usr/bin/env bash
# shellcheck disable=SC2034
# Do not use `export` keyword in this file

# Login Shells
# Used by `setup-shell`
# List with your most preferred login shell first. The first installed preference will be used as your login shell.
DOROTHY_LOGIN_SHELLS=(
	# officially supported shells
	bash # bourne again shell
	dash # debian almquist shell
	fish # fish shell
	nu   # nushell
	zsh  # Z shell
	# officially supported shells (alpha/beta quality integrations)
	elvish # elvish shell
	ksh    # korn shell
	xonsh  # python-powered shell
	# potentially supported shells
	ash  # almquist shell
	hush # hush, an independent implementation of a Bourne shell for BusyBox
	sh   # the operating-system symlinks this to any POSIX compliant shell
)

# APK
# Used by `setup-linux`
# APK_INSTALL=()

# Apt / apt-get
# Used by `setup-linux`
# APT_UNINSTALL=()
# APT_INSTALL=()

# AUR / pamac / pacman / yay / paru / pakku / aurutils
# Used by `setup-linux`
# AUR_INSTALL=()

# Flatpak
# Used by `setup-linux`
# FLATPAK_INSTALL=()

# RPM / dnf / yum
# Used by `setup-linux`
# RPM_INSTALL=()

# Snap
# Used by `setup-linux`
# SNAP_INSTALL=()

# Zypper
# Used by `setup-linux`
# ZYPPER_INSTALL=()

# macOS App Store / mas / https://github.com/mas-cli/mas
# Used by `setup-mac-appstore`
# You can use `mas list` and `mas search` to find apps
# MAS_INSTALL=() # tuple array of id, label
# MAS_UPGRADE='no'

# Homebrew / brew / https://brew.sh
# Used by `setup-mac-brew`
# You can use `setup-mac-brew --configure` to configure some of these.
# HOMEBREW_UNTAPS=()
# HOMEBREW_TAPS=()
# HOMEBREW_FORMULAS=()
# HOMEBREW_SLOW_FORMULAS=()
# HOMEBREW_CASKS=()
HOMEBREW_FONTS=(
	'font-cantarell'
	'font-cascadia-code'
	'font-hack' # many editors require this font, @todo make `setup-util-hack`
	'font-hasklig'
	'font-inconsolata-go-nerd-font'
	'font-inter' # many apps require this font, @todo make `setup-util-inter`
	'font-jetbrains-mono'
	'font-jetbrains-mono-nerd-font'
	'font-lato'
	'font-maven-pro'
	'font-montserrat'
	'font-open-sans'
	'font-oxygen'
	'font-oxygen-mono'
	'font-roboto'
	'font-roboto-mono'
	'font-ubuntu'
)
# HOMEBREW_UNINSTALL=() # for casks and formulas
# HOMEBREW_ENCODING_INSTALL='' # '', 'yes', 'no'
# HOMEBREW_ENCODING_REINSTALL='' # '', 'yes', 'no'

# Golang / go
# Used by `setup-go`
# GO_LINTING_INSTALL='' # '', 'yes', 'no'
# GO_INSTALL=()

# Node.js
# Used by `setup-node`
# NPM_INSTALL=()
# NODE_VERSIONS=()

# Python
# Used by `setup-python`
# PYTHON_INSTALL=()
# UV_INSTALL=()

# Ruby
# Used by `setup-ruby`
# GEM_INSTALL=()

# Rust / Cargo / Crates.io
# Used by `setup-rust`
# CARGO_INSTALL=()

# Utilities to install, these are the `setup-util-*` scripts
# Used by `setup-utils`
# You can use `setup-utils --configure` to configure these.
SETUP_UTILS=(
	'fira-code'
	'ibm-plex' # many editors require this font
	'monoid'
	'nano'
	'source-code-pro' # many editors require this font
	'vim'
)
