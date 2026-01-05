#!/usr/bin/env -S eval-wsl deno run --quiet --no-config --no-lock --no-npm
import { Html5Entities } from 'https://deno.land/x/html_entities@v1.0/mod.js'
const coder =
	Deno.args[0] === 'decode' ? Html5Entities.decode : Html5Entities.encode
const url = Deno.args[1]
console.log(coder(url))
