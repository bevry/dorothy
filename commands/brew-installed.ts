#!/usr/bin/env -S deno run --quiet --no-config
// deno-lint-ignore-file no-explicit-any

// parse stdin
const json = await new Response(Deno.stdin.readable).json()

// prepare result
const names = new Set<string>()

// add casks if not filtered to only formula
if (Deno.args.includes('--formula') === false) {
	// all casks are by request, so no need for special --requested handling for casks
	for (const cask of json.casks.filter((i: any) => i.installed)) {
		names.add(cask.full_token)
	}
}

// add formulas if not filtered to only casks
if (Deno.args.includes('--cask') === false) {
	if (Deno.args.includes('--requested')) {
		// only requested formula
		for (const formula of json.formulae) {
			if (formula.installed.find((i: any) => i.installed_on_request)) {
				names.add(formula.full_name)
			}
		}
	} else {
		// all formula
		for (const formula of json.formulae.filter((i: any) => i.installed)) {
			names.add(formula.full_name)
		}
	}
}

// output result
if (names.size) {
	await Deno.stdout.write(
		new TextEncoder().encode(Array.from(names).sort().concat('').join('\n')),
	)
}
