#!/usr/bin/env zsh

# Oh my zsh
if is-dir "$HOME/.oh-my-zsh"; then
	export DISABLE_UPDATE_PROMPT=true
	export ZSH="$HOME/.oh-my-zsh"
	# export ZSH_THEME="avit"
	export plugins=(terminalapp osx autojump bower brew brew-cask cake coffee cp docker gem git heroku node npm nvm python ruby)
	source "$ZSH/oh-my-zsh.sh"
fi