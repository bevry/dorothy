#!/usr/bin/env bash

function shellsetup {
	usesh fish
}
function nvminstall {
	set -e
	if is_dir "$HOME/.nvm"; then
		nvmupdate
	else
		echo "installing nvm..."
		git clone git://github.com/creationix/nvm.git "$HOME/.nvm"
		source "$HOME/.scripts/sources/nvm.bash"
	fi
}
function nodeinstall {
	set -e
	nvminstall
	nvm install node
	nvm alias default node
	nvm use node
	npminstall
}
function nvmupdate {
	set -e
	echo "updating nvm..."
	cd "$HOME/.nvm"
	git checkout master
	git pull origin master
	cd "$HOME"
}
function npminstall {
	set -e
	npm install -g npm
	npm install -g yarn
	local packages='npm-check-updates live-server ci-watch'  # slap
	nigr $packages || echo "is fine"  # https://github.com/yarnpkg/yarn/issues/2993#issuecomment-289703085
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
function ohmyzshinstall {
	sh -c "$(curl -fsSL https://install.ohmyz.sh)"
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
