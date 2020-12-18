#!/usr/bin/env bash
# this file is only loaded for bash, which is what most of the commands are coded in

# make sure when we use bash, we use globstar if it is supported
if [[ "$BASH_VERSION" = "4."* || "$BASH_VERSION" = "5."* ]]; then
	source "$BDIR/sources/globstar.bash"
fi

# load anything cross-shell useful from source.sh
source "$BDIR/users/balupton/source.sh"

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
	ruby-dev
	software-properties-common
	vim
)

export SNAP_INSTALL=(
	code
	deno
)

# https://github.com/Microsoft/vscode-go/wiki/Go-tools-that-the-Go-extension-depends-on
# https://github.com/golang/go/wiki/gopls#editors-instructions
# github.com/nsf/gocode is outdated
# github.com/alecthomas/gometalinter is outdated
export GO_INSTALL=(
	# github.com/766b/go-outliner
	# github.com/acroca/go-symbols
	# github.com/ahmetb/govvv
	# github.com/cweill/gotests
	# github.com/davidrjenni/reftools/cmd/fillstruct
	# github.com/fatih/gomodifytags
	# github.com/go-delve/delve/cmd/dlv
	# github.com/golangci/golangci-lint/cmd/golangci-lint
	# github.com/gorilla/handlers
	# github.com/haya14busa/goplay/cmd/goplay
	# github.com/josharian/impl
	# github.com/labstack/armor/cmd/armor
	# github.com/labstack/echo
	# github.com/mdempsky/gocode
	# github.com/mgechev/revive
	# github.com/nomasters/hashmap
	# github.com/ramya-rao-a/go-outline
	# github.com/rogpeppe/godef
	# github.com/sourcegraph/go-langserver
	# github.com/sqs/goreturns
	# github.com/uudashr/gopkgs/cmd/gopkgs
	# github.com/zmb3/gogetdoc
	# golang.org/x/lint/golint
	# golang.org/x/tools/cmd/godoc
	# golang.org/x/tools/cmd/goimports
	# golang.org/x/tools/cmd/gopls
	# golang.org/x/tools/cmd/gorename
	# golang.org/x/tools/cmd/guru
	# honnef.co/go/tools/cmd/...
	# sourcegraph.com/sqs/goreturns
	changkun.de/x/rmtrash
	github.com/cloudflare/utahfs/cmd/utahfs-client
)

export BREW_ARCH="x86_64"

export BREW_INSTALL=(
	# azure-cli
	# balena-cli
	# blackbox
	# heroku
	# yarn
	aria2
	bash
	bash-completion
	coreutils
	# disabled until fixed: https://github.com/Homebrew/formulae.brew.sh/issues/380
	# deno
	fish
	git
	git-extras
	git-lfs
	gh
	go
	hashicorp/tap/boundary
	hashicorp/tap/consul
	hashicorp/tap/nomad
	hashicorp/tap/terraform
	hashicorp/tap/vault
	hub
	jq
	kryptco/tap/kr
	mas
	micro
	openssh
	pkg-config
	podman
	python
	ruby
	screen
	terminal-notifier
	tmux
	tree
	vim
	watch
	watchman
	wget
)

export BREW_INSTALL_SLOW=(
	gpg
	shellcheck
)

export BREW_INSTALL_CASK=(
	# 1password-cli
	# acorn
	# adguard
	# airparrot
	# appzapper
	# atom
	# audio-hijack
	# backblaze
	# bartender
	# brave
	# burn
	# caption
	# ccleaner
	# contexts
	# dat
	# devdocs
	# fantastical
	# firefox
	# freedom
	# geekbench
	# github-desktop
	# gitter
	# google-chrome
	# google-hangouts
	# jaikoz
	# julia
	# keybase
	# kodi
	# little-snitch
	# loopback
	# micro-snitch
	# numi
	# opera
	# paragon-ntfs
	# plex-media-server
	# pomello
	# reflector
	# screenflow
	# signal
	# sketch
	# skype
	# soundsource
	# spotify
	# teamviewer
	# toggldesktop
	# torbrowser
	# tower
	# transmission
	# transmit
	# tunnelbear
	# tunnelblick
	# ubersicht
	# undercover
	# usage
	# visual-studio-code
	# vlc
	# vmware-fusion
	# webtorrent
	# windscribe
	# workflowy
	# xld
	calibre
)

