#!/bin/sh
export LOADEDDOTFILES="$LOADEDDOTFILES .usertheme.sh"

# Colours
if is_zsh; then
	autoload colors
	colors
	export RED="$fg[red]"
	export RED_BOLD="$fg_bold[RED]"
	export BLUE="$fg[blue]"
	export CYAN="$fg[cyan]"
	export PURPLE="$fg[purple]"
	export GREEN="$fg[green]"
	export YELLOW="$fg[yellow]"
	export BLACK="$fg[black]"
	export NO_COLOR="$reset_color"
else
	# Bash Colours
	# Can start with either \033 or \e
	# Normal is \e[0;
	# Bold is \e[01;
	export RED="\e[0;31m"
	export RED_BOLD="\e[01;31m"
	export BLUE="\e[0;34m"
	export CYAN='\e[0;36m'
	export PURPLE='\e[0;35m'
	export GREEN="\e[0;32m"
	export YELLOW="\e[0;33m"
	export BLACK="\e[0;38m"
	export NO_COLOR="\e[0m"
fi

# Alias colours for specific usages
export C_RESET=$NO_COLOR
export C_TIME=$GREEN
export C_USER=$BLUE
export C_PATH=$YELLOW
export C_GIT_CLEAN=$CYAN
export C_GIT_DIRTY=$RED

# Function to assemble the Git part of our prompt.
alias git_branch="silent_stderr git branch | sed -n '/^\*/s/^\* //p'"
function git_prompt {
	if ! silent git rev-parse --git-dir; then
		return 0
	fi

	echo ":$(git_branch)"
}
function git_prompt_color {
	if ! git rev-parse --git-dir > /dev/null 2>&1; then
		return 0
	fi

	local git_branch
	git_branch=$(git_branch)

	if silent git diff --quiet; then
		local git_color=$C_GIT_CLEAN
	else
		local git_color=$C_GIT_DIRTY
	fi

	echo ":${git_color}${git_branch}${C_RESET}"
}

# Theme
function baltheme {
	local prefix=""
	local separator=':'
	local moment
	moment="$(date +%H:%M:%S)"
	local user=""
	local target="${PWD/HOME/~}"

	if is_ssh; then
		user="${USER}@${HOSTNAME}"
		local C_USER=$C_GIT_DIRTY
	fi

	if is_string "$moment"; then
		prefix="${prefix}${C_TIME}${moment}${C_RESET}${separator}"
	fi
	if is_string "$user"; then
		prefix="${prefix}${C_USER}${user}${C_RESET}${separator}"
	fi
	if is_string "$target"; then
		prefix="${prefix}${C_PATH}${target}${C_RESET}"
	fi

	prefix="${prefix}$(git_prompt_color)"

	# Bash
	if is_bash; then
		local basename
		local title
		basename=$(basename "$target")
		# local pathReversed=$(echo -n $target | split '/' | sed '1!G;h;$!d' | join '\\\\')
		title="${basename}${separator}${user}${separator}${target}$(git_prompt)"

		export PS1="${prefix}\n\$ "
		echo -ne "\033]0;${title}\007"

	# ZSH
	else
		export PS1="${prefix}
\$ "
		# export PROMPT="${prefix}\n\$ "
		# echo -ne "\e]1;${title}\a"
	fi
}


# Set the terminal to use the theme
if is_bash; then
	export PROMPT_COMMAND="baltheme"
elif is_zsh; then
	function precmd {
		baltheme
	}
fi
