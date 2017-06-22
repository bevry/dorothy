#!/usr/bin/env sh

# Google Cloud SDK
# https://cloud.google.com/functions/docs/quickstart
# brew cask install google-cloud-sdk
# gcloud components install alpha
# gcloud init

if is_dir "$BREW_CASKROOM/google-cloud-sdk"; then
	if is_bash; then
		# shellcheck disable=SC1090
		source "$BREW_CASKROOM/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc"
		# shellcheck disable=SC1090
		source "$BREW_CASKROOM/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc"

	elif is_zsh; then
		# shellcheck disable=SC1090
		source "$BREW_CASKROOM/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"
		# shellcheck disable=SC1090
		source "$BREW_CASKROOM/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc"
	fi
fi