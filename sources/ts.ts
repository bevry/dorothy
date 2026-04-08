#!/usr/bin/env -S eval-wsl deno run --quiet --no-config --no-lock --no-npm --no-remote --cached-only
// this file is alpha quality, conventions will change, feedback welcome
// for instance, here's some over-engineered alternative:
// https://gist.github.com/balupton/4138b7ab3bb72caf020c061a872e1631

// style('blue', 'my blue string')
// style(`--blue=${stringvar}`)
// `styleText` now built into node, but doesn't have support for our `echo-style` comprehensive styles, and unsure of its adaptions
// throw new StyledError(style('help', 'No <action> was present.'), ' ' , style('blue', 'my blue text'))
// throw new UsageError('--help=No <action> was present.', ' ', '--blue=my blue text')

// ANSI style codes (must match styles.bash exactly)
const STYLE: Record<string, string> = {
	// Text styles
	reset: '\x1b[0m',
	bold: '\x1b[1m',
	END__bold: '\x1b[22m',
	dim: '\x1b[2m',
	END__dim: '\x1b[22m',
	italic: '\x1b[3m',
	END__italic: '\x1b[23m',
	underline: '\x1b[4m',
	END__underline: '\x1b[24m',
	double_underline: '\x1b[21m',
	END__double_underline: '\x1b[24m',
	blink: '\x1b[5m',
	END__blink: '\x1b[25m',
	invert: '\x1b[7m',
	END__invert: '\x1b[27m',
	conceal: '\x1b[8m',
	END__conceal: '\x1b[28m',
	strike: '\x1b[9m',
	END__strike: '\x1b[29m',
	framed: '\x1b[51m',
	END__framed: '\x1b[54m',
	circled: '\x1b[52m',
	END__circled: '\x1b[54m',
	overlined: '\x1b[53m',
	END__overlined: '\x1b[55m',

	// Intensity
	intensity: '\x1b[1m',
	END__intensity: '\x1b[22m',

	// Foreground colors
	foreground_black: '\x1b[30m',
	END__foreground_black: '\x1b[39m',
	foreground_red: '\x1b[31m',
	END__foreground_red: '\x1b[39m',
	foreground_green: '\x1b[32m',
	END__foreground_green: '\x1b[39m',
	foreground_yellow: '\x1b[33m',
	END__foreground_yellow: '\x1b[39m',
	foreground_blue: '\x1b[34m',
	END__foreground_blue: '\x1b[39m',
	foreground_magenta: '\x1b[35m',
	END__foreground_magenta: '\x1b[39m',
	foreground_cyan: '\x1b[36m',
	END__foreground_cyan: '\x1b[39m',
	foreground_white: '\x1b[37m',
	END__foreground_white: '\x1b[39m',
	foreground_purple: '\x1b[35m', // alias for magenta
	END__foreground_purple: '\x1b[39m',
	foreground_gray: '\x1b[37m', // alias for white
	END__foreground_gray: '\x1b[39m',
	foreground_grey: '\x1b[37m', // alias for white
	END__foreground_grey: '\x1b[39m',

	// Intense foreground colors
	foreground_intense_black: '\x1b[90m',
	END__foreground_intense_black: '\x1b[39m',
	foreground_intense_red: '\x1b[91m',
	END__foreground_intense_red: '\x1b[39m',
	foreground_intense_green: '\x1b[92m',
	END__foreground_intense_green: '\x1b[39m',
	foreground_intense_yellow: '\x1b[93m',
	END__foreground_intense_yellow: '\x1b[39m',
	foreground_intense_blue: '\x1b[94m',
	END__foreground_intense_blue: '\x1b[39m',
	foreground_intense_magenta: '\x1b[95m',
	END__foreground_intense_magenta: '\x1b[39m',
	foreground_intense_cyan: '\x1b[96m',
	END__foreground_intense_cyan: '\x1b[39m',
	foreground_intense_white: '\x1b[97m',
	END__foreground_intense_white: '\x1b[39m',
	foreground_intense_purple: '\x1b[95m', // alias for magenta
	END__foreground_intense_purple: '\x1b[39m',
	foreground_intense_gray: '\x1b[97m', // alias for white
	END__foreground_intense_gray: '\x1b[39m',
	foreground_intense_grey: '\x1b[97m', // alias for white
	END__foreground_intense_grey: '\x1b[39m',

	// Background colors
	background_black: '\x1b[40m',
	END__background_black: '\x1b[49m',
	background_red: '\x1b[41m',
	END__background_red: '\x1b[49m',
	background_green: '\x1b[42m',
	END__background_green: '\x1b[49m',
	background_yellow: '\x1b[43m',
	END__background_yellow: '\x1b[49m',
	background_blue: '\x1b[44m',
	END__background_blue: '\x1b[49m',
	background_magenta: '\x1b[45m',
	END__background_magenta: '\x1b[49m',
	background_cyan: '\x1b[46m',
	END__background_cyan: '\x1b[49m',
	background_white: '\x1b[47m',
	END__background_white: '\x1b[49m',
	background_purple: '\x1b[45m', // alias for magenta
	END__background_purple: '\x1b[49m',
	background_gray: '\x1b[47m', // alias for white
	END__background_gray: '\x1b[49m',
	background_grey: '\x1b[47m', // alias for white
	END__background_grey: '\x1b[49m',

	// Intense background colors
	background_intense_black: '\x1b[100m',
	END__background_intense_black: '\x1b[49m',
	background_intense_red: '\x1b[101m',
	END__background_intense_red: '\x1b[49m',
	background_intense_green: '\x1b[102m',
	END__background_intense_green: '\x1b[49m',
	background_intense_yellow: '\x1b[103m',
	END__background_intense_yellow: '\x1b[49m',
	background_intense_blue: '\x1b[104m',
	END__background_intense_blue: '\x1b[49m',
	background_intense_magenta: '\x1b[105m',
	END__background_intense_magenta: '\x1b[49m',
	background_intense_cyan: '\x1b[106m',
	END__background_intense_cyan: '\x1b[49m',
	background_intense_white: '\x1b[107m',
	END__background_intense_white: '\x1b[49m',
	background_intense_purple: '\x1b[105m', // alias for magenta
	END__background_intense_purple: '\x1b[49m',
	background_intense_gray: '\x1b[107m', // alias for white
	END__background_intense_gray: '\x1b[49m',
	background_intense_grey: '\x1b[107m', // alias for white
	END__background_intense_grey: '\x1b[49m',

	// Composite styles (must match styles.bash custom styles)
	header: '\x1b[1m\x1b[4m', // bold + underline
	END__header: '\x1b[22m\x1b[24m',
	header1: '\x1b[7m', // invert
	END__header1: '\x1b[27m',
	header2: '\x1b[1m\x1b[4m', // bold + underline
	END__header2: '\x1b[22m\x1b[24m',
	header3: '\x1b[1m', // bold
	END__header3: '\x1b[22m',

	success: '\x1b[32m\x1b[1m', // foreground_green + bold
	END__success: '\x1b[39m\x1b[22m',
	positive: '\x1b[32m\x1b[1m',
	END__positive: '\x1b[39m\x1b[22m',
	negative: '\x1b[31m\x1b[1m',
	END__negative: '\x1b[39m\x1b[22m',

	note: '\x1b[1m\x1b[94m', // bold + foreground_intense_blue
	END__note: '\x1b[22m\x1b[39m',

	good1: '\x1b[102m\x1b[30m', // background_intense_green + foreground_black
	END__good1: '\x1b[49m\x1b[39m',
	good2: '\x1b[1m\x1b[4m\x1b[32m', // bold + underline + foreground_green
	END__good2: '\x1b[22m\x1b[24m\x1b[39m',
	good3: '\x1b[1m\x1b[32m', // bold + foreground_green
	END__good3: '\x1b[22m\x1b[39m',

	error: '\x1b[101m\x1b[97m', // background_intense_red + foreground_intense_white
	END__error: '\x1b[49m\x1b[39m',
	error1: '\x1b[41m\x1b[97m', // background_red + foreground_intense_white
	END__error1: '\x1b[49m\x1b[39m',
	error2: '\x1b[1m\x1b[4m\x1b[31m', // bold + underline + foreground_red
	END__error2: '\x1b[22m\x1b[24m\x1b[39m',
	error3: '\x1b[1m\x1b[31m', // bold + foreground_red
	END__error3: '\x1b[22m\x1b[39m',

	notice: '\x1b[1m\x1b[4m\x1b[93m', // bold + underline + foreground_intense_yellow
	END__notice: '\x1b[22m\x1b[24m\x1b[39m',
	warning: '\x1b[1m\x1b[4m\x1b[33m', // bold + underline + foreground_yellow
	END__warning: '\x1b[22m\x1b[24m\x1b[39m',
	info: '\x1b[1m\x1b[4m\x1b[94m', // bold + underline + foreground_intense_blue
	END__info: '\x1b[22m\x1b[24m\x1b[39m',

	notice1: '\x1b[103m\x1b[30m', // background_intense_yellow + foreground_black
	END__notice1: '\x1b[49m\x1b[39m',
	notice2: '\x1b[1m\x1b[4m\x1b[33m', // bold + underline + foreground_yellow
	END__notice2: '\x1b[22m\x1b[24m\x1b[39m',
	notice3: '\x1b[1m\x1b[33m', // bold + foreground_yellow
	END__notice3: '\x1b[22m\x1b[39m',

	info1: '\x1b[44m\x1b[97m', // background_blue + foreground_intense_white
	END__info1: '\x1b[49m\x1b[39m',
	info2: '\x1b[1m\x1b[4m\x1b[34m', // bold + underline + foreground_blue
	END__info2: '\x1b[22m\x1b[24m\x1b[39m',
	info3: '\x1b[1m\x1b[34m', // bold + foreground_blue
	END__info3: '\x1b[22m\x1b[39m',

	redacted: '\x1b[40m\x1b[30m', // background_black + foreground_black
	END__redacted: '\x1b[49m\x1b[39m',
	elevate: '\x1b[93m', // foreground_intense_yellow
	END__elevate: '\x1b[39m',
	sudo: '\x1b[93m', // alias for elevate
	END__sudo: '\x1b[39m',

	code: '\x1b[90m', // foreground_intense_black
	END__code: '\x1b[39m',
	link: '\x1b[34m\x1b[4m', // foreground_blue + underline
	END__link: '\x1b[24m\x1b[39m',
	url: '\x1b[34m\x1b[4m', // alias for link
	END__url: '\x1b[24m\x1b[39m',
	path: '\x1b[33m', // foreground_yellow
	END__path: '\x1b[39m',

	END__foreground: '\x1b[39m',
	END__background: '\x1b[49m',

	// Level 1 wrappers (h1, g1, e1, n1)
	h1: '\n\x1b[7m┌  ', // newline + invert + ┌
	END__h1: '  ┐\x1b[27m',
	g1: '\x1b[102m\x1b[30m└  ',
	END__g1: '  ┘\x1b[49m\x1b[39m',
	e1: '\x1b[41m\x1b[97m└  ',
	END__e1: '  ┘\x1b[49m\x1b[39m',
	n1: '\x1b[103m\x1b[30m└  ',
	END__n1: '  ┘\x1b[49m\x1b[39m',

	// Level 2 wrappers
	h2: '\x1b[0m\x1b[1m┌  ',
	END__h2: '  ┐\x1b[0m',
	g2: '\x1b[0m\x1b[1m\x1b[32m└  ',
	END__g2: '  ┘\x1b[0m',
	e2: '\x1b[0m\x1b[1m\x1b[31m└  ',
	END__e2: '  ┘\x1b[0m',
	n2: '\x1b[0m\x1b[1m\x1b[33m└  ',
	END__n2: '  ┘\x1b[0m',

	// Level 3 wrappers
	h3: '\x1b[0m┌  ',
	END__h3: '  ┐\x1b[0m',
	g3: '\x1b[0m\x1b[32m└  ',
	END__g3: '  ┘\x1b[0m',
	e3: '\x1b[0m\x1b[31m└  ',
	END__e3: '  ┘\x1b[0m',
	n3: '\x1b[0m\x1b[33m└  ',
	END__n3: '  ┘\x1b[0m',

	// Element wrappers
	element: '\x1b[2m\x1b[1m< \x1b[22m',
	END__element: '\x1b[2m\x1b[1m >\x1b[22m',
	slash_element: '\x1b[2m\x1b[1m</ \x1b[22m',
	END__slash_element: '\x1b[2m\x1b[1m >\x1b[22m',
	element_slash: '\x1b[2m\x1b[1m< \x1b[22m',
	END__element_slash: '\x1b[2m\x1b[1m />\x1b[22m',
	fragment: '\x1b[2m\x1b[1m<>\x1b[22m',
	slash_fragment: '\x1b[2m\x1b[1m</>\x1b[22m',
}

