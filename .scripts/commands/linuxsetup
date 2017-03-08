#!/bin/bash

# Specific Operating System Configuration: Linux
if is_linux; then

	# Installers
	function fontinstall {
		# Prepare
		set -e
		local f="$HOME/.fonts"
		local ft="$f/tmp"
		local p; p=$(pwd)
		mkdir -p "$f" "$ft"
		cd "$ft"

		# Monoid
		down https://cdn.rawgit.com/larsenwork/monoid/2db2d289f4e61010dd3f44e09918d9bb32fb96fd/Monoid.zip
		unzip Monoid.zip
		mv ./*.ttf "$f"

		# Source Code Pro
		# http://askubuntu.com/a/193073/22776
		# https://github.com/adobe-fonts/source-code-pro
		down https://github.com/adobe-fonts/source-code-pro/archive/2.010R-ro/1.030R-it.zip
		unzip 1.030R-it.zip
		mv source-code-pro-2.010R-ro-1.030R-it/OTF/*.otf "$f"

		# Monaco
		# https://github.com/showcases/fonts
		# https://github.com/todylu/monaco.ttf
		down https://github.com/todylu/monaco.ttf/raw/master/monaco.ttf
		mv monaco.ttf "$f"

		# Refresh
		fc-cache -f -v
		cd "$p"
		rm -Rf "$ft"
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

	# Bash Autocompletion
	if is_bash; then
		if is_file /etc/bash_completion; then
			# shellcheck disable=SC1091
			source /etc/bash_completion
		fi
	fi

fi