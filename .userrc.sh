###
# Configuration


###
# Functions

# Check if a Command Exists
function command_exists {
    type "$1" &> /dev/null
}

# Configuration Git
function setupgit {
	###
	# Git Configuration

	# Configure Git
	git config --global core.excludesfile ~/.gitignore_global
	git config --global push.default simple
	git config --global mergetool.keepBackup false
	git config --global color.ui auto
	git config --global hub.protocol https

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

# DocPad Extra Branch Sync
function docpad_branch_sync {
	git checkout docpad-6.x
	git pull origin docpad-6.x
	git merge master

	git checkout master
	git pull origin master
	git merge docpad-6.x

	git checkout docpad-6.x
	git merge master

	git checkout dev
	git pull origin dev
	git merge master

	git checkout master
	git push origin --all
}



###
# Environemnt

# OS
export OS="$(uname -s)"

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

# Bash
if [[ $PROFILE_SHELL = "bash" ]]; then
	# Standard
	export RED="\[\033[0;31m\]"
	export RED_BOLD="\[\033[01;31m\]"
	export BLUE="\[\033[0;34m\]"
	export CYAN='\[\e[0;36m\]'
	export PURPLE='\[\e[0;35m\]'
	export GREEN="\[\033[0;32m\]"
	export YELLOW="\[\033[0;33m\]"
	export BLACK="\[\033[0;38m\]"
	export NO_COLOUR="\[\033[0m\]"

	# Custom
	export C_RESET='\[\e[0m\]'
	export C_TIME=$GREEN
	export C_USER=$BLUE
	export C_PATH=$YELLOW
	export C_GIT_CLEAN=$CYAN
	export C_GIT_DIRTY=$RED

	# Theme
	source "$HOME/.usertheme.sh"

elif [[ $PROFILE_SHELL = "zsh" ]]; then
	# OH MY ZSH
	#ZSH_THEME="avit"
	if [ -d "$HOME/.oh-my-zsh" ]; then
		export DISABLE_UPDATE_PROMPT=true
		export ZSH=$HOME/.oh-my-zsh
		plugins=(terminalapp osx autojump bower brew brew-cask cake coffee cp docker gem git heroku node npm nvm python ruby)
		source $ZSH/oh-my-zsh.sh
	fi

	# Custom
	export C_RESET=$reset_color
	export C_TIME=$fg[green]
	export C_USER=$fg[blue]
	export C_PATH=$fg[yellow]
	export C_GIT_CLEAN=$fg[cyan]
	export C_GIT_DIRTY=$fg[red]

	# Theme
	source "$HOME/.usertheme.sh"
fi

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
	alias brewinit='ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" && brew install caskroom/cask/brew-cask && brew tap caskroom/fonts && brew tap caskroom/fonts'
	alias brewinstall='brew install aria2 bash git git-extras python ruby wget hub zsh'
	alias caskinstall='brew cask install alfred appzapper atom bittorrent-sync dropbox firefox github google-drive google-earth google-hangouts heroku-toolbelt java lastfm mailbox opera picasa plex-media-server skype screenflow slate soundcleod steam toggldesktop transmission undercover xld xbmc vlc'
	alias updatebrew='brew update && brew upgrade && brew cleanup && brew cask cleanup'
	alias updatesublime='cd ~/Library/Application\ Support/Sublime\ Text\ 3/ && git pull origin master && ./update.sh'

	# Generic
	alias fontinstall='brew cask install font-ubuntu font-droid-sans font-lato font-source-code-pro'
	alias updateatom='rm /Library/Caches/Homebrew/atom-latest; brew cask install atom --force'
	alias install='brewinit && brewinstall && caskinstall && fontinstall && nvminstall && npminstall && geminstall && pipinstall && apminstall'

	# MD5
	alias md5sum='md5 -r'

	# Applications
	alias iosdev='open /Applications/Xcode.app/Contents/Applications/iPhone\ Simulator.app'
	alias androiddev='/Applications/Android\ Studio.app/sdk/tools/emulator -avd basic'

	# Brew Cask Location
	export HOMEBREW_CASK_OPTS="--appdir=/Applications --binarydir=/usr/local/bin"
	# export HOMEBREW_CASK_OPTS="--appdir=~/Applications --caskroom=~/Applications --binarydir=~/bin"

	# Brew Python Location
	export PKG_CONFIG_PATH=$(brew --prefix python3)/Frameworks/Python.framework/Versions/3.4/lib/pkgconfig

	# Atom Location
	#export ATOM_PATH="/Users/$USER/Applications"

# Aliases: Linux
elif [[ "$OS" = "Linux" ]]; then
	# Install
	alias aptinstall='sudo apt-get update && sudo apt-get install curl build-essential openssl libssl-dev git python python-pip ruby libnotify-bin libgnome-keyring-dev zsh'
	alias exposeinstall='sudo apt-get install compiz compizconfig-settings-manager compiz-plugins-extra compiz-plugins-main compiz-plugins'
	alias solarizedinstall='cd ~ && git clone git://github.com/sigurdga/gnome-terminal-colors-solarized.git && cd gnome-terminal-colors-solarized && chmod +x install.sh && cd ~ && rm -Rf gnome-terminal-colors-solarized'

	# Generic
	function fontinstall {
		# Prepare
		mkdir -p ~/.fonts
		mkdir /tmp/fonts
		cd /tmp/fonts

		# Source Code Pro
		wget http://downloads.sourceforge.net/project/sourcecodepro.adobe/SourceCodePro_FontsOnly-1.017.zip
		unzip SourceCodePro_FontsOnly-1.017.zip
		mv SourceCodePro_FontsOnly-1.017/OTF/*.otf ~/.fonts
		rm -Rf SourceCodePro_FontsOnly-1.017*

		# Monaco
		wget -c https://github.com/cstrap/monaco-font/raw/master/Monaco_Linux.ttf
		mv Monaco_Linux.ttf ~/.fonts

		# Refresh
		fc-cache -f -v
		cd ~
	}
	alias atominstall='sudo add-apt-repository ppa:webupd8team/atom && sudo apt-get update && sudo apt-get install atom'
	alias install='aptinstall && fontinstall && nvminstall && npminstall && geminstall && pipinstall && atominstall && apminstall && ohmyzshinstall && usezsh'

	# System
	alias resetfirefox="rm ~/.mozilla/firefox/*.default/.parentlock"
fi

# Don't check mail
export MAILCHECK=0

# Apps
mkdir -p ~/bin

# Docker Host Location (boot2docker)
export DOCKER_HOST=tcp://localhost:4243

# Custom
if [[ -s ~/.userenv.sh ]]; then
	source ~/.userenv.sh
fi

# RBEnv
if command_exists rbenv > /dev/null; then
	eval "$(rbenv init -)"
fi

# NVM
alias loadnvm='export NVM_DIR=~/.nvm && source ~/.nvm/nvm.sh'
if [[ -s ~/.nvm/nvm.sh ]]; then
	loadnvm
fi

# Hub
#if command_exists hub > /dev/null; then
#	alias git='hub'
#fi


###
# Aliases

# Aliases: install
alias usezsh='chpass -u $USER -s $(which zsh)'
alias ohmyzshinstall='curl -L http://install.ohmyz.sh | sh'
alias npminstall='npm install -g npm && npm install -g jshint csslint coffeelint coffee-script node-inspector simple-server'
alias pipinstall='pip install httpie'
alias geminstall='sudo gem install git-up terminal-notifier sass compass'
alias nvminstall='git clone git://github.com/creationix/nvm.git ~/.nvm && loadnvm && nvm install iojs && nvm install node && nvm alias default iojs && nvm use iojs'
alias apminstall='apm install linter Zen atom-pair atom-detect-indentation autoclose-html docs-snippets editorconfig emmet file-type-icons git-blame highlight-selected language-jade language-handlebars linter-coffeelint linter-csslint linter-js-yaml linter-jshint linter-jsonlint linter-tidy merge-conflicts open-in-browser open-in-github-app react sort-lines symbols-tree-view toggle-quotes visual-bell pen-paper-coffee-syntax unity-ui'

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
if command_exists nvm; then
	alias nta4='nvm use 0.4 && npm test && nvm use 0.6 && npm test && nvm use 0.8 && npm test'
	alias nta6='nvm use 0.6 && npm test && nvm use 0.8 && npm test'
fi
alias npmusa='npm set registry http://registry.npmjs.org/'
alias npmaus='npm set registry http://registry.npmjs.org.au/'
alias npmpublish='npmusa; npm publish; npmaus'
alias cakepublish='npmusa; cake publish; npmaus'

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

# Aliases: Misc
function wdown {
	http -c -d $1 -o $2
}
alias down='aria2c'
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
alias flushdns='dscacheutil -flushcache'
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

###
# Unused

# # Sublime
# if [ ! -f ~/bin/subl ]; then
# 	if [ -f "/opt/sublime_text_2/sublime_text" ]; then
# 		ln -s "/opt/sublime_text_2/sublime_text" ~/bin/subl
# 	elif [ -f "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" ]; then
# 		ln -s "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" ~/bin/subl
# 	fi
# 	# if sublime is installed via brew cask, then symlink will be created for us
# fi

# # Airmail
# export airmailPrefDirUser="$HOME/Library/Containers/it.bloop.airmail.beta8/Data/Library/Application Support/Airmail/General"
# export airmailPrefDirSync="$HOME/Dropbox/Preferences/Airmail"
# function airmail_to_sync {
# 	mkdir -p "$airmailPrefDirSync"
# 	rm "$airmailPrefDirSync/prefs"
# 	rm "$airmailPrefDirSync/Accounts.db"
# 	cp "$airmailPrefDirUser/prefs" "$airmailPrefDirSync/prefs"
# 	cp "$airmailPrefDirUser/Accounts.db" "$airmailPrefDirSync/Accounts.db"
# }
# function sync_to_airmail {
# 	mkdir -p "$airmailPrefDirUser"
# 	rm "$airmailPrefDirUser/prefs"
# 	rm "$airmailPrefDirUser/Accounts.db"
# 	cp "$airmailPrefDirSync/prefs" "$airmailPrefDirUser/prefs"
# 	cp "$airmailPrefDirSync/Accounts.db" "$airmailPrefDirUser/Accounts.db"
# }

# # Aliases: App Fog
# if command_exists af; then
# 	alias afs='af logs $1; af crashes $1; af files $1'
# 	alias afd='af delete $1; af push $1; af start $1'
# 	alias afu='af update $1; af start $1'
# 	afpush() { af update $@; aflog $@; }
# 	aflog() { af logs $@; af crashlogs $@; af instances $@; }
# fi

# Aliases: Minify
# minify() {
#	rm -f $1.min.js $1.min.map;
#	uglifyjs $1.js -o $1.min.js --source-map $1.min.map;
# }

# # Aliases: Rails
# alias dierails='ps -a|grep "/usr/local/bin/ruby script/server"|grep -v "grep /usr"|cut -d " " -f1|xargs -n 1 kill -KILL $1'
# alias resetrails='ps -a|grep "/usr/local/bin/ruby script/server"|grep -v "grep /usr"|cut -d " " -f1|xargs -n 1 kill -HUP $1'

# # Alises: Zend
# if command_exists zendctl.sh; then
# 	alias restartzend='sudo zendctl.sh restart'
# 	alias startzend='sudo zendctl.sh start'
# 	alias startzendx='startzend; mysqld'
# 	alias stopzend='sudo zendctl.sh stop'
# 	alias cleanzend='sudo rm -Rf /usr/local/zend /etc/my.cnf /tmp/mysql.sock'
# 	alias postinstallzend='sudo rm -f /tmp/mysql.sock /etc/my.cnf ; sudo ln -s /usr/local/zend/mysql/tmp/mysql.sock /tmp/mysql.sock ; sudo ln -s /usr/local/zend/mysql/data/my.cnf /etc/my.cnf'
# 	alias mysql='/usr/local/zend/mysql/bin/mysql'
# 	alias mysqladmin='/usr/local/zend/mysql/bin/mysqladmin'
# 	alias editmysql='edit /usr/local/zend/mysql/support-files/my.cnf'
# 	alias openmysql='open /usr/local/zend/mysql/'
# 	alias openserver='open /usr/local/zend/mysql/'
# fi

# # Aliases: Wget
# alias wgett='echo -e "\nHave you remembered to correct the following:\n user agent, trial attempts, timeout, retry and wait times?\n\nIf you are about to leech use:\n [wgetbot] to brute-leech as googlebot\n [wgetff]  to slow-leech  as firefox (120 seconds)\nRemember to use -w to customize wait time.\n\nPress any key to continue...\n" ; read -n 1 ; wget --no-check-certificate'
# alias wgetbot='wget -t 2 -T 15 --waitretry 10 -nc --user-agent="Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"'
# alias wgetff='wget -t 2 -T 15 --waitretry 10 -nc -w 120 --user-agent="-user-agent="Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.1.6) Gecko/20070725 Firefox/2.0.0.6""'
