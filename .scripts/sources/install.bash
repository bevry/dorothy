#!/bin/bash

function zshinstall {
	set -e
	ohmyzshinstall
	usezsh
}
function nvminstall {
	set -e
	git clone git://github.com/creationix/nvm.git ~/.nvm
	loadnvm
	nvm install node
	nvm alias default node
	nvm use node
	npm install -g npm
}
function npminstall {
	set -e
	npm install -g npm
	npm install -g yarn
	local packages='npm-check-updates'  # slap
	nigr $packages  # https://github.com/yarnpkg/yarn/issues/2993#issuecomment-289703085
	nig $packages
}
function pipinstall {
	set -e
	pip install --upgrade pip
	pip install httpie
}
function baseupdate {
	set -e
	cd ~
	git pull origin master
}
function editprofile {
	edit ~/.profile ~/.*profile ~/.*rc
}
function ohmyzshinstall {
	curl -L http://install.ohmyz.sh | sh
}
function geminstall {
	gem install git-up terminal-notifier sass compass travis rhc
}
function apminstall {
	apm install apex/apex-ui-slim atom-beautify editorconfig file-type-icons highlight-selected indentation-indicator language-stylus linter linter-coffeelint linter-csslint linter-eslint linter-flow linter-jsonlint linter-shellcheck react visual-bell
}
function apmupdate {
	apm update --no-confirm
}
