#!/usr/bin/env sh
# Imports ACTIVE_POSIX_SHELL

# Use `command -v` instead of `command -v` for POSIX

# =====================================
# Visuals, at the start for perception of speed

# macOS workarounds
if [ "$ACTIVE_POSIX_SHELL" = 'bash' ]; then
	# Silence macOS deprecation warning on bash v3, as Dorothy handles bash upgrades
	export BASH_SILENCE_DEPRECATION_WARNING=1

	# Fix `HISTTIMEFORMAT: unbound variable` on fresh macOS
	export HISTTIMEFORMAT='%F %T '
fi

# Shoutouts
if command -v shuf >/dev/null 2>&1; then
	shuf -n1 "$DOROTHY/sources/shoutouts.txt"
fi
dorothy-warnings warn

# =====================================
# Configuration

# Source our ability to load configuration files
. "$DOROTHY/sources/config.sh"

# Load the configuration for interactive shells
if [ "$ACTIVE_POSIX_SHELL" = 'sh' ]; then
	load_dorothy_config --first --optional -- 'interactive.sh'
else
	load_dorothy_config --first --optional -- "interactive.$ACTIVE_POSIX_SHELL" 'interactive.sh'
fi

# =====================================
# NVM, might be used by theme, so load it here

if [ "$ACTIVE_POSIX_SHELL" != 'ksh' ]; then # nvm is not compatible with ksh
	nvm() {                                    # lazy-load, as nvm is really slow to load
		. "$DOROTHY/sources/nvm.sh" || return $?
		nvm "$@"
	}
fi

# =====================================
# Theme

. "$DOROTHY/sources/theme.sh"

# =====================================
# SSH

# we are in posix, so can't use bash's &> shortcut

# silent is done to prevent rsync ssh failures
# https://fixyacloud.wordpress.com/2020/01/26/protocol-version-mismatch-is-your-shell-clean/

# fix gpg errors, caused by lack of authentication of gpg key, caused by pinentry not being aware of tty
#   error: gpg failed to sign the data
#   fatal: failed to write commit object
# you can test it is working via:
#   setup-git
#   printf '%s\n' 'test' | gpg --clearsign
# if you are still getting those errors, check via `gpg-helper list` that your key has not expired
# if it has, then run `gpg-helper extend`
if command -v gpg >/dev/null 2>&1; then
	export GPG_TTY
	GPG_TTY="$(tty)"
fi

# only work on environments that have an ssh-agent
if command -v ssh-agent >/dev/null 2>&1; then
	# ensure ask pass is discoverable by the agent
	if [ -z "${SSH_ASKPASS-}" ] && command -v ssh-askpass >/dev/null 2>&1; then
		export SSH_ASKPASS
		SSH_ASKPASS="$(command -v ssh-askpass)"
	fi
	# setting `SSH_ASKPASS_REQUIRE` to `prefer` voids TTY responses

	# check if the agent is still running
	if [ -n "${SSH_AGENT_PID-}" ] && ! kill -0 "$SSH_AGENT_PID" >/dev/null 2>&1; then
		SSH_AGENT_PID=''
	fi

	# (re)start the ssh agent if the inherited one crashed
	if [ -z "${SSH_AUTH_SOCK-}" ] || [ -z "${SSH_AGENT_PID-}" ]; then
		eval "$(ssh-agent -s)" >/dev/null 2>&1
	fi

	# shutdown the ssh-agent when our shell exits
	on_ssh_finish() {
		# killall ssh-agent
		eval "$(ssh-agent -k)" >/dev/null 2>&1
	}
	trap on_ssh_finish EXIT
fi

# =====================================
# Autocomplete

# Visual Studio Code Terminal Shell Integration
# https://code.visualstudio.com/docs/terminal/shell-integration#_manual-installation
if [ "${TERM_PROGRAM-}" = 'vscode' ] && command -v code >/dev/null 2>&1; then
	. "$(code --locate-shell-integration-path "$ACTIVE_POSIX_SHELL")"
fi

if [ "$ACTIVE_POSIX_SHELL" = 'bash' ]; then
	# Enable Completions
	# trunk-ignore(shellcheck/SC3044)
	shopt -s progcomp

	# Carapace
	# https://carapace-sh.github.io/carapace-bin/setup.html#bash
	if command -v carapace >/dev/null 2>&1; then
		eval "$(carapace _carapace bash)"
	fi

elif [ "$ACTIVE_POSIX_SHELL" = 'zsh' ]; then
	# Enable Completions
	autoload -Uz compinit
	compinit

	# Carapace
	# https://carapace-sh.github.io/carapace-bin/setup.html#zsh
	if command -v carapace >/dev/null 2>&1; then
		# trunk-ignore(shellcheck/SC3003)
		zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
		eval "$(carapace _carapace zsh)"
	fi
fi

# =====================================
# Terminals

# Ghostty, it is here, because the title is better here, could be an issue with `oz`
# https://ghostty.org/docs/features/shell-integration
# https://github.com/ghostty-org/ghostty/tree/main/src/shell-integration
if [ -n "${GHOSTTY_RESOURCES_DIR-}" ]; then
	if [ "$ACTIVE_POSIX_SHELL" = 'bash' ]; then
		. "$GHOSTTY_RESOURCES_DIR/shell-integration/bash/ghostty.bash"
	elif [ "$ACTIVE_POSIX_SHELL" = 'zsh' ]; then
		. "$GHOSTTY_RESOURCES_DIR"/shell-integration/zsh/ghostty-integration
	fi
fi
