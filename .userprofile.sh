###
# Functions

# Check if a Command Exists
function command_exists {
    type "$1" &> /dev/null
}


###
# Configuration

# Make the terminal title not show the current process when initially setting up
echo -ne "\033]0;-\007"

# Paths
if [[ -f /usr/local/opt/rbenv ]]; then
	export RBENV_ROOT=/usr/local/opt/rbenv
fi

# Path
if test -n "$RBENV_ROOT"; then
	export PATH=$RBENV_ROOT/bin:$PATH
fi
if command_exists go; then
    if ! test -n "$GOPATH"; then
    	export GOPATH=$HOME/go
	mkdir -p $GOPATH
    fi
    if test -n "$GOPATH"; then
    	export PATH=$GOPATH/bin:$PATH
    fi
fi
if [[ -d /usr/local/opt/ruby/bin ]]; then
	export PATH=/usr/local/opt/ruby/bin:$PATH
fi
if [[ -d /usr/local/heroku/bin ]]; then
	export PATH=/usr/local/heroku/bin:$PATH
fi
# apparently this is not needed anymore
# if [[ -d /usr/local/share/python ]]; then
# 	export PATH=/usr/local/share/python:$PATH
# fi
if [[ -d /usr/local/bin ]]; then
	export PATH=/usr/local/bin:$PATH
fi
if [[ -d $HOME/bin ]]; then
	export PATH=$HOME/bin:$PATH
fi

if [[ -d /usr/local/man ]]; then
	export MANPATH=/usr/local/man:$MANPATH
fi

# Software Metrics Unit
# if [[ -d /usr/units/sm/bin ]]; then
# 	export PATH=/opt/rsm:/usr/units/sm/bin:$PATH
# 	export CLASSPATH=.:/usr/units/sm/classes:$CLASSPATH
# fi

# Atom
if [[ -d $HOME/Applications/Atom.app ]]; then
	if ! command_exists atom; then
		ln -s "$HOME/Applications/Atom.app/Contents/Resources/app/atom.sh" "$HOME/bin/atom"
		ln -s "$HOME/Applications/Atom.app/Contents/Resources/app/apm/bin/apm" "$HOME/bin/apm"
	fi
fi

# Editor
export LC_CTYPE=en_US.UTF-8
if [[ -n $SSH_CONNECTION ]]; then
	alias edit=`which vim`
	export EDITOR='vim'
elif command_exists atom; then
	alias edit=`which atom`
	export EDITOR='atom -w'
elif command_exists subl; then
	alias edit=`which subl`
	export EDITOR='subl -w'
elif command_exists gedit; then
	alias edit=`which gedit`
	export EDITOR='gedit'
fi
