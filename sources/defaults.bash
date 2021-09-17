#!/usr/bin/env bash

# make sure when we use bash, we use globstar if it is supported
if [[ "$BASH_VERSION" = "4."* || "$BASH_VERSION" = "5."* ]]; then
	source "$DOROTHY/sources/globstar.bash"
fi

# inherit the cross-platform shell configuration
source "$DOROTHY/sources/defaults.sh"

# dns
export DNS_NOFAP=''
export DNS_SERVICE=''
export DNS_PROVIDER=''
export DNS_SERVERS=()
export DNS_IPV4SERVERS=()
export DNS_IPV6SERVERS=()

# our editors in order of preference
export TERMINAL_EDITORS=(
	vim # --noplugin -c "set nowrap"'
	micro
	nano
)
export GUI_EDITORS=(
	"code -w"
	"atom -w"
	"subl -w"
	gedit
)

# our shells in order of preference
# export USER_SHELLS=(
# 	fish
# 	zsh
# 	bash
# 	sh
#  dash
#  ash
#  tsch
# )

# what to install or remove
export APK_INSTALL=()
export APT_REMOVE=()
export APT_ADD=()
export SNAP_INSTALL=()
export HOMEBREW_INSTALL=()
export HOMEBREW_INSTALL_SLOW=()
export HOMEBREW_INSTALL_CASK=()
export GO_INSTALL=()
export NODE_INSTALL=()
export PYTHON_INSTALL=()
# export RUBY_VERSION='system'
export RUBY_INSTALL=()
export RUST_INSTALL=()
export SETUP_UTILS=()

# choose your architecture for apple silicon
# export HOMEBREW_ARCH='x86_64' # 'arm64e'
