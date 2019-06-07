#!/usr/bin/env bash
if [[ "$BASH_VERSION" = "4."* || "$BASH_VERSION" = "5."* ]]; then
	source "$HOME/.scripts/sources/globstar.bash"
fi
source "$HOME/.scripts/users/balupton/source.sh"

export TERMINAL_EDITORS=(
	vim # --noplugin -c "set nowrap"'
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

# https://github.com/Microsoft/vscode-go/wiki/Go-tools-that-the-Go-extension-depends-on
# https://github.com/golang/go/wiki/gopls#editors-instructions
# github.com/nsf/gocode is outdated
# github.com/alecthomas/gometalinter is outdated
export GO_INSTALL=(
	github.com/766b/go-outliner
	github.com/acroca/go-symbols
	github.com/ahmetb/govvv
	github.com/cweill/gotests
	github.com/davidrjenni/reftools/cmd/fillstruct
	github.com/fatih/gomodifytags
	github.com/go-delve/delve/cmd/dlv
	github.com/golangci/golangci-lint/cmd/golangci-lint
	github.com/gorilla/handlers
	github.com/haya14busa/goplay/cmd/goplay
	github.com/josharian/impl
	github.com/labstack/armor/cmd/armor
	github.com/labstack/echo
	github.com/mdempsky/gocode
	github.com/mgechev/revive
	github.com/ramya-rao-a/go-outline
	github.com/rogpeppe/godef
	github.com/sourcegraph/go-langserver
	github.com/sqs/goreturns
	github.com/uudashr/gopkgs/cmd/gopkgs
	github.com/zmb3/gogetdoc
	golang.org/x/lint/golint
	golang.org/x/tools/cmd/godoc
	golang.org/x/tools/cmd/goimports
	golang.org/x/tools/cmd/gopls
	golang.org/x/tools/cmd/gorename
	golang.org/x/tools/cmd/guru
	honnef.co/go/tools/cmd/...
	sourcegraph.com/sqs/goreturns
)

export BREW_INSTALL=(
	# azure-cli
	# blackbox
	# heroku
	1password-cli
	aria2
	bash
	bash-completion
	coreutils
	fish
	git
	git-extras
	git-lfs
	go
	hub
	jq
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
	# acorn
	# airparrot
	# appzapper
	# atom
	# bartender
	# brave
	# burn
	# caption
	# ccleaner
	# contexts
	# dat
	# devdocs
	# firefox
	# freedom
	# geekbench
	# github-desktop
	# gitter
	# jaikoz
	# julia
	# keybase
	# kodi
	# micro-snitch
	# numi
	# opera
	# paragon-ntfs
	# plex-media-server
	# reflector
	# signal
	# skype
	# teamviewer
	# toggldesktop
	# torbrowser
	# transmission
	# transmit
	# tunnelbear
	# tunnelblick
	# ubersicht
	# usage
	# vlc
	# webtorrent
	# windscribe
	# workflowy
	# xld
	adguard
	audio-hijack
	backblaze
	calibre
	fantastical
	google-chrome
	google-hangouts
	little-snitch
	loopback
	pomello
	screenflow
	sketch
	soundsource
	spotify
	tower
	undercover
	visual-studio-code
	vmware-fusion
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
	# "@stencil/core"
	# ionic
	# ember-cli
	# firebase-tools
	# lasso-cli
	# marko-cli
	# marko-starter
	apollo
	now

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
	silvenon.mdx
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