/** Resolve a style name to its canonical STYLE key, applying aliases (e.g. red -> foreground_red). */
function resolveStyleName(name: string): string {
	// convert hyphens to underscores
	let s = name.replace(/-/g, '_')
	// foreground color shorthand aliases
	if (
		/^(black|red|green|yellow|blue|magenta|cyan|white|purple|gray|grey)$/.test(
			s,
		)
	) {
		return 'foreground_' + s
	}
	if (
		/^intense_(black|red|green|yellow|blue|magenta|cyan|white|purple|gray|grey)$/.test(
			s,
		)
	) {
		return 'foreground_intense_' + s.slice(8)
	}
	// /element -> slash_element
	if (s.startsWith('/')) {
		return 'slash_' + s.slice(1)
	}
	// element/ -> element_slash
	if (s.endsWith('/')) {
		return s.slice(0, -1) + '_slash'
	}
	return s
}

/** Resolve styles for an array of style names, returning combined begin and end codes. */
function resolveStyles(names: string[]): { begin: string; end: string } {
	let begin = ''
	let end = ''
	for (const name of names) {
		const resolved = resolveStyleName(name)
		const beginCode = STYLE[resolved]
		const endCode = STYLE['END__' + resolved]
		if (beginCode != null) {
			begin += beginCode
		}
		if (endCode != null) {
			end = endCode + end // prepend, like the bash version
		}
	}
	return { begin, end }
}

