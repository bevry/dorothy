#!/usr/bin/env fish

# Microsoft Azure
if command-exists azure
	azure --completion-fish | source
end

# 1Password
# https://developer.1password.com/docs/cli/get-started#shell-completion
if command-exists op
	op completion fish | source
end

# Visual Studio Code Terminal Shell Integration
# https://code.visualstudio.com/docs/terminal/shell-integration#_manual-installation
if test "$TERM_PROGRAM" = "vscode"
	. (code --locate-shell-integration-path "$ACTIVE_SHELL")
end
