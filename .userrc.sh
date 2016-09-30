export LOADEDDOTFILES="$LOADEDDOTFILES .userrc.sh"

###
# Environment, Configuration, Installation

# Check if a Command Exists
function command_exists {
	type "$1" &> /dev/null
}

# OS
export OS="$(uname -s)"

# Don't check mail
export MAILCHECK=0

# Shell
if test -n "$ZSH_VERSION"; then
	export PROFILE_SHELL='zsh'
	export HOSTNAME=$(hostname)  # what does this do?
elif test -n "$BASH_VERSION"; then
	export PROFILE_SHELL='bash'
elif test -n "$KSH_VERSION"; then
	export PROFILE_SHELL='ksh'
elif test -n "$FCEDIT"; then
	export PROFILE_SHELL='ksh'
elif test -n "$PS3"; then
	export PROFILE_SHELL='unknown'
else
	export PROFILE_SHELL='sh'
fi

# OH MY ZSH
if [[ $PROFILE_SHELL = "zsh" ]]; then
	if [ -d "$HOME/.oh-my-zsh" ]; then
		export DISABLE_UPDATE_PROMPT=true
		export ZSH=$HOME/.oh-my-zsh
		# ZSH_THEME="avit"
		plugins=(terminalapp osx autojump bower brew brew-cask cake coffee cp docker gem git heroku node npm nvm python ruby)
		source $ZSH/oh-my-zsh.sh
	fi
fi

# Theme
source "$HOME/.usertheme.sh"

# Environment
source "$HOME/.userenv.sh"

# Specific Operating System Configuration: macOS
if [[ "$OS" = "Darwin" ]]; then
	# Brew Cask Location
	export HOMEBREW_CASK_OPTS="--appdir=~/Applications --caskroom=~/Applications/Caskroom"

	# Configuration
	function macsetup {
		# Apps
		mkdir -p ~/bin
		mkdir -p ~/Applications

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

		# disable the annoying terminal bell
		# http://superuser.com/a/1123198/32418
		local TERMINAL_PLIST="$HOME/Library/Preferences/com.apple.Terminal.plist"
		local TERMINAL_THEME=`/usr/libexec/PlistBuddy -c "Print 'Default Window Settings'" $TERMINAL_PLIST`
		/usr/libexec/PlistBuddy -c "Set 'Window Settings':$TERMINAL_THEME:Bell false" $TERMINAL_PLIST
		/usr/libexec/PlistBuddy -c "Set 'Window Settings':$TERMINAL_THEME:VisualBellOnlyWhenMuted false" $TERMINAL_PLIST
	}

	# Install
	alias brewinit='ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
	alias brewinstall='brew install aria2 bash heroku git git-extras gpg python ruby tree wget watchman hub vim zsh'
	alias caskinit='brew untap caskroom/cask; brew install caskroom/cask/brew-cask && brew tap caskroom/fonts'
	alias caskinstall='echo "User applications should now be manually installed to ~/Applications — https://gist.github.com/balupton/5259595"'
	alias fontinstall='brew cask install font-cantarell font-droid-sans font-hasklig font-lato font-fira-code font-maven-pro font-fira-mono font-monoid font-montserrat font-open-sans font-oxygen font-oxygen-mono font-roboto font-roboto-mono font-source-code-pro font-ubuntu'  # font-andale-mono failed to install
	alias brewupdate='brew update && brew upgrade && brew cleanup && brew cask cleanup'
	alias install='macsetup && brewinit && brewinstall && gitsetup && caskinit && caskinstall && binsetup && fontinstall && nvminstall && npminstall && geminstall && pipinstall && apminstall'
	alias update='baseupdate && brewupdate && apmupdate'

	# Font Seaching
	alias fontsearch='brew cask search /font-/'

	# Flush DNS
	function flushdns {
		# https://support.apple.com/en-us/HT202516
		sudo killall -HUP mDNSResponder
		sudo dscacheutil -flushcache
		sudo discoveryutil mdnsflushcache
	}

	# Mac specific aliases
	alias md5sum='md5 -r'
	alias edithosts='sudo edit /etc/hosts'

	# iOS Simulator
	function iosdev {
		if [ -d "$HOME/Applications/Xcode-beta.app" ]; then
			open ~/Applications/Xcode-beta.app/Contents/Developer/Applications/Simulator.app
		elif [ -d "$HOME/Applications/Xcode.app" ]; then
			open ~/Applications/Xcode.app/Contents/Applications/iPhone\ Simulator.app
		elif [ -d "/Applications/Xcode.app" ]; then
			open /Applications/Xcode.app/Contents/Applications/iPhone\ Simulator.app
		else
			echo "Xcode is not installed"
		fi
	}

	# Android Simulator
	function androiddev {
		if [ -d "/Applications/Android\ Studio.app" ]; then
			/Applications/Android\ Studio.app/sdk/tools/emulator -avd basic
		else
			echo "Android Studio is not installed"
		fi
	}

