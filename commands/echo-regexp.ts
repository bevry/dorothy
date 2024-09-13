#!/usr/bin/env -S deno run --quiet --no-config
const flags = new Set((Deno.args[0] || '').split(''))
const counting = flags.has('c')
const onlyMatching = flags.has('o')
const newlines = flags.has('n')
if (counting) {
	flags.delete('c')
	flags.add('g')
}
if (onlyMatching) {
	flags.delete('o')
}
if (newlines) {
	flags.delete('n')
}
const sep = newlines ? '\n' : ''
if (counting && onlyMatching) {
	throw new Error('Cannot use both -c and -o')
}
const global = flags.has('g')
const globalFlags = new Set([...Array.from(flags), 'g'])
// rust regex to js regex
const find = (Deno.args[1] || '')
	.replaceAll('(?P<', '(?<')
	.replaceAll('[[:alnum:]]', '[0-9A-Za-z]')
	.replaceAll('[[:alpha:]]', '[A-Za-z]')
	.replaceAll('[[:ascii:]]', '[\x00-\x7F]')
	.replaceAll('[[:blank:]]', '[\t ]')
	.replaceAll('[[:cntrl:]]', '[\x00-\x1F\x7F]')
	.replaceAll('[[:digit:]]', '[0-9]')
	.replaceAll('[[:graph:]]', '[!-~]')
	.replaceAll('[[:lower:]]', '[a-z]')
	.replaceAll('[[:print:]]', '[ -~]')
	.replaceAll('[[:punct:]]', '[!-/:-@[-`{-~]')
	.replaceAll('[[:space:]]', '[\t\n\v\f\r ]')
	.replaceAll('[[:upper:]]', '[A-Z]')
	.replaceAll('[[:word:]]', '[0-9A-Za-z_]')
	.replaceAll('[[:xdigit:]]', '[0-9A-Fa-f]')
const replacements = Deno.args.slice(2).map(function (replacement) {
	return replacement.replaceAll(/\$\{([^}]+)\}/g, '$<$1>')
})
const regexp = new RegExp(find, Array.from(flags).join(''))
const globalRegexp = new RegExp(find, Array.from(globalFlags).join(''))
const input = await new Response(Deno.stdin.readable).text()
async function write(output: string) {
	return await Deno.stdout.write(new TextEncoder().encode(output))
}
if (replacements.length === 0) {
	let count = 0
	for (const match of input.matchAll(globalRegexp)) {
		if (counting === false) await write(`${match[0]}${sep}`)
		if (global === false) break
		++count
	}
	if (counting) await write(`${count}${sep}`)
} else if (onlyMatching) {
	let count = 0
	if (global === false) replacements.push('$&')
	const last = replacements.length - 1
	for (const match of input.matchAll(globalRegexp)) {
		if (counting === false)
			await write(
				match[0].replace(
					regexp,
					count >= last ? replacements[last] : replacements[count],
				) + sep,
			)
		if (global === false) break
		++count
	}
} else if (replacements.length === 1) {
	await write(input.replace(regexp, replacements[0]))
} else {
	let count = 0
	if (global === false) replacements.push('$&')
	const last = replacements.length - 1
	await write(
		input.replace(globalRegexp, function (match) {
			const result = match.replace(
				regexp,
				count >= last ? replacements[last] : replacements[count],
			)
			++count
			return result
		}),
	)
}
