#!/bin/bash

# Installers
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
	nig npm-check-updates
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