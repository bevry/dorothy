#!/bin/sh
export LOADEDDOTFILES="$LOADEDDOTFILES .user.sh"

###
# Base Helpers

# function arguments
# http://stackoverflow.com/a/6212408/130638

# test, man test
# -z is empty string: True if the length of string is zero.
# -n is string: True if the length of string is nonzero.
# -d is dir: True if file exists and is a directory.
# -f is file: True if file exists and is a regular file.
# -s is nonempty file: True if file exists and has a size greater than zero.
# = is equal: True if the strings s1 and s2 are identical.
# http://unix.stackexchange.com/a/306115/50703
# http://unix.stackexchange.com/a/246320/50703
function is_empty_string {
	test -z "$1"
}
function is_string {
	test -n "$1"
}
function is_dir {
	test -d "$1"
}
function is_file {
	test -f "$1"
}
function is_nonempty_file {
	test -s "$1"
}
function is_equal {
	test "$1" = "$2"
}

# Extras
function is_mac {
	test "$OS" = "Darwin"
}
function is_linux {
	test "$OS" = "Linux"
}
function is_bash {
	test "$PROFILE_SHELL" = "bash"
}
function is_zsh {
	test "$PROFILE_SHELL" = "zsh"
}
function command_exists {
	type "$1" &> /dev/null
	# fish not bash: type --quiet "$1"
}
function command_missing {
	! command_exists "$1"
}


###
# Init Helpers

# Setup the path
function pathinit {
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
		if is_string "$GOPATH"; then
			export PATH=$GOPATH/bin:$PATH
		fi
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
}

# Setup shell configuration
function shellinit {
	if is_string "$ZSH_VERSION"; then
		export PROFILE_SHELL='zsh'
	elif is_string "$BASH_VERSION"; then
		export PROFILE_SHELL='bash'
	elif is_string "$KSH_VERSION"; then
		export PROFILE_SHELL='ksh'
	elif is_string "$FCEDIT"; then
		export PROFILE_SHELL='ksh'
	elif is_string "$PS3"; then
		export PROFILE_SHELL='unknown'
	else
		export PROFILE_SHELL='sh'
	fi
}

# Set the editor configuration
function editorinit {
    export LC_CTYPE=en_US.UTF-8

	if command_exists micro; then
		export TERMINAL_EDITOR='micro'
		export TERMINAL_EDITOR_PROMPT='micro'
	elif command_exists nano; then
		export TERMINAL_EDITOR='nano'
		export TERMINAL_EDITOR_PROMPT='nano'
	elif command_exists vim; then
		export TERMINAL_EDITOR='vim'
		export TERMINAL_EDITOR_PROMPT='vim' # --noplugin -c "set nowrap"'
	fi

	if command_exists atom; then
		export GUI_EDITOR='atom'
		export GUI_EDITOR_PROMPT='atom -w'
	elif command_exists code; then
		export GUI_EDITOR='code'
		export GUI_EDITOR_PROMPT='code -w'
	elif command_exists subl; then
		export GUI_EDITOR='subl'
		export GUI_EDITOR_PROMPT='subl -w'
	elif command_exists gedit; then
		export GUI_EDITOR='gedit'
		export GUI_EDITOR_PROMPT='gedit'
	fi

	if is_string "$SSH_CONNECTION"; then
		alias edit=$TERMINAL_EDITOR
	else
		alias edit=$GUI_EDITOR
	fi

	# Always use terminal editor for prompts
	# as GUI editors are too slow
	export EDITOR=$TERMINAL_EDITOR_PROMPT
}


###
# Setup Helpers

# Setup git configuraiton
function gitsetup {
	# General
	git config --global core.excludesfile ~/.gitignore_global
	git config --global push.default simple
	git config --global mergetool.keepBackup false
	git config --global color.ui auto

	# Authentication
	# Use OSX Credential Helper if available, otherwise default to time cache
	if is_mac; then
		git config --global credential.helper osxkeychain
		git config --global diff.tool opendiff
		git config --global merge.tool opendiff
		git config --global difftool.prompt false
		# http://apple.stackexchange.com/a/254619/15131
		echo "\nAddKeysToAgent yes" >> ~/.ssh/config
	else
		git config --global credential.helper cache
		git config credential.helper 'cache --timeout=86400'
	fi
}

