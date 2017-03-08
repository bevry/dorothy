#!/bin/bash

if is_mac; then
	# -------------------------------------
	# Settings

	function macsettings {
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

	# -------------------------------------
	# Installers

	# Brew Cask Location
	export HOMEBREW_CASK_OPTS="--appdir=$HOME/Applications --caskroom=$HOME/Applications/Caskroom"

	# Install
	alias brewinit='ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
	alias brewinstall='brew install aria2 bash bash-completion heroku hub git git-extras gpg python micro ruby shellcheck tree wget watchman vim zsh'

	function caskinit {
		brew untap caskroom/cask
		set -e
		brew install caskroom/cask/brew-cask
		brew tap caskroom/fonts
	}
	alias caskinstall='echo "User applications should now be manually installed to ~/Applications — https://gist.github.com/balupton/5259595"'

	function brewupdate {
		set -e
		brew update
		brew upgrade
		brew cleanup
		brew cask cleanup
	}

	alias fontinstall='brew cask install font-cantarell font-droid-sans font-hasklig font-lato font-fira-code font-maven-pro font-fira-mono font-monoid font-montserrat font-open-sans font-oxygen font-oxygen-mono font-roboto font-roboto-mono font-source-code-pro font-ubuntu'  # font-andale-mono failed to install

	function nvmupdate {
		set -e
		cd "$HOME/.nvm"
		git checkout master
		git pull origin master
		cd "$HOME"
	}
	function install {
		set -e
		macsettings
		brewinit
		brewinstall
		gitsetup
		caskinit
		caskinstall
		binsetup
		fontinstall
		nvminstall
		npminstall
		geminstall
		pipinstall
		apminstall
		vscodesetup
	}
	function update {
		baseupdate
		brewupdate
		nvmupdate
		apmupdate
	}

	# Perhaps use --appdir for cask: https://github.com/caskroom/homebrew-cask/blob/master/USAGE.md#options
	# Perhaps use ~/homebrew: https://github.com/Homebrew/brew/blob/master/docs/Installation.md#untar-anywhere

	# -------------------------------------
	# Helpers

	# Mac specific aliases
	alias md5sum='md5 -r'
	alias edithosts='sudo edit /etc/hosts'

	# Font Seaching
	function fontsearch {
		brew cask search /font-/ | grep "$1"
	}

	# Bash Completion
	if is_bash; then
		if command_exists brew; then
			if is_file "$(brew --prefix)/etc/bash_completion"; then
				# shellcheck disable=SC1090
				source "$(brew --prefix)/etc/bash_completion"
			fi
		fi
	fi
fi