# export RUBY_VERSION="ruby@2.3"
export RUBY_INSTALL=(
	compass # "compass 1.0.3"
	ffi # "ffi 1.9.21"
	git-up
	sass # "sass 3.4.25"
)

export PYTHON_INSTALL=(
	# bitcoinlib
	# cairosvg
	httpie
)

export NODE_INSTALL=(
	# bevry
	"@bevry/testen"
	boundation

	# servers
	# browser-refresh
	# live-server
	serve

	# database
	fauna-shell

	# ecosystems
	# "@stencil/core"
	# @cloudflare/wrangler
	# apollo
	# ember-cli
	# firebase-tools
	# ionic
	# lasso-cli
	# marko-cli
	# marko-starter
	# netlify-cli
	# now

	# tooling
	# typescript@next
	eslint
	json
	prettier
	tldr
	typescript

	# cryptocurrency
	# cartera
	# coinmon
)

## BAD THEMES ##
# Adophis
# After Dark
# Ardent
# Ayu
# Ayu Adaptive
# Cobalt2
# Eva
# Eye Care
# Eye Relax Theme
# Eye Relax Theme
# Fons
# IKKI
# Kimbie Dark
# Make Apps
# Night Owl Light
# Noctis
# Palenight
# Ra Eyeful
# Rainbow
# Red
# Relax Eyes
# Relax Eyes
# Relax your eyes
# Salad
# Solarized
# Tomorrow Night
# Zenburn

## BEST LIGHT THEMES ##
# An Old Hope Light
# Eyesore
# GitHub Light
# Ra Light
# Ra Spring

## BEST DARK THEMES ##
# Github Dark
# Monokai Night
# Night Owl
# PEGO Eye
# Save Eyes HC
# Save My Eyes
# Zeal
export VSCODE_INSTALL=(
	# akamud.vscode-theme-onedark
	# akamud.vscode-theme-onelight
	# ccy.ayu-adaptive
	# DavidAnson.vscode-markdownlint
	# donjayamanne.jupyter
	# fatihacet.gitlab-workflow
	# flowtype.flow-for-vscode
	# jsaulou.theme-by-language
	# julialang.language-julia
	# mindginative.terraform-snippets
	# ms-vscode.vscode-typescript-next
	# shinnn.stylelint
	# teabyii.ayu
	# Uber.baseweb
	alexlab.save-eyes-hc
	bierner.lit-html
	dbaeumer.vscode-eslint
	dbaeumer.vscode-eslint
	denoland.vscode-deno
	dotjoshjohnson.xml
	dustinsanders.an-old-hope-theme-vscode
	eamodio.gitlens
	editorconfig.editorconfig
	esbenp.prettier-vscode
	fabiospampinato.vscode-monokai-night
	fauna.faunadb
	github.github-vscode-theme
	github.vscode-pull-request-github
	golang.go
	hashicorp.terraform
	idleberg.applescript
	joonaskivikunnas.eyesore
	kqadem.zeal-theme
	mechatroner.rainbow-csv
	ms-azuretools.vscode-docker
	ms-python.python
	ms-vsliveshare.vsliveshare-pack
	pego.pego-eye
	pkief.material-icon-theme
	plievone.vscode-template-literal-editor
	rahmanyerli.ra-light
	rahmanyerli.ra-spring
	richie5um2.vscode-sort-json
	sdras.night-owl
	silvenon.mdx
	skyapps.fish-vscode
	timonwong.shellcheck
	wayou.vscode-todo-highlight
	zaphodando.save-my-eyes
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
