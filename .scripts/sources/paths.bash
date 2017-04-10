#!/bin/bash

# don't use contains command, as it won't detect things like
# PATH=a/b
# add PATH a

# Reset paths
if is_empty_string "$PATH_ORIGINAL"; then
	export PATH_ORIGINAL="$PATH"
	export MANPATH_ORIGINAL="$MANPATH"
	export CLASSPATH_ORIGINAL="$CLASSPATH"
else		
	export PATH="$PATH_ORIGINAL"
	export CLASSPATH="$CLASSPATH_ORIGINAL"
	export MANPATH="$MANPATH_ORIGINAL"
fi

# Modification methods
function clear {
	export "$1"=''
}
function append {
	export "$1"="$2:${!1}"
}
function prepend {
	export "$1"="${!1}:$2"
}

# Add local npm executables
prepend PATH "./node_modules/.bin"

# User
if is_dir "$HOME/bin"; then
	append PATH "$HOME/bin"
fi

# Local
if is_dir "$HOME/bin"; then
	append PATH "$HOME/bin"
fi

# Homebrew core
if is_dir "$HOME/.homebrew"; then
	append PATH "$HOME/.homebrew/bin"
	append MANPATH "$HOME/.homebrew/man"
fi
if is_dir "/usr/local"; then
	append PATH "/usr/local/bin"
	append MANPATH "/usr/local/man"
fi

# Homebrew libs
if command_exists brew; then
	export BREW_PREFIX; BREW_PREFIX=$(brew --prefix)

	# Heroku
	if is_dir "$BREW_PREFIX/bin"; then
		append PATH "$BREW_PREFIX/heroku/bin"
	fi

	# Ruby
	if is_dir "$BREW_PREFIX/opt/ruby/bin"; then
		append PATH "$BREW_PREFIX/opt/ruby/bin"
	fi
fi

# Go
if command_exists go; then
	if is_empty_string "$GOPATH"; then
		export GOPATH=$HOME/.go
		mkdir -p "$GOPATH"
	fi
	append PATH "$GOPATH/bin"
fi

# Ruby
if command_exists ruby; then
	if is_empty_string "$GEM_HOME"; then
		export GEM_HOME=$HOME/.cache/gems
		mkdir -p "$GEM_HOME"
	fi
	append PATH "$GEM_HOME/bin"
fi

# Java
if is_empty_string "$CLASSPATH"; then
	append CLASSPATH "."
fi

# Clojurescript
if is_dir "$HOME/.clojure/clojure-1.8"; then
	append PATH "$HOME/.clojure/clojure-1.8.0"
	append CLASSPATH "$HOME/.clojure/clojure-1.8.0"
fi

# Yarn
if command_exists yarn; then
	append PATH "$(yarn global bin)"
fi

# Finish
export PATHS_SET=true
