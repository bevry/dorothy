#!/usr/bin/env sh

# Google Cloud SDK
# https://cloud.google.com/functions/docs/quickstart
# brew cask install google-cloud-sdk
# gcloud components install alpha
# gcloud init

if is_string "$BREW_CASKROOM"; then
	GDIR="$BREW_CASKROOM/google-cloud-sdk"
else
	GDIR="$(brew --prefix)/Caskroom/google-cloud-sdk"
fi

if is_dir "$GDIR"; then
	if is_bash; then
		# shellcheck disable=SC1090
		source "$GDIR/latest/google-cloud-sdk/path.bash.inc"
		# shellcheck disable=SC1090
		source "$GDIR/latest/google-cloud-sdk/completion.bash.inc"

	elif is_zsh; then
		# shellcheck disable=SC1090
		source "$GDIR/latest/google-cloud-sdk/path.zsh.inc"
		# shellcheck disable=SC1090
		source "$GDIR/latest/google-cloud-sdk/completion.zsh.inc"
	fi
fi
