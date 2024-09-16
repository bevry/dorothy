#!/usr/bin/env -S deno run --quiet --no-config --no-lock --no-npm --no-remote --cached-only
const coder = Deno.args[0] === 'decode' ? decodeURI : encodeURI
const url = Deno.args[1]
console.log(coder(url))
