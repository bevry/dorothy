export LOADEDDOTFILES="$LOADEDDOTFILES .userprofile.sh"

###
# Environment, Configuration, Installation

# Check if a Command Exists
function command_exists {
	type "$1" &> /dev/null
}

# Set the editor configuration
function editorsetup {
    export LC_CTYPE=en_US.UTF-8

	if command_exists vim; then
		export TERMINAL_EDITOR='vim'
		export TERMINAL_EDITOR_PROMPT='vim'
	fi

	if command_exists atom; then
		export GUI_EDITOR='atom'
		export GUI_EDITOR_PROMPT='atom -w'
	elif command_exists subl; then
		export GUI_EDITOR='subl'
		export GUI_EDITOR_PROMPT='subl -w'
	elif command_exists gedit; then
		export GUI_EDITOR='gedit'
		export GUI_EDITOR_PROMPT='gedit'
	fi

	if [[ -n $SSH_CONNECTION ]]; then
		alias edit=`which $TERMINAL_EDITOR`
	else
		alias edit=`which $GUI_EDITOR`
	fi

	# Always use terminal editor for prompts
	# as GUI editors are too slow
	export EDITOR=$TERMINAL_EDITOR_PROMPT
}

# Make the terminal title not show the current process when initially setting up
# echo -ne "\033]0;-\007"

# Add current directories node_module binaries to the end of the path, so least preferred
export PATH=$PATH:./node_modules/.bin

# Add the paths needed for go
if command_exists go; then
	if ! test -n "$GOPATH"; then
		export GOPATH=$HOME/go
	mkdir -p $GOPATH
	fi
	if test -n "$GOPATH"; then
		export PATH=$GOPATH/bin:$PATH
	fi
fi

# Straightforward other additions to the path
if [[ -d /usr/local/opt/ruby/bin ]]; then
	export PATH=/usr/local/opt/ruby/bin:$PATH
fi
if [[ -d /usr/local/heroku/bin ]]; then
	export PATH=/usr/local/heroku/bin:$PATH
fi
if [[ -d /usr/local/bin ]]; then
	export PATH=/usr/local/bin:$PATH
fi
if [[ -d $HOME/bin ]]; then
	export PATH=$HOME/bin:$PATH
fi

# Man path
if [[ -d /usr/local/man ]]; then
	export MANPATH=/usr/local/man:$MANPATH
fi

# Editor
editorsetup
