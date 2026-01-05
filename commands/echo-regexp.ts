#!/usr/bin/env -S eval-wsl deno run --quiet --no-config --no-lock --no-npm --no-remote --cached-only
const flags = new Set((Deno.args[0] || '').replace(/^-/, '').split(''))
const fail = flags.has('f')
const counting = flags.has('c')
const onlyMatching = flags.has('o')
const newlines = flags.has('n')
const quiet = flags.has('q')
const verbose = flags.has('v')
if (fail) {
	flags.delete('f')
}
if (verbose) {
	flags.delete('v')
}
if (quiet) {
	flags.delete('q')
}
if (counting) {
	flags.delete('c')
}
if (onlyMatching) {
	flags.delete('o')
}
if (newlines) {
	flags.delete('n')
}
const sep = newlines ? '\n' : ''
const global = flags.has('g')
const globalFlags = new Set([...Array.from(flags), 'g'])
// rust regex to js regex
// > sd '[:blank:]' '_' <<< 'hello world'
// he__o wor_d
// > sd '[[:blank:]]' '_' <<< 'hello world'
// hello_world
const characterClasses: {
	[name: string]: string
} = {
	alnum: '0-9A-Za-z',
	alpha: 'A-Za-z',
	ascii: '\x00-\x7F',
	blank: '\t ',
	cntrl: '\x00-\x1F\x7F',
	digit: '0-9',
	graph: '!-~',
	lower: 'a-z',
	print: ' -~',
	punct: '!-/:-@[-`{-~',
	space: '\t\n\v\f\r ',
	upper: 'A-Z',
	word: '0-9A-Za-z_',
	xdigit: '0-9A-Fa-f',
}
function compatRegexpString(input: string): string {
	let wip = input.replaceAll('(?P<', '(?<')
	// convert [[:digit:][:lower:]] to [0-9a-z]
	// this also happens to convert [[:digit:]] to [0-9]
	for (const [name, value] of Object.entries(characterClasses)) {
		wip = wip.replaceAll(`[:${name}:]`, value)
	}
	return wip
}
const find = compatRegexpString(Deno.args[1] || '')
const replacements = Deno.args.slice(2).map(function (replacement) {
	return replacement.replaceAll(/\$\{([^}]+)\}/g, '$<$1>')
})
const regexp = new RegExp(find, Array.from(flags).join(''))
const globalRegexp = new RegExp(find, Array.from(globalFlags).join(''))
const input = await new Response(Deno.stdin.readable).text()
async function write(output: string) {
	return await Deno.stdout.write(new TextEncoder().encode(output))
}
let count = 0,
	countSep = ''
if (quiet || (counting && !verbose)) {
	// no replacements is same as onlyMatching
	for (const _ of input.matchAll(globalRegexp)) {
		++count
		if (global === false) break
	}
} else if (replacements.length === 0) {
	// no replacements is same as onlyMatching
	for (const match of input.matchAll(globalRegexp)) {
		await write(`${match[0]}${sep}`)
		++count
		if (global === false) break
	}
	if (counting && count !== 0 && sep !== '\n') countSep = '\n'
} else if (onlyMatching) {
	const last = replacements.length - 1
	const beyondValue = global ? replacements[last] : '$&'
	for (const match of input.matchAll(globalRegexp)) {
		const replace = count > last ? beyondValue : replacements[count]
		const replacement = match[0].replace(regexp, replace)
		// console.error({ count, match, replace, replacement })
		await write(`${replacement}${sep}`)
		++count
		if (global === false && count > last) break
	}
	if (counting && count !== 0 && sep !== '\n') countSep = '\n'
} else {
	let shouldBreak = false
	const last = replacements.length - 1
	const beyondValue = global ? replacements[last] : '$&'
	// console.error({
	// 	last,
	// 	beyondValue,
	// 	global,
	// 	globalRegexp,
	// 	input,
	// 	replacements,
	// })
	const result = input.replaceAll(globalRegexp, function (match) {
		// console.error({ shouldBreak })
		if (shouldBreak) return match
		const replace = count > last ? beyondValue : replacements[count]
		const replacement = match.replace(regexp, replace)
		// console.error({ count, match, replace, replacement })
		++count
		if (global === false && count > last) shouldBreak = true
		return replacement
	})
	if (fail && count === 0) {
		// don't write
	} else {
		await write(`${result}${sep}`)
	}
	if (counting && sep !== '\n') countSep = '\n'
}
if (counting) await write(`${countSep}${count}\n`)
if ((fail || quiet) && count === 0) {
	Deno.exit(1)
	// Deno.exitCode is Deno 1.44: https://github.com/denoland/deno/pull/23609
	// However Alpine APK is only Deno 1.43: https://pkgs.alpinelinux.org/packages?name=deno
	// So use Deno.exit instead
}
