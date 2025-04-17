#!/usr/bin/env bash
# shellcheck disable=SC2034
# Used by `edit`
# Do not use `export` keyword in this file

# Our editors in order of preference
TERMINAL_EDITORS=(
	# editors with an obvious newb friendly UX
	'nano' # setup-util-nano
	# editors with an extremely obtuse UX:
	# requires more than 5 seconds for a newb to save and quit a file
	# sorted by popularity of conventions, then by modernness of the tool of that convention
	'nvim'  # setup-util-neovim - 49k stars
	'vim'   # setup-util-vim
	'vi'    # commonly bundled, only worthwhile if vim is missing
	'micro' # setup-util-micro - 18k stars
	'emacs' # setup-util-emacs - 3k stars
	'amp'   # setup-util-amp - 3k stars
	'ne'    # setup-util-ne - 300 stars
)
GUI_EDITORS=(
	'code' # setup-util-vscode
	'zed'  # https://zed.dev
	'atom'
	'subl'
	'gedit'             # linux default
	'gnome-text-editor' # fedora default
	'TextEdit'          # macos default
)

# editors with complicated install instructions:
# https://github.com/syl20bnr/spacemacs#install - 23.8k stars

# dead editors:
# https://github.com/slap-editor/slap/issues/413 - 6.1k stars
# https://github.com/curlpipe/ox - 3.4k stars
# https://github.com/gchp/iota - 1.6k stars
# https://github.com/gphalkes/tilde - 414 stars

# @todo add support for these:
# https://github.com/helix-editor/helix - 35k stars - neovim
# https://github.com/lapce/lapce - 34.9k stars - desktop, built on XI
# https://github.com/NvChad/NvChad - 25.3k stars - neovim
# https://github.com/syl20bnr/spacemacs - 23.8k stars - emacs
# https://github.com/xi-editor/xi-editor - 19.8k stars - desktop, proof of concept
# https://github.com/mawww/kakoune - 10.1k stars - neovim
# https://github.com/jmacdonald/amp - 3.8k stars - GUI, proof of concept
# https://github.com/ilai-deutel/kibi - 1.6k stars - modal
# https://github.com/xyproto/orbiton - 500 stars - desktop
# https://github.com/craigbarnes/dte - 164 stars - modal
