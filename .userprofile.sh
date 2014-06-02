###
# Configuration

# Paths
if [[ -f /usr/local/opt/rbenv ]]; then
	export RBENV_ROOT=/usr/local/opt/rbenv
fi
if [[ -f $HOME/Library/Developer/go ]]; then
	export GOPATH=$HOME/Library/Developer/go
fi

# Path
if test -n "$RBENV_ROOT"; then
	export PATH=$RBENV_ROOT/bin:$PATH
fi
if test -n "$GOPATH"; then
	export PATH=$GOPATH/bin:$PATH
fi
if [[ -d /usr/local/opt/ruby/bin ]]; then
	export PATH=/usr/local/opt/ruby/bin:$PATH
fi
if [[ -d /usr/local/heroku/bin ]]; then
	export PATH=/usr/local/heroku/bin:$PATH
fi
if [[ -d /usr/local/share/python ]]; then
	export PATH=/usr/local/share/python:$PATH
fi
if [[ -d /usr/local/bin ]]; then
	export PATH=/usr/local/bin:$PATH
fi
if [[ -d $HOME/bin ]]; then
	export PATH=$HOME/bin:$PATH
fi

if [[ -d /user/local/man ]]; then
	export MANPATH=/usr/local/man:$MANPATH
fi


# Editor
export LC_CTYPE=en_US.UTF-8
if [[ -n $SSH_CONNECTION ]]; then
	export EDITOR='vim'
else
	export EDITOR='subl -w'
fi


###
# Source

# Source our custom rc configuration
source "$HOME/.userrc.sh"
