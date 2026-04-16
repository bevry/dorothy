#!/usr/bin/env elvish

if ?( command-missing -- starship ) {
	setup-util-starship dependency
}

eval (starship init elvish)