/**
 * @usage style(`--<style>=<text rendered in style>`)
 * @usage style(`--<style>+<style>=<text rendered in both styles>`)
 * @usage style(`--<style>`, `--<style>=<text rendered in both styles>`)
 * @usage style(`--<style>`, `--reset`, `--<style>=<text rendered only in the latter style>`)
 * @example style(`--red`, 'red text', `--bold=red and bold text as the red has carried over`)
 * @example style(`--error=<wrapped in STYLE.error and STYLE.END__error>`)
 * @example style(`--help=<forward to renderHelp>`)
 * @example style(`--bold=<wrapped in STYLE.bold and STYLE.END__bold>`)
 **/
export function style(...messages: Array<string | number>): string {
	// Matches the buffer model of styles.bash:__print_style
	// - flag only (--bold): opens style that carries forward via buffer_right
	// - flag+content (--bold=text): wraps content in begin/end, does not carry forward
	// - plain content: appended as-is, surrounded by any active (carried) styles
	// - combined styles (--bold+red=text): splits on +, applies all
	// - --reset: flushes accumulated carried styles
	// - --help=<template>: forwards to renderHelp
	// - --=content or --: treated as plain content

	let bufferLeft = ''
	let bufferRight = ''

	for (const msg of messages) {
		const item = String(msg)

		// determine type: content, flag, or flag+content
		let itemType: 'content' | 'flag' | 'flag+content'
		let itemFlag = ''
		let itemContent = ''

		if (item.startsWith('--=')) {
			// --=content: empty flag, just content
			itemType = 'content'
			itemContent = item.slice(3)
		} else if (!item.startsWith('--') || item === '--') {
			// not a flag, just content
			itemType = 'content'
			itemContent = item
		} else {
			// is a flag: strip the leading --
			itemFlag = item.slice(2)

			// split flag=content
			const eqIdx = itemFlag.indexOf('=')
			if (eqIdx !== -1) {
				itemType = 'flag+content'
				itemContent = itemFlag.slice(eqIdx + 1)
				itemFlag = itemFlag.slice(0, eqIdx)
			} else {
				itemType = 'flag'
			}

			// lowercase the flag
			itemFlag = itemFlag.toLowerCase()

			// split on + for combined styles, resolving each part
			const styleParts: string[] = []
			for (const part of itemFlag.split('+')) {
				// handle special dynamic styles
				if (part === 'help' || part === 'man') {
					itemContent = renderHelp(itemContent)
					continue
				}
				if (part === 'status') {
					const code = Number(itemContent)
					if (code === 0) {
						styleParts.push('good3')
					} else {
						styleParts.push('error3')
					}
					itemContent = `[${itemContent}]`
					continue
				}
				styleParts.push(part)
			}

			// resolve style codes
			const { begin, end } = resolveStyles(styleParts)

			if (itemType === 'flag') {
				// flag only: carry forward — append begin to left, prepend end to right
				bufferLeft += begin
				bufferRight = end + bufferRight
			} else {
				// flag+content: wrap content, don't carry forward
				bufferLeft += begin + itemContent + end
			}
			continue
		}

		// plain content: just append
		bufferLeft += itemContent
	}

	return bufferLeft + bufferRight
}