# Specific Operating System Configuration: Linux
elif [[ "$OS" = "Linux" ]]; then
	# Installers
	function fontinstall {
		# Prepare
		local f=~/.fonts
		local ft=$f/tmp
		local p=$(pwd)
		mkdir -p $f $ft
		cd $ft

		# Source Code Pro
		# http://askubuntu.com/a/193073/22776
		# https://github.com/adobe-fonts/source-code-pro
		wget https://github.com/adobe-fonts/source-code-pro/archive/2.010R-ro/1.030R-it.zip
		unzip 1.030R-it.zip
		cp source-code-pro-2.010R-ro-1.030R-it/OTF/*.otf $f

		# Monaco
		# https://github.com/showcases/fonts
		# https://github.com/todylu/monaco.ttf
		wget https://github.com/todylu/monaco.ttf/raw/master/monaco.ttf
		mv monaco.ttf $f

		# Refresh
		fc-cache -f -v
		cd $p
		rm -Rf $ft
	}
	alias aptinstall='sudo apt-get install -y build-essential curl git httpie libssl-dev openssl python ruby software-properties-common vim'
	alias aptupdate='sudo apt-get update -y && sudo apt-get upgrade -y'
	alias aptclean='sudo apt-get clean -y && sudo apt-get autoremove -y'
	alias aptremove='sudo apt-get remove -y --purge libreoffice* rhythmbox thunderbird shotwell gnome-mahjongg gnomine gnome-sudoku gnome-mines aisleriot imagemagick && aptclean'
	alias exposeinstall='sudo apt-get install -y compiz compizconfig-settings-manager compiz-plugins-extra compiz-plugins-main compiz-plugins'
	alias solarizedinstall='cd ~ && git clone git://github.com/sigurdga/gnome-terminal-colors-solarized.git && cd gnome-terminal-colors-solarized && chmod +x install.sh && cd ~ && rm -Rf gnome-terminal-colors-solarized'
	alias atominstall='sudo add-apt-repository -y ppa:webupd8team/atom && sudo apt-get update -y && sudo apt-get install -y atom && apminstall'
	alias shellinstall='sudo apt-get -y update && sudo apt-get install -y libnotify-bin libgnome-keyring-dev'
	alias install='gitsetup && aptupdate && aptinstall && shellinstall && fontinstall && nvminstall && npminstall && atominstall && aptclean'
	alias update='baseupdate && aptupdate && aptclean'

	# System
	alias resetfirefox="rm ~/.mozilla/firefox/*.default/.parentlock"
fi

# NVM
alias loadnvm='export NVM_DIR=~/.nvm && source ~/.nvm/nvm.sh'
if [[ -s ~/.nvm/nvm.sh ]]; then
	loadnvm
fi

# Installers
alias editprofile='edit ~/.profile ~/.*profile ~/.*rc'
alias usezsh='chpass -u $USER -s $(which zsh)'
alias ohmyzshinstall='curl -L http://install.ohmyz.sh | sh'
alias zshinstall='ohmyzshinstall && usezsh'
alias nvminstall='git clone git://github.com/creationix/nvm.git ~/.nvm && loadnvm && nvm install node && nvm alias default node && nvm use node && npm install -g npm'
alias npminstall='npm install -g npm && npm install -g coffee-script node-inspector npm-check-updates'
alias pipinstall='pip install --upgrade pip && pip install httpie'
alias geminstall='sudo gem install git-up terminal-notifier sass compass travis rhc'
# graveyard themes: chester-atom-syntax duotone-dark-syntax duotone-dark-space-syntax duotone-light-syntax duotone-snow atom-material-syntax atom-material-syntax-light atom-material-ui
# graveyard packages: markdown-preview-plus language-markdown
alias apminstall='apm install atom-beautify editorconfig file-type-icons highlight-selected indentation-indicator linter linter-coffeelint linter-csslint linter-eslint linter-flow linter-jsonlint react visual-bell'
alias apmupdate='apm update --no-confirm'
alias baseupdate='cd ~ && git pull origin master'

# Setup git configuraiton
function gitsetup {
	# General
	git config --global core.excludesfile ~/.gitignore_global
	git config --global push.default simple
	git config --global mergetool.keepBackup false
	git config --global color.ui auto

	# Authentication
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
}

# Setup binary files
function binsetup {
	# Atom
	if [[ -d $HOME/Applications/Atom.app ]]; then
		if ! command_exists atom; then
			ln -s "$HOME/Applications/Atom.app/Contents/Resources/app/atom.sh" "$HOME/bin/atom"
			ln -s "$HOME/Applications/Atom.app/Contents/Resources/app/apm/bin/apm" "$HOME/bin/apm"
			editorsetup
		fi
	fi

	# GitHub
	if [[ -d $HOME/Applications/GitHub.app ]]; then
		if ! command_exists github; then
			ln -s "$HOME/Applications/GitHub Desktop.app/Contents/MacOS/github_cli" "$HOME/bin/github"
		fi
	fi

	# Git Scan
	if ! command_exists git-scan; then
		curl -LsS "https://download.civicrm.org/git-scan/git-scan.phar" -o "$HOME/bin/git-scan"
		chmod +x "$HOME/bin/git-scan"
	fi
}

# Setup a SSH Key
function newsshkey {
	if test -n "$1"; then
		local name=$1

		local comment=$name
		if test -n "$2"; then
			comment=$2
		fi

		local path=$HOME/.ssh/$name
		rm -f "$path*"
		echo "Creating new ssh-key at $path with comment $comment"
		ssh-keygen -t rsa -b 4096 -C "$comment" -f "$path"
		eval "$(ssh-agent -s)"
		ssh-add "$path"
		cat "$path.pub"
	else
		echo "newsshkey KEY_NAME [YOUR_EMAIL]"
	fi
}

# All loaded and configured
# To install and configure a new machine, type `install`
# To update an existing machine type `update`

# Now time for any additional helpers that are not necessary for the above,
# but are there to assist the user


###
# Helpers

# Get current directory
function dir {
	basename "`pwd`"
}

# Highlight clipboard code as RTF for keynote
# styles: https://help.farbox.com/pygments.html
alias highlight="pbpaste | pygmentize -g -f rtf -O 'fontface=Monaco,style=tango' | pbcopy"

# Tar
alias mktar='tar -cvzf'
alias extar='tar -xvzf'

# Database
alias startredis='redis-server /usr/local/etc/redis.conf'
alias startmongo='mongod --config /usr/local/etc/mongod.conf'

# Servers
alias serve='python -m SimpleHTTPServer 8000'

# Compliance
alias php5='php'
alias make="make OS=$OS OSTYPE=$OSTYPE"

# Node
alias npmus='npm set registry http://registry.npmjs.org/'
alias npmau='npm set registry http://registry.npmjs.org.au/'
alias npmeu='npm set registry http://registry.npmjs.eu/'
alias npmcn='npm set registry http://r.cnpmjs.org/'
alias nake='npm run-script'
alias npmio='npm install --cache-min 999999999'

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
alias gitclean='rm -rf .git/refs/original/; git reflog expire --expire=now --all; git gc --prune=now; git gc --aggressive --prune=now'
alias gitsvnupdate='git-svn rebase'
alias gpo='gp origin; gp origin --tags'
alias gitrm='git ls-files --deleted | xargs git rm'
alias git-svn='git svn'
alias gitsync='git checkout dev && git merge master; git checkout master && git merge dev; git checkout dev; git push origin --all && git push origin --tags'
alias gup='git pull origin'
alias gap='git remote | xargs -L1 git push'

# Download and extract a github repository rather than cloning it, should be faster if you don't need git history
function gitdown {
	local repo=`echo "$1" | sed "s/https:\/\/github.com\///" | sed "s/.git//"`
	local file=`basename "$repo"`
	rm -Rf $file $file.tar.gz && mkdir -p $file && cd $file && down "https://github.com/$repo/archive/master.tar.gz" -O $file.tar.gz && tar -xvzf $file.tar.gz && mv *-master/* . && rm -Rf *-master $file.tar.gz && cd ..
}

# Download a file from a github repo
function gdown {
	down https://raw.githubusercontent.com/$1
}

# Clone a list of repositories
function clone {
	for ARG in $*
	do
		hub clone $ARG
	done
}

# Downloading
function wdown {
	http -c -d $1 -o $2
}
function down {
	if command_exists aria2c; then
		aria2c -c --allow-overwrite=true --auto-file-renaming=false $1
	elif command_exists wget; then
		wget -N $1
	elif command_exists curl; then
		curl -OL $1
	fi
}
alias download='down'

# Wget
alias wgett='echo -e "\nHave you remembered to correct the following:\n user agent, trial attempts, timeout, retry and wait times?\n\nIf you are about to leech use:\n [wgetbot] to brute-leech as googlebot\n [wgetff]  to slow-leech  as firefox (120 seconds)\nRemember to use -w to customize wait time.\n\nPress any key to continue...\n" ; read -n 1 ; wget --no-check-certificate'
alias wgetbot='wget -t 2 -T 15 --waitretry 10 -nc --user-agent="Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"'
alias wgetff='wget -t 2 -T 15 --waitretry 10 -nc -w 120 --user-agent="-user-agent="Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.1.6) Gecko/20070725 Firefox/2.0.0.6""'

# Get the geocoordinates of a location
function geocode {
	open "https://api.tiles.mapbox.com/v3/examples.map-zr0njcqy/geocode/$1.json"
}

# Merge videos in current directory
function vmerge {
	ffmpeg -f concat -safe 0 -i <(for f in *m4v; do echo "file '$PWD/$f'"; done) -c copy `dir`.m4v
	mv `dir`.m4v ..
}

# Get stats on a java program
function jstats {
	if command_exists javac; then
		javac "$1.java"
		echo "compiled $1.class"
		if command_exists javap; then
			javap -c "$1" > "$1.javap"
			echo "compiled $1.javap"
		else
			echo "no javap"
		fi
	else
		echo "no javac"
	fi
	if command_exists rsm; then
		rsm -c "$1.java" > "$1.rsm"
		echo "compiled $1.rsm"
	else
		echo "no rsm"
	fi
}

# Administration
alias edithooks='edit .git/hooks/pre-commit'
alias sha1check='openssl sha1 '
alias takeownership='sudo chown -R $USER .'
alias svnshowexternals='svn propget -R svn:externals .'
alias rmsvn='sudo find . -name ".svn" -exec rm -Rf $1 {} \;'
alias rmtmp='sudo find ./* -name ".tmp*" -exec rm -Rf $1 {} \;'
alias rmsync='sudo find . -name ".sync" -exec rm -Rf $1 {} \;'
alias rmmodules='sudo find ./* -name "node_modules" -exec rm -Rf $1 {} \;'
alias rmall='rm -fdR'
alias search='find . -name'
alias allow='chmod +x'
alias sha256='shasum -a 256'
