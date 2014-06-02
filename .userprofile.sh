###
# Configuration

# OS
export OS="$(uname -s)"

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
# Git Configuration

# Configure Git
git config --global core.excludesfile ~/.gitignore_global
git config --global push.default simple
git config --global mergetool.keepBackup false
git config --global color.ui auto
git config --global hub.protocol https
git config core.filemode false

# Use OSX Credential Helper if available, otherwise default to time cache
if [[ "$OS" = "Darwin" ]]; then
	git config --global credential.helper osxkeychain
	git config --global diff.tool opendiff
	git config --global merge.tool opendiff
	git config --global difftool.prompt false
else
	git config --global credential.helper cache
	git config credential.helper 'cache --timeout=86400'
fi


###
# Source

# Source our custom rc configuration
source "$HOME/.userrc.sh"
