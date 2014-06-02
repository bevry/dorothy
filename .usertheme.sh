# Function to assemble the Git part of our prompt.
function git_prompt {
	if ! git rev-parse --git-dir > /dev/null 2>&1; then
		return 0
	fi

	echo ":$(git branch 2>/dev/null| sed -n '/^\*/s/^\* //p')"
}
function git_prompt_color {
	if ! git rev-parse --git-dir > /dev/null 2>&1; then
		return 0
	fi

	local git_branch=$(git branch 2>/dev/null| sed -n '/^\*/s/^\* //p')

	if git diff --quiet 2>/dev/null >&2; then
		local git_color=$C_GIT_CLEAN
	else
		local git_color=$C_GIT_DIRTY
	fi

	echo ":${git_color}${git_branch}${C_RESET}"
}

# Terminal Prefix
function precmd {
	local separator=':'
	local time=$(date +%H:%M:%S)
	local target=${PWD/$HOME/~}
	local user="${USER}@${HOSTNAME}"
	if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
		local C_USER=$RED
	fi

	local basename=$(basename "$target")
	# local pathReversed=$(echo -n $target | split '/' | sed '1!G;h;$!d' | join '\\\\')
	local title="${basename}${separator}${user}${separator}${target}$(git_prompt)"
	local prefix="${C_TIME}${time}${C_RESET}${separator}${C_USER}${user}${C_RESET}${separator}${C_PATH}${target}${C_RESET}$(git_prompt_color)"

	# Bash
	if [[ $PROFILE_SHELL = 'bash' ]]; then
		export PS1="${prefix}\n\$ "
		echo -ne "\033]0;${title}\007"

	# ZSH
	else
		export PROMPT="${prefix}
$ "     # zsh
		# echo -ne "\e]1;${title}\a"
	fi
}
export PROMPT_COMMAND=precmd  # bash