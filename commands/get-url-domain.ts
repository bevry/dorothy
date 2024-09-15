#!/usr/bin/env -S deno run --quiet --no-config

if (Deno.args.length === 0) throw new Error('USAGE: get-url-domain.ts <url>')

for (const input of Deno.args) {
	const url = new URL(input)
	const domain = url.protocol + '//' + url.host
	console.log(domain)
}
