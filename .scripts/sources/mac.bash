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
		if confirm "Show all file extensions?"; then
			defaults write NSGlobalDomain AppleShowAllExtensions -boolean true
		else
			defaults delete NSGlobalDomain AppleShowAllExtensions
		fi

		# https://software.com/mac/tweaks/show-all-files-in-finder
		if confirm "Show hidden files?"; then
			defaults write com.apple.finder AppleShowAllFiles -boolean true
		else
			defaults delete com.apple.finder AppleShowAllFiles
		fi

		# https://software.com/mac/tweaks/hide-desktop-icons
		if confirm "Hide desktop icons?"; then
			defaults write com.apple.finder CreateDesktop -bool false
		else
			defaults delete com.apple.finder CreateDesktop
		fi

		# http://osxdaily.com/2012/04/11/disable-the-file-extension-change-warning-in-mac-os-x/
		if confirm "Disable extension confirm dialog?"; then
			defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
		else
			defaults delete com.apple.finder FXEnableExtensionChangeWarning
		fi

		# https://software.com/mac/tweaks/auto-hide-the-dock
		if confirm "Hide the dock automatically?"; then
			defaults write com.apple.dock autohide -boolean true
		else
			defaults delete com.apple.dock autohide
		fi
	}

	# -------------------------------------
	# Installers

	# https://github.com/caskroom/homebrew-cask/blob/master/USAGE.md#options
	export HOMEBREW_CASK_OPTS="--appdir=$HOME/Applications --caskroom=$HOME/.cache/Caskroom"
	function brewinit {
		set -e
		if command_exists brew; then
			echo "brew already installed"
		else
			echo "installing brew locally..."
			# https://github.com/Homebrew/brew/blob/master/docs/Installation.md#untar-anywhere
			mkdir -p "$HOME/.homebrew"
			curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C "$HOME/.homebrew"
			source "$HOME/.scripts/sources/paths.bash"
		fi
	}
	function caskinit {
		set -e
		echo "initialising cask..."
		brew tap caskroom/cask
		brew tap caskroom/fonts
	}
	function brewinstall {
		set -e
		echo "installing brew apps..."
		brew install aria2 bash bash-completion heroku hub fish git git-extras gpg python mas micro rmtrash ruby shellcheck tree wget watchman vim zsh
		source "$HOME/.scripts/sources/paths.bash"
	}
	function caskinstall {
		set -e
		echo "install cask apps..."
		brew cask install airparrot appzapper atom bartender brave burn calibre caption ccleaner contexts devdocs firefox freedom geekbench github-desktop jaikoz keepingyouawake kodi opera plex-media-server pomello reflector screenflow sketch skype spotify spotifree teamviewer toggldesktop torbrowser transmission tunnelbear typora usage visual-studio-code vlc vmware-fusion xld
		source "$HOME/.scripts/sources/paths.bash"
	}
	function masinstall {
		set -e
		# mas signout
		# mas signin --dialog apple@bevry.me
		echo "install mac app store paps..."
		mas install 937984704   # Amphetamine
		mas install 1121192229  # Better.fyi
		mas install 430798174   # HazeOver
		mas install 441258766   # Magnet
		mas install 1124077199  # Paws for Trello
		mas install 803453959   # Slack
		mas install 931134707   # Wire
	}
	function brewupdate {
		set -e
		echo "updating brew..."
		brew update
		brew upgrade
		brew cleanup
		brew cask cleanup
		source "$HOME/.scripts/sources/paths.bash"
	}
	function fontinstall {
		set -e
		echo "installing fonts..."
		brew cask install font-cantarell font-droid-sans font-hasklig font-lato font-fira-code font-maven-pro font-fira-mono font-monoid font-montserrat font-open-sans font-oxygen font-oxygen-mono font-roboto font-roboto-mono font-source-code-pro font-ubuntu
		# font-andale-mono failed to install
	}
	function install {
		set -e
		macsettings
		brewinit
		brewupdate
		caskinit
		brew install git
		gitsetup
		binsetup

		brewinstall
		caskinstall  # sometimes requires sudo input, so & is not an option
		masinstall
		fontinstall

		nodeinstall
		geminstall
		pipinstall
		apminstall

		vscodesetup
		binsetup
		source "$HOME/.scripts/sources/paths.bash"
		usesh bash
	}
	function update {
		set -e
		baseupdate
		brewupdate
		nvmupdate
		apmupdate
		source "$HOME/.scripts/sources/paths.bash"
	}

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