export function printError(...messages: Array<string | number>): string {
	return style(`--error=ERROR: `, ...messages)
}

// This is a AI conversion of Dorothy's source of truth `styles.bash:__print_help` implementation, which has tests in `echo-help`.
export function renderHelp(template: string): string {
	// Convert string to character array for character-by-character processing
	// This matches the bash version's approach of storing characters in an array
	const chars = template.split('')
	const n = chars.length
	const prefixes: string[] = Array(n).fill('')
	const suffixes: string[] = Array(n).fill('')

	// State tracking
	let inCode = false
	let inFence = false
	let inColor = false
	let inOption = false
	const intensities: string[] = []

	// Helper: check if all prior characters on line match pattern
	function arePriorCharactersMatching(
		pattern: RegExp,
		until: string,
		from: number,
	): number | null {
		let lastMatchIndex = -1
		for (let ii = from - 1; ii >= 0; ii--) {
			if (chars[ii] === until) break
			if (pattern.test(chars[ii])) {
				lastMatchIndex = ii
			} else if (chars[ii] !== ' ' && chars[ii] !== '\t') {
				return null
			}
		}
		return lastMatchIndex >= 0 ? lastMatchIndex : null
	}

	// Helper: check if all next characters match pattern until boundary
	function areNextCharactersMatching(
		pattern: RegExp,
		until: string,
		from: number,
	): number | null {
		let lastMatchIndex = -1
		for (let ii = from + 1; ii < n; ii++) {
			if (chars[ii] === until) break
			if (pattern.test(chars[ii])) {
				lastMatchIndex = ii
			} else {
				return null
			}
		}
		return lastMatchIndex >= 0 ? lastMatchIndex : null
	}

	// Helper: find next pattern index
	function findNextPatternIndex(pattern: RegExp, from: number): number | null {
		for (let ii = from + 1; ii < n; ii++) {
			if (pattern.test(chars[ii])) return ii
			if (chars[ii] === '\n') break
		}
		return null
	}

	// Helper: find prior pattern index
	function findPriorPatternIndex(pattern: RegExp, from: number): number | null {
		for (let ii = from - 1; ii >= 0; ii--) {
			if (pattern.test(chars[ii])) return ii
			if (chars[ii] === '\n') break
		}
		return null
	}

	// Helper: check if prior characters are only whitespace
	function arePriorCharactersOnlyPadding(from: number): boolean {
		//
		for (let ii = from - 1; ii >= 0; ii--) {
			if (chars[ii] === '\n') return true
			if (!/[\s]/.test(chars[ii])) return false
		}
		return true
	}

	// Helper: check if prior characters are only header (uppercase + space)
	function arePriorCharactersOnlyHeader(from: number): boolean {
		let foundMatch = false
		for (let ii = from - 1; ii >= 0; ii--) {
			if (chars[ii] === '\n') break
			if (/[A-Z ]/.test(chars[ii])) {
				foundMatch = true
			} else {
				return false
			}
		}
		return foundMatch
	}

	// Main processing loop - character by character
	for (let i = 0; i < n; i++) {
		const c = chars[i]
		const next1 = chars[i + 1] || ''
		const next2 = chars[i + 2] || ''
		const next3 = chars[i + 3] || ''
		const next4 = chars[i + 4] || ''
		const prev1 = chars[i - 1] || ''

		// Skip control sequences
		if (c === '\x1b') {
			inColor = true
			continue
		}
		if (inColor) {
			if (c === 'm') {
				inColor = false
			}
			continue
		}

		// CODE FENCE: ```
		if (c === '`' && next1 === '`' && next2 === '`') {
			chars[i] = ''
			chars[i + 1] = ''
			chars[i + 2] = ''

			// Remove fence if it's the only non-whitespace on line
			if (chars[i + 3] === '\n' && arePriorCharactersOnlyPadding(i)) {
				chars[i + 3] = ''
				const startIdx = findPriorPatternIndex(/\n/, i)
				if (startIdx !== null) {
					for (let ii = startIdx + 1; ii < i; ii++) {
						chars[ii] = ''
					}
				}
			}

			// Toggle fence
			if (!inFence) {
				inFence = true
				chars[i] = STYLE.code
			} else {
				chars[i] = STYLE.END__code
				inFence = false
			}
			continue
		}

		// If in fence, skip all other processing
		if (inFence) continue

		// LIST MARKER: * or !
		if ((c === '*' || c === '!') && next1 === ' ') {
			if (arePriorCharactersOnlyPadding(i)) {
				if (c === '*') {
					chars[i] = '•'
				} else if (c === '!') {
					const priorIdx = findPriorPatternIndex(/\n/, i)
					if (priorIdx !== null) {
						prefixes[priorIdx + 1] += STYLE.foreground_red
					} else {
						prefixes[0] += STYLE.foreground_red
					}
					chars[i] = '!'
					suffixes[i] += STYLE.END__foreground
				}
				continue
			}
		}

		// HEADER: Uppercase text ending with :
		if (c === ':' && next1 === '\n') {
			if (arePriorCharactersOnlyHeader(i)) {
				const headerStart = findPriorPatternIndex(/\n/, i)
				const startIdx = (headerStart ?? -1) + 1
				prefixes[startIdx] += STYLE.foreground_magenta
				suffixes[i] += STYLE.END__foreground
				continue
			}
		}

		// URL: <http...>
		if (c === '<' && `${next1}${next2}${next3}${next4}` === 'http') {
			const endIdx = findNextPatternIndex(/^>$/, i)
			if (endIdx !== null) {
				chars[i] = STYLE.foreground_blue + STYLE.link
				chars[endIdx] = STYLE.END__link + STYLE.END__foreground
				i = endIdx
				continue
			}
		}

		// RETURN STATUS: [0...] or [1-9...]
		if (c === '[') {
			const nextIdx = areNextCharactersMatching(/^0+$/, ']', i)
			if (nextIdx !== null) {
				prefixes[i] += STYLE.foreground_green
				suffixes[nextIdx + 1] += STYLE.END__foreground
				i = nextIdx + 1
				continue
			}
			const nextIdx2 = areNextCharactersMatching(/^[\d*]*$/, ']', i)
			if (nextIdx2 !== null) {
				prefixes[i] += STYLE.foreground_red
				suffixes[nextIdx2 + 1] += STYLE.END__foreground
				i = nextIdx2 + 1
				continue
			}
		}

		// INLINE CODE: `
		if (c === '`') {
			if (!inCode) {
				inCode = true
				chars[i] = STYLE.code
			} else {
				inCode = false
				chars[i] = STYLE.END__code
			}
			continue
		}

		// OPTIONS/ACTIONS: -, <, [, |, &, ...
		inOption = false
		switch (c) {
			case '-':
			case '<':
			case '[':
			case '|':
				inOption = true
				break
			case '&':
				if (next1 === ' ') {
					inOption = true
					chars[i] = ''
					chars[i + 1] = ''
				}
				break
			case '.':
				if (next1 === '.' && next2 === '.') {
					inOption = true
				}
				break
		}

		if (inOption && arePriorCharactersOnlyPadding(i)) {
			prefixes[i] = STYLE.foreground_magenta
			const eol = findNextPatternIndex(/^\n$/, i)
			if (eol !== null) {
				suffixes[eol] += STYLE.END__foreground
			} else {
				suffixes[n - 1] += STYLE.END__foreground
			}
		}

		// INTENSITY MODIFIERS: <, [, >, ]
		let removeIntensity = false
		switch (c) {
			case '<':
				if (![' ', '&', '(', '='].includes(next1)) {
					intensities.push(STYLE.bold)
					prefixes[i] += STYLE.bold
				}
				break
			case '[':
				if (
					!(next1 === 'a' && next2 === '-' && next3 === 'z') &&
					next1 !== ' '
				) {
					intensities.push(STYLE.dim)
					prefixes[i] += STYLE.dim
				}
				break
			case '>':
				removeIntensity = true
				break
			case ']':
				removeIntensity = true
				break
		}

		if (removeIntensity) {
			if (intensities.length === 0) {
				// Mismatched - but for now just skip
			} else if (intensities.length === 1) {
				suffixes[i] += STYLE.END__intensity
				intensities.length = 0
			} else {
				intensities.pop()
				suffixes[i] += STYLE.END__intensity + intensities.join('')
			}
		}
	}

	// Build result
	let result = ''
	for (let i = 0; i < n; i++) {
		result += prefixes[i] + chars[i] + suffixes[i]
	}

	// Trim double trailing newline
	while (result.endsWith('\n\n')) {
		result = result.slice(0, -1)
	}

	return result
}