# Setup binary files
function binsetup {
	# Atom
	if is_dir "$HOME/Applications/Atom.app"; then
		if command_missing atom; then
			ln -s "$HOME/Applications/Atom.app/Contents/Resources/app/atom.sh" "$HOME/bin/atom"
			ln -s "$HOME/Applications/Atom.app/Contents/Resources/app/apm/bin/apm" "$HOME/bin/apm"
			editorinit
		fi
	fi

	# Visual Studio Code
	if is_dir "$HOME/Applications/Visual Studio Code.app"; then
		if command_missing code; then
			ln -s "$HOME/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" "$HOME/bin/code"
			editorinit
		fi
	fi

	# GitHub
	if is_dir "$HOME/Applications/GitHub.app"; then
		if command_missing github; then
			ln -s "$HOME/Applications/GitHub Desktop.app/Contents/MacOS/github_cli" "$HOME/bin/github"
		fi
	fi

	# Git Scan
	if command_missing git-scan; then
		curl -LsS "https://download.civicrm.org/git-scan/git-scan.phar" -o "$HOME/bin/git-scan"
		chmod +x "$HOME/bin/git-scan"
	fi
}


###
# General Helpers

# Download a file
alias download='down'
function down {
	# do not use the continue flags as they will prefer the local file over the remote file if the local exists
	if command_exists aria2c; then
		aria2c --allow-overwrite=true --auto-file-renaming=false "$1"
	elif command_exists wget; then
		wget -N "$1"
	elif command_exists curl; then
		curl -OL "$1"
	elif command_exists http; then
		http -d "$1"
	fi
}

# Download a file from a github repo
function gdown {
	down "https://raw.githubusercontent.com/$1"
}

