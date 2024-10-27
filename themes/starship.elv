#!/usr/bin/env elvish

if ?( command-missing -- starship ) {
	setup-util-starship --quiet
}

eval (starship init elvish)