export class CodeError extends Error {
	readonly code: number = 1
	constructor(code: number, message: string) {
		super(message)
		if (code != null) {
			this.code = code
		}
	}
}

export class HelpError extends Error {
	readonly help: string = ''
	readonly messages: string[] = []
	readonly code = 22
	constructor(...messages: string[]) {
		super()
		this.messages = messages
	}
	public override toString(): string {
		if (this.messages.length) {
			if (this.help) {
				return renderHelp(this.help) + `\n\n` + printError(...this.messages)
			} else {
				return printError(...this.messages)
			}
		} else {
			if (this.help) {
				return renderHelp(this.help)
			} else {
				throw new CodeError(
					14,
					'HelpError had no help template, nor error messages.',
				)
			}
		}
	}
}

export async function exec(cmd: string[]): Promise<void> {
	// cannot do `, stderr` because we do `stderr: inherit`
	const { code } = await new Deno.Command(cmd[0], {
		args: cmd.slice(1),
		stdout: 'inherit',
		stderr: 'inherit',
	}).output()
	if (code) {
		throw new CodeError(code, `Execution of ${cmd.join(' ')} failed.`)
	}
}

export type AssertValues<T extends readonly unknown[]> = T[number]
export function assertFactory<T extends readonly unknown[]>(
	values: T,
	typeName: string,
): {
	values: T
	assert: (value: unknown) => asserts value is T[number]
	as: (value: unknown) => T[number]
} {
	function assert(value: unknown): asserts value is T[number] {
		if (!values.includes(value as T[number])) {
			throw new CodeError(
				14,
				`${typeName} must be one of: ${values.join(', ')}, but received: ${String(value)}`,
			)
		}
	}
	return {
		values,
		assert,
		as(value: unknown): T[number] {
			assert(value)
			return value as T[number]
		},
	}
}

