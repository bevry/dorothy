#!/usr/bin/env bash
# do not use `export` keyword in this file:
# shellcheck disable=SC2034

# Used by `setup-shell`

# Our shells in order of preference
USER_SHELLS=(
	fish  # fish shell
	zsh   # Z shell
	bash  # bourne again shell
	nu    # nushell
	xonsh # python-powered	 shell
	sh    # bourne shell
	ash   # almquist shell
	dash  # debian almquist shell
	ksh   # korn shell
	hush  # hush, an independent implementation of a Bourne shell for BusyBox
)
