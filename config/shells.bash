#!/usr/bin/env bash
# shellcheck disable=SC2034
# Used by `setup-shell`, use `--configure` to (re)configure this
# Do not use `export` keyword in this file

# Shells that Dorothy supports, reorder them with most preferred first
USER_SHELLS=(
	# officially supported shells
	bash # bourne again shell
	dash # debian almquist shell
	fish # fish shell
	nu   # nushell
	zsh  # Z shell
	# officially supported shells (alpha/beta quality integrations)
	elvish # elvish shell
	ksh    # korn shell
	xonsh  # python-powered shell
	# potentially supported shells
	ash  # almquist shell
	hush # hush, an independent implementation of a Bourne shell for BusyBox
	sh   # the operating-system symlinks this to any POSIX compliant shell
)
