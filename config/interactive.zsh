#!/usr/bin/env bash
# do whatever you want in this file:
# shellcheck disable=SC2034

# Used by `interactive.sh`

# Load oh-my-zsh if it exists on the system
if [[ -d "$HOME/.oh-my-zsh" ]]; then
	export DISABLE_UPDATE_PROMPT=true
	export ZSH="$HOME/.oh-my-zsh"
	# export ZSH_THEME='avit'
	export plugins=(terminalapp osx autojump bower brew brew-cask cake coffee cp docker gem git heroku node npm nvm python ruby)
	if [[ -f "$ZSH/oh-my-zsh.sh" ]]; then
		source "$ZSH/oh-my-zsh.sh"
	fi
fi
