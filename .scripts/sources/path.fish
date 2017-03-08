#!/bin/bash

if is_empty_string "$PATH_ORIGINAL"; then
	export PATH_ORIGINAL=$PATH
	export MANPATH_ORIGINAL=$MANPATH
	export CLASSPATH_ORIGINAL=$CLASSPATH
else
	export PATH=$PATH_ORIGINAL
	export CLASSPATH=$CLASSPATH_ORIGINAL
	export MANPATH=$MANPATH_ORIGINAL
fi

# Add current directories node_module binaries to the end of the path, so least preferred
export PATH=$PATH:./node_modules/.bin

# Add the paths needed for go
if command_exists go; then
	if is_empty_string "$GOPATH"; then
		export GOPATH=$HOME/.go
		mkdir -p "$GOPATH"
	fi
	export PATH=$GOPATH/bin:$PATH
fi

# Ruby
if command_exists go; then
	if is_empty_string "$GEM_HOME"; then
		export GEM_HOME=$HOME/.gems
		mkdir -p "$GEM_HOME"
	fi
	export PATH=$GEM_HOME/bin:$PATH
fi

# Java
if is_empty_string "$CLASSPATH"; then
	export CLASSPATH='.'
fi

# Clojurescript
if is_dir "$HOME/.clojure/clojure-1.8"; then
	export PATH=$HOME/.clojure/clojure-1.8.0:$PATH
	export CLASSPATH=$CLASSPATH:$HOME/.clojure/clojure-1.8.0
fi

# Straightforward other additions to the path
if is_dir /usr/local/opt/ruby/bin; then
	export PATH=/usr/local/opt/ruby/bin:$PATH
fi
if is_dir /usr/local/heroku/bin; then
	export PATH=/usr/local/heroku/bin:$PATH
fi
if is_dir /usr/local/bin; then
	export PATH=/usr/local/bin:$PATH
fi
if is_dir "$HOME/bin"; then
	export PATH=$HOME/bin:$PATH
fi

# Man path
if is_dir /usr/local/man; then
	export MANPATH=/usr/local/man:$MANPATH
fi