# Download and extract a github repository rather than cloning it, should be faster if you don't need git history
function gitdown {
	local repo
	local file
	repo=$(echo "$1" | sed "s/https:\/\/github.com\///" | sed "s/.git//")
	file=$(basename "$repo")
	rm -Rf "$file" "$file.tar.gz" && mkdir -p "$file" && cd "$file" && down "https://github.com/$repo/archive/master.tar.gz" -O "$file.tar.gz" && tar -xvzf "$file.tar.gz" && mv ./*-master/* . && rm -Rf ./*-master "$file.tar.gz" && cd ..
}

# Clone a list of repositories
function clone {
	for ARG in "$@"
	do
		hub clone "$ARG"
	done
}

# Get the geocoordinates of a location
function geocode {
	open "https://api.tiles.mapbox.com/v3/examples.map-zr0njcqy/geocode/$1.json"
}

# Merge videos in current directory
function vmerge {
	local dir
	dir=$(basename "$(pwd)")
	ffmpeg -f concat -safe 0 -i <(for f in *m4v; do echo "file '$PWD/$f'"; done) -c copy "$dir.m4v"
	mv "$dir.m4v" ..
}

# Setup a SSH Key
function addsshkey {
	eval "$(ssh-agent -s)"
	ssh-add -K "$HOME/.ssh/$1"
}
function newsshkey {
	if is_string "$1"; then
		local name=$1

		local comment=$name
		if is_string "$2"; then
			comment=$2
		fi

		local path=$HOME/.ssh/$name
		rm -f "$path*"
		echo "Creating new ssh-key at $path with comment $comment"
		ssh-keygen -t rsa -b 4096 -C "$comment" -f "$path"
		addsshkey "$name"
		cat "$path.pub"
	else
		echo "newsshkey KEY_NAME [YOUR_EMAIL]"
	fi
}

# Clojure install
function clojureinstall {
	# Install Clojure
	rm -Rf ~/.clojure && mkdir ~/.clojure && cd ~/.clojure && down http://repo1.maven.org/maven2/org/clojure/clojure/1.8.0/clojure-1.8.0.zip && unzip clojure-1.8.0.zip

	# Install ClojureScript
	cd ~/bin && down https://github.com/clojure/clojurescript/releases/download/r1.9.229/cljs.jar

	# Install Boot
	cd ~/bin && down https://github.com/boot-clj/boot-bin/releases/download/latest/boot.sh && chmod +x boot.sh
}

###
# Initialise

# OS
export OS
OS=$(uname -s)

# Don't check mail
export MAILCHECK=0

# Path
pathinit

# Editor
editorinit

# Shell
shellinit

# Oh my zsh
if is_equal "$PROFILE_SHELL" "zsh"; then
	if is_dir "$HOME/.oh-my-zsh"; then
		export DISABLE_UPDATE_PROMPT=true
		export ZSH="$HOME/.oh-my-zsh"
		# export ZSH_THEME="avit"
		export plugins=(terminalapp osx autojump bower brew brew-cask cake coffee cp docker gem git heroku node npm nvm python ruby)
		# shellcheck source=.oh-my-zsh/oh-my-zsh.sh
		source "$ZSH/oh-my-zsh.sh"
	fi
fi

# NVM
if is_dir "$HOME/.nvm"; then
	export NVM_DIR="$HOME/.nvm"
	# shellcheck source=.nvm/nvm.sh
	source "$NVM_DIR/nvm.sh"
fi

# Operating System
# Specific Operating System Configuration: macOS
if is_mac; then
	# Brew Cask Location
	export HOMEBREW_CASK_OPTS="--appdir=$HOME/Applications --caskroom=$HOME/Applications/Caskroom"

	# Configuration
	function macsetup {
		# Apps
		mkdir -p "$HOME/bin"
		mkdir -p "$HOME/Applications"

		# https://software.com/mac/tweaks/highlight-stacked-items-in-dock
		# defaults write com.apple.dock mouse-over-hilite-stack -boolean true

		# http://superuser.com/a/176197/32418
		# defaults write com.apple.dock workspaces-auto-swoosh -bool false

		# https://software.com/mac/tweaks/show-file-extensions-in-finder
		defaults write NSGlobalDomain AppleShowAllExtensions -boolean true

		# https://software.com/mac/tweaks/show-all-files-in-finder
		defaults write com.apple.finder AppleShowAllFiles -boolean true

		# https://software.com/mac/tweaks/hide-desktop-icons
		defaults write com.apple.finder CreateDesktop -bool false

		# http://osxdaily.com/2012/04/11/disable-the-file-extension-change-warning-in-mac-os-x/
		defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

		# https://software.com/mac/tweaks/auto-hide-the-dock
		defaults write com.apple.dock autohide -boolean true
	}

	# Install
	alias brewinit='ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
	alias brewinstall='brew install aria2 bash heroku hub git git-extras gpg python micro ruby shellcheck tree wget watchman vim zsh'
	alias caskinit='brew untap caskroom/cask; brew install caskroom/cask/brew-cask && brew tap caskroom/fonts'
	alias caskinstall='echo "User applications should now be manually installed to ~/Applications — https://gist.github.com/balupton/5259595"'
	alias fontinstall='brew cask install font-cantarell font-droid-sans font-hasklig font-lato font-fira-code font-maven-pro font-fira-mono font-monoid font-montserrat font-open-sans font-oxygen font-oxygen-mono font-roboto font-roboto-mono font-source-code-pro font-ubuntu'  # font-andale-mono failed to install
	alias brewupdate='brew update && brew upgrade && brew cleanup && brew cask cleanup'
	alias nvmupdate='cd "$HOME/.nvm" && git checkout master && git pull origin master && cd "$HOME"'
	alias install='macsetup && brewinit && brewinstall && gitsetup && caskinit && caskinstall && binsetup && fontinstall && nvminstall && npminstall && geminstall && pipinstall && apminstall'
	alias update='baseupdate && brewupdate && nvmupdate && apmupdate'

	# Mac specific aliases
	alias md5sum='md5 -r'
	alias edithosts='sudo edit /etc/hosts'

	# Font Seaching
	function fontsearch {
		brew cask search /font-/ | grep "$1"
	}

	# Flush DNS
	function flushdns {
		# https://support.apple.com/en-us/HT202516
		sudo killall -HUP mDNSResponder
		sudo dscacheutil -flushcache
		sudo discoveryutil mdnsflushcache
	}

	# iOS Simulator
	function iosdev {
		if is_dir "$HOME/Applications/Xcode-beta.app"; then
			open ~/Applications/Xcode-beta.app/Contents/Developer/Applications/Simulator.app
		elif is_dir "$HOME/Applications/Xcode.app"; then
			open ~/Applications/Xcode.app/Contents/Applications/iPhone\ Simulator.app
		elif is_dir "/Applications/Xcode.app"; then
			open /Applications/Xcode.app/Contents/Applications/iPhone\ Simulator.app
		else
			echo "Xcode is not installed"
		fi
	}

	# Android Simulator
	function androiddev {
		if is_dir "/Applications/Android\ Studio.app"; then
			/Applications/Android\ Studio.app/sdk/tools/emulator -avd basic
		else
			echo "Android Studio is not installed"
		fi
	}

# Specific Operating System Configuration: Linux
elif is_linux; then
	# Installers
	function fontinstall {
		# Prepare
		local f="$HOME/.fonts"
		local ft="$f/tmp"
		local p
		p=$(pwd)
		mkdir -p "$f" "$ft" && \
		cd "$ft" || exit

		# Monoid
		down https://cdn.rawgit.com/larsenwork/monoid/2db2d289f4e61010dd3f44e09918d9bb32fb96fd/Monoid.zip && \
		unzip Monoid.zip && \
		mv ./*.ttf "$f"

		# Source Code Pro
		# http://askubuntu.com/a/193073/22776
		# https://github.com/adobe-fonts/source-code-pro
		down https://github.com/adobe-fonts/source-code-pro/archive/2.010R-ro/1.030R-it.zip && \
		unzip 1.030R-it.zip && \
		mv source-code-pro-2.010R-ro-1.030R-it/OTF/*.otf "$f"

		# Monaco
		# https://github.com/showcases/fonts
		# https://github.com/todylu/monaco.ttf
		down https://github.com/todylu/monaco.ttf/raw/master/monaco.ttf && mv monaco.ttf "$f"

		# Refresh
		fc-cache -f -v && cd "$p" && rm -Rf "$ft"
	}
	alias aptinstall='sudo apt-get install -y build-essential curl git httpie libssl-dev openssl python ruby software-properties-common vim'
	alias aptupdate='sudo apt-get update -y && sudo apt-get upgrade -y'
	alias aptclean='sudo apt-get clean -y && sudo apt-get autoremove -y'
	alias aptremove='sudo apt-get remove -y --purge libreoffice* rhythmbox thunderbird shotwell gnome-mahjongg gnomine gnome-sudoku gnome-mines aisleriot imagemagick && aptclean'
	alias exposeinstall='sudo apt-get install -y compiz compizconfig-settings-manager compiz-plugins-extra compiz-plugins-main compiz-plugins'
	alias solarizedinstall='cd ~ && git clone git://github.com/sigurdga/gnome-terminal-colors-solarized.git && cd gnome-terminal-colors-solarized && chmod +x install.sh && cd ~ && rm -Rf gnome-terminal-colors-solarized'
	alias atominstall='sudo add-apt-repository -y ppa:webupd8team/atom && sudo apt-get update -y && sudo apt-get install -y atom && apminstall'
	alias shellinstall='sudo apt-get -y update && sudo apt-get install -y libnotify-bin libgnome-keyring-dev'
	alias javainstall='sudo add-apt-repository -y ppa:webupd8team/java && sudo apt-get update -y && sudo apt-get install -y oracle-java8-installer oracle-java8-set-default'
	alias install='gitsetup && aptupdate && aptinstall && shellinstall && fontinstall && nvminstall && npminstall && atominstall && aptclean'
	alias update='baseupdate && aptupdate && aptclean'

	# System
	alias resetfirefox="rm ~/.mozilla/firefox/*.default/.parentlock"
fi

# Installers
alias editprofile='edit ~/.profile ~/.*profile ~/.*rc'
alias usezsh='chpass -u $USER -s $(which zsh)'
alias ohmyzshinstall='curl -L http://install.ohmyz.sh | sh'
alias zshinstall='ohmyzshinstall && usezsh'
alias nvminstall='git clone git://github.com/creationix/nvm.git ~/.nvm && loadnvm && nvm install node && nvm alias default node && nvm use node && npm install -g npm'
alias npminstall='npm install -g npm && npm install -g yarn && nig npm-check-updates' # node-inspector
alias pipinstall='pip install --upgrade pip && pip install httpie'
alias geminstall='sudo gem install git-up terminal-notifier sass compass travis rhc'
# graveyard themes: chester-atom-syntax duotone-dark-syntax duotone-dark-space-syntax duotone-light-syntax duotone-snow atom-material-syntax atom-material-syntax-light atom-material-ui
# graveyard packages: markdown-preview-plus language-markdown
alias apminstall='apm install atom-beautify editorconfig file-type-icons highlight-selected indentation-indicator linter linter-coffeelint linter-csslint linter-eslint linter-flow linter-jsonlint linter-shellcheck react visual-bell'
alias apmupdate='apm update --no-confirm'
alias baseupdate='cd ~ && git pull origin master'

# Highlight clipboard code as RTF for keynote
# styles: https://help.farbox.com/pygments.html
alias highlight="pbpaste | pygmentize -g -f rtf -O 'fontface=Monaco,style=tango' | pbcopy"

# Tar
alias mktar='tar -cvzf'
alias untar='tar -xvzf'

# Database
alias startredis='redis-server /usr/local/etc/redis.conf'
alias startmongo='mongod --config /usr/local/etc/mongod.conf'

# Servers
alias serve='python -m SimpleHTTPServer 8000'

# Node
alias nic='rm -Rf node_modules yarn.lock && yarn'
alias ni='yarn add'  # npm install --save
alias nid='yarn add --dev'  # npm install --save-dev
alias nig='npm install --global add'  # yarn global
alias npmus='npm set registry http://registry.npmjs.org/'
alias npmau='npm set registry http://registry.npmjs.org.au/'
alias npmeu='npm set registry http://registry.npmjs.eu/'
alias npmio='npm install --cache-min 999999999'
function nake {
	npm run-script "our:$1"
}

# Git
alias ga='git add'
alias gu='git add -u'
alias gp='git push'
alias gl='git log'
alias gs='git status'
alias gd='git diff'
alias gdc='git diff --cached'
alias gm='git commit -m'
alias gma='git commit -am'
alias gb='git branch'
alias gc='git checkout'
alias gra='git remote add'
alias grr='git remote rm'
alias gpu='git pull'
alias gcl='git clone'
alias gpo='gp origin; gp origin --tags'
alias gup='git pull origin'
alias gap='git remote | xargs -L1 git push'
alias gitclean='rm -rf .git/refs/original/; git reflog expire --expire=now --all; git gc --prune=now; git gc --aggressive --prune=now'
alias gitsvnupdate='git svn rebase'
alias gitrm='git ls-files --deleted | xargs git rm'
alias githooks='edit .git/hooks/pre-commit'

# Wget
alias wgett='echo -e "\nHave you remembered to correct the following:\n user agent, trial attempts, timeout, retry and wait times?\n\nIf you are about to leech use:\n [wgetbot] to brute-leech as googlebot\n [wgetff]  to slow-leech  as firefox (120 seconds)\nRemember to use -w to customize wait time.\n\nPress any key to continue...\n" ; read -n 1 ; wget --no-check-certificate'
alias wgetbot='wget -t 2 -T 15 --waitretry 10 -nc --user-agent="Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"'
alias wgetff='wget -t 2 -T 15 --waitretry 10 -nc -w 120 --user-agent="-user-agent="Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.1.6) Gecko/20070725 Firefox/2.0.0.6""'

# Administration
alias sha1check='openssl sha1 '
alias takeownership='sudo chown -R $USER .'
alias svnshowexternals='svn propget -R svn:externals .'
alias search='find . -name'
alias allow='chmod +x'
alias sha256='shasum -a 256'
alias filecount='find . | wc -l'

# Cleaners
function rmdir {
	rm -Rfd "$1"
}
alias rmsvn='sudo find . -name ".svn" -exec rmdir {} \;'
alias rmtmp='sudo find ./* -name ".tmp*" -exec rmdir {} \;'
alias rmsync='sudo find . -name ".sync" -exec rmdir {} \;'
alias rmmodules='sudo find ./* -name "node_modules" -exec rmdir {} \;'

# Environment
if is_file "$HOME/.userenv.sh"; then
	# shellcheck source=.userenv.sh
	source "$HOME/.userenv.sh"
fi

# Theme
if is_equal "$THEME" "baltheme"; then
	# shellcheck source=.baltheme.sh
	source "$HOME/.baltheme.sh"
fi
