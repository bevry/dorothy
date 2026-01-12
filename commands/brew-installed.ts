#!/usr/bin/env -S eval-wsl deno run --quiet --no-config --no-lock --no-npm --no-remote --cached-only
// deno-lint-ignore-file no-explicit-any

// parse stdin
const json = await new Response(Deno.stdin.readable).json()

// prepare result
const names = new Set<string>()

// type
const type: 'cask' | 'formula' | 'tap' | '' = Deno.args.includes('--type=cask')
	? 'cask'
	: Deno.args.includes('--type=formula')
		? 'formula'
		: Deno.args.includes('--type=tap')
			? 'tap'
			: ''

// add taps if desired
if (['tap'].includes(type)) {
	// all taps are by request
	const taps = json || []
	for (const tap of taps.filter((i: any) => i.installed)) {
		names.add(tap.name)
	}
}

// add casks if desired
if (['', 'cask'].includes(type)) {
	// all casks are by request
	const casks = json.casks || []
	for (const cask of casks.filter((i: any) => i.installed)) {
		names.add(cask.full_token)
	}
}

// add formulas if desired
if (['', 'formula'].includes(type)) {
	// formulas could be by request, or by dependency
	const formulae = json.formulae || []
	if (Deno.args.includes('--requested')) {
		// only requested formula
		for (const formula of formulae) {
			if (formula.installed.find((i: any) => i.installed_on_request)) {
				names.add(formula.full_name)
			}
		}
	} else {
		// all formula
		for (const formula of formulae.filter((i: any) => i.installed)) {
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
