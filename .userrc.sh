export LOADEDDOTFILES="$LOADEDDOTFILES .userrc.sh"

###
# Configuration

###
# Functions

# Check if a Command Exists
function command_exists {
	type "$1" &> /dev/null
}

# Create a SSH Key
function newsshkey {
	if test -n "$1"; then
		local name=$1

		if test -n "$2"; then
			local email="b@lupton.cc"
		else
			local email=$2
		fi
		local path=$HOME/.ssh/$name
		ssh-keygen -t rsa -b 4096 -C "$email" -f "$path"
		eval "$(ssh-agent -s)"
		ssh-add "$path"
	else
		echo "newsshkey KEY_NAME [YOUR_EMAIL]"
	fi
}

# Flush DNS
function flushdns {
	# https://support.apple.com/en-us/HT202516
	sudo killall -HUP mDNSResponder
	sudo dscacheutil -flushcache
	sudo discoveryutil mdnsflushcache
}

# Configuration Git
function setupgit {
	###
	# Git Configuration

	# General
	git config --global core.excludesfile ~/.gitignore_global
	git config --global push.default simple
	git config --global mergetool.keepBackup false
	git config --global color.ui auto
	git config --global hub.protocol https

	# Signing Key
	# https://github.com/keybase/keybase-issues/issues/2182#issuecomment-206409733
	if test -n "$GIT_SIGNING_KEY"; then
		git config --global commit.gpgsign true
		# git config --global push.gpgsign true
		# ^ github doesn't support this, will do: fatal: the receiving end does not support --signed push
		git config --global user.signingkey $GIT_SIGNING_KEY
		git config --global gpg.program $(which gpg)
 		echo "no-tty" >> ~/.gnupg/gpg.conf
		# ^ http://github.com/isaacs/github/issues/675
	fi

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

# Clone each repo
function clone {
	for ARG in $*
	do
		hub clone $ARG
	done
}

# Get current directory
function dir {
	basename "`pwd`"
}

# Merge videos in current directory
function vmerge {
	ffmpeg -f concat -safe 0 -i <(for f in *m4v; do echo "file '$PWD/$f'"; done) -c copy `dir`.m4v
	mv `dir`.m4v ..
}

# Java
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

###
# Environemnt

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

# Aliases: OSX
if [[ "$OS" = "Darwin" ]]; then
	# System
	alias stackhighlightyes='defaults write com.apple.dock mouse-over-hilte-stack -boolean yes ; killall Dock'
	alias stackhighlightno='defaults write com.apple.dock mouse-over-hilte-stack -boolean no ; killall Dock'
	alias showallfilesyes='defaults write com.apple.finder AppleShowAllFiles TRUE ; killall Finder'
	alias showallfilesno='defaults write com.apple.finder AppleShowAllFiles FALSE ; killall Finder'
	alias autoswooshyes='defaults write com.apple.Dock workspaces-auto-swoosh -bool YES ; killall Dock'
	alias autoswooshno='defaults write com.apple.Dock workspaces-auto-swoosh -bool NO ; killall Dock'
	alias nodesktopicons='defaults write com.apple.finder CreateDesktop -bool false'
	alias edithosts='sudo edit /etc/hosts'

	# Install
	alias brewinit='ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
	alias brewinstall='brew install aria2 bash heroku git git-extras gnupg python ruby tree wget watchman hub vim zsh'
	alias caskinit='brew untap caskroom/cask; brew install caskroom/cask/brew-cask && brew tap caskroom/fonts'
	alias caskinstall='echo "User applications should now be manually installed to ~/Applications — https://gist.github.com/balupton/5259595"'
	alias fontinstall='brew cask install font-fira-mono font-fira-code font-ubuntu font-droid-sans font-lato font-maven-pro font-source-code-pro font-open-sans font-montserrat'
	alias updatebrew='brew update && brew upgrade && brew cleanup && brew cask cleanup'
	alias install='setupgit && brewinit && brewinstall && caskinit && caskinstall && fontinstall && nvminstall && npminstall && geminstall && pipinstall && apminstall'

	# Font Seaching
	alias fontlist='brew cask search /font-/'

	# MD5
	alias md5sum='md5 -r'

	# iOS Simulator
	if [ -d "$HOME/Applications/Xcode-beta.app" ]; then
		alias iosdev='open ~/Applications/Xcode-beta.app/Contents/Developer/Applications/Simulator.app'
	elif [ -d "$HOME/Applications/Xcode.app" ]; then
		alias iosdev='open ~/Applications/Xcode.app/Contents/Applications/iPhone\ Simulator.app'
	elif [ -d "/Applications/Xcode.app" ]; then
		alias iosdev='open /Applications/Xcode.app/Contents/Applications/iPhone\ Simulator.app'
	else
		alias iosdev='echo "Xcode is not installed"'
	fi

	# Android Simulator
	if [ -d "/Applications/Android\ Studio.app" ]; then
		alias androiddev='/Applications/Android\ Studio.app/sdk/tools/emulator -avd basic'
	else
		alias androiddev='echo "Android Studio is not installed"'
	fi

	# Apps
	mkdir -p ~/bin
	mkdir -p ~/Applications

	# Brew Cask Location
	export HOMEBREW_CASK_OPTS="--appdir=~/Applications --caskroom=~/Applications/Caskroom --binarydir=~/bin"

	# BRew Locations
	if command_exists brew; then
		# Brew Python Location
		export PKG_CONFIG_PATH=$(brew --prefix python3)/Frameworks/Python.framework/Versions/3.4/lib/pkgconfig
	fi

	# Atom Location
	#export ATOM_PATH="/Users/$USER/Applications"

# Aliases: Linux
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
	alias aptinstall='sudo apt-get install -y curl build-essential openssl libssl-dev git python ruby httpie vim'
	alias exposeinstall='sudo apt-get install -y compiz compizconfig-settings-manager compiz-plugins-extra compiz-plugins-main compiz-plugins'
	alias solarizedinstall='cd ~ && git clone git://github.com/sigurdga/gnome-terminal-colors-solarized.git && cd gnome-terminal-colors-solarized && chmod +x install.sh && cd ~ && rm -Rf gnome-terminal-colors-solarized'
	alias atominstall='sudo add-apt-repository -y ppa:webupd8team/atom && sudo apt-get update -y && sudo apt-get install -y atom && apminstall'
	alias shellinstall='sudo apt-get -y update && sudo apt-get install -y libnotify-bin libgnome-keyring-dev'
	alias install='setupgit && updateinstall && aptinstall && shellinstall && fontinstall && nvminstall && npminstall && atominstall && cleaninstall'
	alias updateinstall='sudo apt-get update -y && sudo apt-get upgrade -y'
	alias cleaninstall='sudo apt-get clean -y && sudo apt-get autoremove -y'
	alias removeinstall='sudo apt-get remove -y --purge libreoffice* rhythmbox thunderbird shotwell gnome-mahjongg gnomine gnome-sudoku gnome-mines aisleriot imagemagick && cleaninstall'

	# System
	alias resetfirefox="rm ~/.mozilla/firefox/*.default/.parentlock"
fi

# Custom
if [[ -s ~/.userenv.sh ]]; then
	source ~/.userenv.sh
fi

# RBEnv
if command_exists rbenv; then
	eval "$(rbenv init -)"
fi

# NVM
alias loadnvm='export NVM_DIR=~/.nvm && source ~/.nvm/nvm.sh'
if [[ -s ~/.nvm/nvm.sh ]]; then
	loadnvm
fi


###
# Aliases

# Aliases: install
alias usezsh='chpass -u $USER -s $(which zsh)'
alias ohmyzshinstall='curl -L http://install.ohmyz.sh | sh'
alias zshinstall='ohmyzshinstall && usezsh'
alias nvminstall='git clone git://github.com/creationix/nvm.git ~/.nvm && loadnvm && nvm install node && nvm alias default node && nvm use node && npm install -g npm'
alias npminstall='npm install -g npm && npm install -g coffee-script npm-check-updates node-inspector'
alias pipinstall='pip install --upgrade pip && pip install httpie'
alias geminstall='sudo gem install git-up terminal-notifier sass compass travis rhc'
alias apminstall='apm install chester-atom-syntax duotone-dark-syntax duotone-dark-space-syntax duotone-light-syntax duotone-snow atom-material-syntax atom-material-syntax-light atom-material-ui editorconfig file-type-icons highlight-selected indentation-indicator linter linter-coffeelint linter-csslint linter-eslint linter-flow linter-jsonlint react visual-bell'

# Aliases: db
alias startredis='redis-server /usr/local/etc/redis.conf'
alias startmongo='mongod --config /usr/local/etc/mongod.conf'

# Aliases: System
alias serve='python -m SimpleHTTPServer 8000'
alias reload='cd ~ && git pull origin master && source ~/.userrc.sh'
alias bye='exit'
alias editprofile='edit ~/.profile ~/.*profile ~/.*rc'
alias edithooks='edit .git/hooks/pre-commit'
#alias restartaudio="sudo kill `ps -ax | grep 'coreaudiod' | grep 'sbin' |awk '{print $1}'`"

# Aliases: Compliance
alias php5='php'
alias make="make OS=$OS OSTYPE=$OSTYPE"

# Aliases: Node
alias npmus='npm set registry http://registry.npmjs.org/'
alias npmau='npm set registry http://registry.npmjs.org.au/'
alias npmeu='npm set registry http://registry.npmjs.eu/'
alias npmcn='npm set registry http://r.cnpmjs.org/'
alias nake='npm run-script'

# Aliases: Git
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
gitdown() {
	rm -Rf $2 $2.tar.gz && mkdir -p $2 && cd $2 && wget "https://github.com/$1/archive/master.tar.gz" -O $2.tar.gz && tar -xvzf $2.tar.gz && mv *-master/* . && rm -Rf *-master $2.tar.gz && cd ..
}

# Aliases: Downloading
function wdown {
	http -c -d $1 -o $2
}
alias down='aria2c'

# # Aliases: Wget
alias wgett='echo -e "\nHave you remembered to correct the following:\n user agent, trial attempts, timeout, retry and wait times?\n\nIf you are about to leech use:\n [wgetbot] to brute-leech as googlebot\n [wgetff]  to slow-leech  as firefox (120 seconds)\nRemember to use -w to customize wait time.\n\nPress any key to continue...\n" ; read -n 1 ; wget --no-check-certificate'
alias wgetbot='wget -t 2 -T 15 --waitretry 10 -nc --user-agent="Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"'
alias wgetff='wget -t 2 -T 15 --waitretry 10 -nc -w 120 --user-agent="-user-agent="Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.1.6) Gecko/20070725 Firefox/2.0.0.6""'

# Aliases: Geocoding
function geocode {
	open "https://api.tiles.mapbox.com/v3/examples.map-zr0njcqy/geocode/$1.json"
}

# Aliases: Tar
alias mktar='tar -cvzf'
alias extar='tar -xvzf'

# Aliases: Administration
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

# Aliases: Copy
if command_exists xclip; then
	alias copy='pbcopy '
elif command_exists pbcopy; then
	alias copy='pbcopy '
fi
