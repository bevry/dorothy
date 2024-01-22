#!/usr/bin/env bash
# do not use `export` keyword in this file:
# shellcheck disable=SC2034

# Used by `setup-environment-commands`

# Our editors in order of preference
TERMINAL_EDITORS=(
	# editors with an obvious newb friendly UX
	'nano' # setup-util-nano
	# editors with an extremely obtuse UX,
	# that is, requires more than 5 seconds for a newb to save and quit a file
	# sorted by popularity of conventions, then by modernness of the tool of that convention
	'nvim'  # setup-util-neovim (49k stars)
	'vim'   # setup-util-vim
	'vi'    # commonly bundled, only worthwhile if vim is missing
	'micro' # setup-util-micro (18k stars)
	'emacs' # setup-util-emacs (3k stars)
	'amp'   # setup-util-amp (3k stars)
	'ne'    # setup-util-ne (300 stars)
)
GUI_EDITORS=(
	'code' # setup-util-vscode
	'atom'
	'subl'
	'gedit'             # linux default
	'gnome-text-editor' # fedora default
	'TextEdit'          # macos default
)

# editors with complicated install instructions:
# https://github.com/syl20bnr/spacemacs#install

# dead editors:
# https://github.com/gphalkes/tilde
# https://github.com/gchp/iota
# https://github.com/curlpipe/ox
# https://github.com/slap-editor/slap/issues/413

# @todo add support for these:
# https://github.com/lapce/lapce
# https://github.com/helix-editor/helix
# https://github.com/syl20bnr/spacemacs
# https://github.com/xi-editor/xi-editor
# https://github.com/NvChad/NvChad