export function assertString(value: unknown): asserts value is string {
	if (typeof value !== 'string') {
		throw new CodeError(14, `Expected a string, but received: ${typeof value}`)
	}
}
export function asString(value: unknown): string {
	assertString(value)
	return value
}

export function assertError(value: unknown): asserts value is Error {
	if (!(value instanceof Error)) {
		throw new CodeError(14, `Expected an Error, but received: ${typeof value}`)
	}
}
export function asError(value: unknown): Error {
	assertError(value)
	return value
}

export async function exitWithError(error?: unknown, status?: number) {
	if (status == null || status < 0) {
		if (error instanceof CodeError) {
			status = error.code ?? 1
		} else {
			status = 1
		}
	}
	if (error) {
		let output: string
		// If it's a HelpError, use its toTerminalString method for formatting
		output = error.toString()
		// Write directly to stderr to preserve ANSI codes
		await Deno.stderr.write(new TextEncoder().encode(output + '\n'))
	}
	Deno.exit(status)
}

export function writeStdoutStringify(output: unknown) {
	return writeStdoutPlain(JSON.stringify(output))
}
export function writeStdoutPlain(output: string) {
	return Deno.stdout.write(new TextEncoder().encode(output))
}
export function writeStdoutPretty(output: unknown) {
	console.log(output)
}

export async function readWhole(reader: Deno.Reader): Promise<string> {
	// `Deno.readAll` was deprecated <https://docs.deno.com/api/deno/~/Deno.readAll>
	// Implementation based on `@std/io/read-all` <https://github.com/denoland/std/blob/main/io/read_all.ts> <https://github.com/denoland/std/blob/main/LICENSE> Copyright 2018-2022 the Deno authors. MIT License
	const buffer: Uint8Array[] = []
	const DEFAULT_CHUNK_SIZE = 16_640 // <https://github.com/denoland/std/blob/main/io/_constants.ts>
	const buf = new Uint8Array(DEFAULT_CHUNK_SIZE)
	let bytesRead: number | null
	while ((bytesRead = await reader.read(buf)) !== null) {
		buffer.push(buf.slice(0, bytesRead))
	}
	const data = new Uint8Array(buffer.reduce((acc, b) => acc + b.length, 0))
	let offset = 0
	for (const b of buffer) {
		data.set(b, offset)
		offset += b.length
	}
	return new TextDecoder().decode(data)
}

export async function readStdinWhole(): Promise<string> {
	return readWhole(Deno.stdin)
}
