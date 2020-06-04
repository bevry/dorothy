#!/usr/bin/env bash
# this file is only loaded for bash, which is what most of the commands are coded in

# make sure when we use bash, we use globstar if it is supported
if [[ "$BASH_VERSION" = "4."* || "$BASH_VERSION" = "5."* ]]; then
	source "$BDIR/sources/globstar.bash"
fi

# load anything cross-shell useful from source.sh
source "$BDIR/users/$(whoami)/source.sh"

# our preferred editors
export TERMINAL_EDITORS=()
export GUI_EDITORS=()

# what to install or remove
export APK_INSTALL=()
export APT_REMOVE=()
export APT_ADD=()
export BREW_INSTALL=()
export BREW_INSTALL_SLOW=()
export BREW_INSTALL_CASK=()
export RUBY_INSTALL=()
export PYTHON_INSTALL=()
export NODE_INSTALL=()
export VSCODE_INSTALL=()
export ATOM_INSTALL=()