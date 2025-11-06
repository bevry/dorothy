#!/usr/bin/env bash
# shellcheck disable=SC2034
# Used by `interactive.sh`
# Do whatever you want in this file

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

# Inherited into `theme.zsh` to load the desired theme, use `dorothy theme` to (re)configure this
# export DOROTHY_THEME=''
