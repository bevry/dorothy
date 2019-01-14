#!/usr/bin/env bash
source "$HOME/.scripts/sources/globstar.bash"
source "$HOME/.scripts/users/balupton/source.sh"

export TERMINAL_EDITORS=(
	vim  # --noplugin -c "set nowrap"'
	micro
	nano
)

export GUI_EDITORS=(
	"code -w"
	"atom -w"
	"subl -w"
	gedit
)

export APK_INSTALL=(
	aria2
	bash
	fish
	git
	gnupg
	python
	ruby
	tree
	wget
)

export APT_REMOVE=(
	aisleriot
	gnome-mahjongg
	gnome-mines
	gnome-sudoku
	gnomine
	imagemagick
	"libreoffice*"
	rhythmbox
	shotwell
	thunderbird
)

export APT_ADD=(
	build-essential
	curl
	fish
	git
	libssl-dev
	openssl
	python
	ruby
	software-properties-common
	vim
)

export BREW_INSTALL=(
	# azure-cli
	# blackbox
	# heroku
	aria2
	bash
	bash-completion
	coreutils
	fish
	git
	git-extras
	go
	hub
	kryptco/tap/kr
	mas
	micro
	pkg-config
	python
	python3
	rmtrash
	ruby
	screen
	terminal-notifier
	terraform
	tmux
	tree
	vault
	vim
	watch
	watchman
	wget
	yarn
)

export BREW_INSTALL_SLOW=(
	gpg
	shellcheck
)

export BREW_INSTALL_CASK=(
	# airparrot
	# burn
	# caption
	# ccleaner
	# dat
	# firefox
	# github-desktop
	# gitter
	# jaikoz
	# opera
	# pomello
	# reflector
	# signal
	# toggldesktop
	# torbrowser
	# transmission
	# tunnelbear
	# tunnelblick
	# usage
	# windscribe
	acorn
	adguard
	appzapper
	atom
	backblaze
	bartender
	brave
	calibre
	contexts
	devdocs
	freedom
	geekbench
	google-chrome
	google-hangouts
	keybase
	kodi
	little-snitch
	loopback
	micro-snitch
	numi
	paragon-ntfs
	plex-media-server
	screenflow
	sketch
	skype
	soundsource
	spotify
	teamviewer
	tower
	transmit
	ubersicht
	undercover
	visual-studio-code
	vlc
	vmware-fusion
	webtorrent
	workflowy
	xld
)

# export RUBY_VERSION="ruby@2.3"
export RUBY_INSTALL=(
	ffi # "ffi 1.9.21"
	travis
	travis_migrate_to_apps
	sass # "sass 3.4.25"
	compass # "compass 1.0.3"
	git-up
)

export PYTHON_INSTALL=(
	setuptools
	httpie
)

export NODE_INSTALL=(
	# bevry
	"@bevry/testen"
	boundation

	# servers
	browser-refresh
	live-server
	serve

	# database
	fauna-shell

	# ecosystem
	"@stencil/core"
	apollo
	ember-cli
	firebase-tools
	ionic
	lasso-cli
	marko-cli
	marko-starter
	'now@canary'

	# tools
	eslint
	json
	npm-check-updates
	prettier
	typescript

	# continuous integration
	ci-watch
	travis-watch

	# cryptocurrency
	cartera
	coinmon
)

export VSCODE_INSTALL=(
	# akamud.vscode-theme-onedark
	# akamud.vscode-theme-onelight
	# donjayamanne.jupyter
	# flowtype.flow-for-vscode
	# julialang.language-julia
	DavidAnson.vscode-markdownlint
	dbaeumer.vscode-eslint
	EditorConfig.EditorConfig
	fatihacet.gitlab-workflow
	idleberg.applescript
	mauve.terraform
	mechatroner.rainbow-csv
	mindginative.terraform-snippets
	ms-python.python
	ms-vscode.go
	PeterJausovec.vscode-docker
	PKief.material-icon-theme
	richie5um2.vscode-sort-json
	shinnn.stylelint
	skyapps.fish-vscode
	teabyii.ayu
	timonwong.shellcheck
)

export ATOM_INSTALL=(
	city-lights-ui
	editorconfig
	file-type-icons
	highlight-selected
	indentation-indicator
	jackhammer-syntax
	language-stylus
	linter
	linter-coffeelint
	linter-csslint
	linter-eslint
	linter-flow
	linter-jsonlint
	linter-shellcheck
	react
	visual-bell
)
