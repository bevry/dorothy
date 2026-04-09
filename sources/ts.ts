#!/usr/bin/env -S eval-wsl deno run --quiet --no-config --no-lock --no-npm --no-remote --cached-only

/**
 * Shared TypeScript runtime helpers for Dorothy commands.
 *
 * This module is still alpha quality; conventions can change.
 * Alternative implementation notes: <https://gist.github.com/balupton/4138b7ab3bb72caf020c061a872e1631>
 */

/**
 * ANSI styles.
 * Partial TypeScript-style implementation of the source-of-truth reference `styles.bash`.
 */
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
	const s = name.replace(/-/g, '_')
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
 * Render text with Dorothy's style-flag mini-language.
 * Partial TypeScript-style implementation of the source-of-truth reference `styles.bash:__print_style`.
 *
 * @param messages Plain text and/or style flags such as `--bold` or
 * `--red=message`.
 * @returns ANSI-styled output string.
 * @remarks
 * Supported patterns include:
 * - carry-forward flags: `--bold`
 * - wrapped content flags: `--bold=message`
 * - combined styles: `--bold+red=message`
 * - reset: `--reset`
 * - help rendering: `--help=...`
 * @example
 * ```ts
 * style('--red', 'red text', '--bold=red and bold text as red carries over')
 * ```
 * @example
 * ```ts
 * style('--error=wrapped in STYLE.error and STYLE.END__error')
 * ```
 */
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

/** Prefix a message list with a styled ERROR label. */
export function printError(...messages: Array<string | number>): string {
	return style(`--error1=ERROR:`, ' ', ...messages)
}

/**
 * Tagged template helper for indented multiline text blocks.
 * Trims surrounding blank lines and removes shared leading indentation.
 * TypeScript-like implementation of the source-of-truth reference of Bash's tab-stripped heredocs `<<-EOF`.
 */
export function heredoc(
	strings: TemplateStringsArray,
	...values: unknown[]
): string {
	let output = strings[0] ?? ''
	for (let i = 0; i < values.length; i++) {
		output += String(values[i]) + (strings[i + 1] ?? '')
	}

	const lines = output.replace(/\r\n?/g, '\n').split('\n')
	while (lines.length > 0 && lines[0].trim() === '') lines.shift()
	while (lines.length > 0 && lines[lines.length - 1].trim() === '') lines.pop()
	if (lines.length === 0) return ''

	let minIndent = Number.POSITIVE_INFINITY
	for (const line of lines) {
		if (line.trim() === '') continue
		const indent = line.match(/^[\t ]*/)?.[0].length ?? 0
		if (indent < minIndent) minIndent = indent
	}

	if (!Number.isFinite(minIndent) || minIndent === 0) {
		return lines.join('\n')
	}

	return lines
		.map((line) => (line.trim() === '' ? '' : line.slice(minIndent)))
		.join('\n')
}

/**
 * Render Dorothy help templates into ANSI-styled terminal output.
 *
 * Full TypeScript-style implementation of the source-of-truth reference `styles.bash:__print_help`.
 * Validated by `echo-help.ts --test` which shares fixtures with the source-of-truth reference `echo-help --test`.
 */
export function renderHelp(template: string): string {
	// This works by splitting text into per-character segments, with parallel
	// prefixes/suffixes arrays that carry styling metadata for each segment.
	// Segment removals use: segments[index] = ''.
	// Segment replacements use: segments[index] = 'replacement'.
	// Segment styling uses: prefixes[index] += beginStyle and suffixes[index] += endStyle.
	// This mirrors styles.bash:__print_help and keeps content and style transformations separate.
	// In simple cases we may place style codes directly into segments[index].
	const segments = template.split('')
	const segmentsCount = segments.length
	const prefixes: string[] = Array(segmentsCount).fill('')
	const suffixes: string[] = Array(segmentsCount).fill('')

	// State tracking
	let inCode = false
	let inFence = false
	let inColor = false
	let inOption = false
	type IntensityEntry = { style: string; segmentIndex: number; segment: string }
	const intensities: IntensityEntry[] = []

	// <expansive>: when a match is found, keep extending while pattern matches.
	// <xenophobic>: matching must remain contiguous from the start position.
	function findSegment(options: {
		start?: number
		direction?: -1 | 1
		pattern: RegExp
		until?: string
		matchExtends?: boolean
		matchNothing?: boolean
		otherFails?: boolean
	}): number | null {
		const startSegmentIndex = options.start ?? 0
		const direction = options.direction ?? 1
		const pattern = options.pattern
		const until = options.until
		const matchExtends = options.matchExtends ?? false
		const matchNothing = options.matchNothing ?? false
		const otherFails = options.otherFails ?? false

		let foundSegmentIndex: number | null = null
		let iterations = 0
		for (
			let searchSegmentIndex = startSegmentIndex + direction;
			searchSegmentIndex >= 0 && searchSegmentIndex < segmentsCount;
			searchSegmentIndex += direction
		) {
			iterations++
			if (pattern.test(segments[searchSegmentIndex])) {
				foundSegmentIndex = searchSegmentIndex
				if (!matchExtends) break
				continue
			}
			if (until != null && segments[searchSegmentIndex] === until) {
				if (matchNothing && iterations === 1) {
					return startSegmentIndex
				}
				break
			}
			if (otherFails) {
				return null
			}
			if (foundSegmentIndex != null) {
				break
			}
		}

		if (matchNothing && iterations === 0) {
			return startSegmentIndex
		}

		return foundSegmentIndex
	}

	function findXenophobicMatchesUntil(
		pattern: RegExp,
		until: string,
		fromSegmentIndex: number,
	): number | null {
		return findSegment({
			start: fromSegmentIndex,
			pattern,
			until,
			matchExtends: true,
			otherFails: true,
		})
	}

	function findIndexOfEarlierPattern(
		pattern: RegExp,
		fromSegmentIndex: number,
	): number | null {
		return findSegment({ start: fromSegmentIndex, direction: -1, pattern })
	}

	function findIndexOfUpcomingPattern(
		pattern: RegExp,
		fromSegmentIndex: number,
	): number | null {
		return findSegment({ start: fromSegmentIndex, pattern })
	}

	function expandAcrossPossiblePaddingToEnd(
		fromSegmentIndex: number,
	): number | null {
		return findSegment({
			start: fromSegmentIndex,
			direction: -1,
			pattern: /^[\t ]$/,
			until: '\n',
			matchExtends: true,
			matchNothing: true,
			otherFails: true,
		})
	}

	function leftwardsOfHeader(fromSegmentIndex: number): number | null {
		return findSegment({
			start: fromSegmentIndex,
			direction: -1,
			pattern: /^[A-Z ]$/,
			until: '\n',
			matchExtends: true,
			matchNothing: true,
			otherFails: true,
		})
	}

	// Concatenate a segment range, defaulting to the end of input.
	function concatenateSegments(
		fromSegmentIndex: number,
		untilSegmentIndex: number = segmentsCount,
	): string {
		return segments.slice(fromSegmentIndex, untilSegmentIndex).join('')
	}

	// Require problematic help syntax to be fenced, and report the exact line context.
	function requireFence(segment: string, fromSegmentIndex: number): never {
		const lineStartSegmentIndex =
			(findIndexOfEarlierPattern(/^\n$/, fromSegmentIndex) ?? -1) + 1
		const lineEndSegmentIndex =
			findIndexOfUpcomingPattern(/^\n$/, fromSegmentIndex) ?? segmentsCount
		const line = concatenateSegments(lineStartSegmentIndex, lineEndSegmentIndex)
		throw new HelpError(
			{ code: 94 },
			'Invalid help template. Wrap ',
			`--code=${segment}`,
			' in ',
			'--code=```',
			'.',
			'\n',
			'Problem:',
			'\n',
			`--code=${line}`,
			'\n',
			'Solution:',
			'\n',
			`--code=\`\`\`${line}\`\`\``,
		)
	}

	// Report intensity parsing failures with local line context and remediation guidance.
	function requireMatchedIntensitiesError(
		intensityIndex: number,
		intensitySegment: string,
	): never {
		const priorNewline = findIndexOfEarlierPattern(/^\n$/, intensityIndex)
		const nextNewline = findIndexOfUpcomingPattern(/^\n$/, intensityIndex)
		const left =
			priorNewline != null
				? concatenateSegments(priorNewline + 1, intensityIndex)
				: ''
		const right =
			nextNewline != null
				? concatenateSegments(intensityIndex, nextNewline)
				: concatenateSegments(intensityIndex)

		throw new HelpError(
			{ code: 94 },
			'Invalid help template. Unable to complete ',
			`--code=${intensitySegment}`,
			' at ',
			`--code=${String(intensityIndex)}`,
			' within:',
			'\n',
			`--code=${left}${right}`,
			'\n',
			'Check for complete opening and closure of this intensity modifier, or for complete opening and closure of intensity modifiers within it.',
			'\n',
			'If the segment is correct, such as being valid code, then wrap it or the line in three backticks ',
			'--code=```',
			' to prevent its interpretation as an intensity modifier.',
		)
	}

	// Closing marker without any currently-open intensity.
	function reportMismatchedIntensity(atSegmentIndex: number): never {
		return requireMatchedIntensitiesError(
			atSegmentIndex,
			segments[atSegmentIndex] ?? '',
		)
	}

	// End of parse while one or more intensity markers remain open.
	function reportUnclosedIntensity(): never {
		for (const intensity of intensities) {
			requireMatchedIntensitiesError(intensity.segmentIndex, intensity.segment)
		}
		throw new CodeError(
			94,
			printError('Invalid help template. Mismatched intensity modifiers.'),
		)
	}

	// Main processing loop - character by character
	for (
		let currentSegmentIndex = 0;
		currentSegmentIndex < segmentsCount;
		currentSegmentIndex++
	) {
		const segment = segments[currentSegmentIndex]
		const nextSegment1 = segments[currentSegmentIndex + 1] || ''
		const nextSegment2 = segments[currentSegmentIndex + 2] || ''
		const nextSegment3 = segments[currentSegmentIndex + 3] || ''
		const nextSegment4 = segments[currentSegmentIndex + 4] || ''
		const priorSegment1 = segments[currentSegmentIndex - 1] || ''

		// Skip ANSI control sequences present in incoming content.
		if (segment === '\x1b') {
			inColor = true
			continue
		}
		if (inColor) {
			if (segment === 'm') {
				inColor = false
			}
			continue
		}

		// CODE FENCE: ```
		// Fence bodies disable all non-code parsing rules until the closing fence.
		if (segment === '`' && nextSegment1 === '`' && nextSegment2 === '`') {
			segments[currentSegmentIndex] = ''
			segments[currentSegmentIndex + 1] = ''
			segments[currentSegmentIndex + 2] = ''

			// Remove fence if it's the only non-whitespace on line
			const paddingStartSegmentIndex =
				expandAcrossPossiblePaddingToEnd(currentSegmentIndex)
			if (
				segments[currentSegmentIndex + 3] === '\n' &&
				paddingStartSegmentIndex !== null
			) {
				segments[currentSegmentIndex + 3] = ''
				for (
					let subSegmentIndex = paddingStartSegmentIndex;
					subSegmentIndex < currentSegmentIndex;
					subSegmentIndex++
				) {
					segments[subSegmentIndex] = ''
				}
			}

			// Toggle fence
			if (!inFence) {
				inFence = true
				segments[currentSegmentIndex] = STYLE.code
			} else {
				segments[currentSegmentIndex] = STYLE.END__code
				inFence = false
			}
			continue
		}

		// Ignore all transformations inside fenced code.
		if (inFence) continue

		// LIST MARKER: * or !
		if ((segment === '*' || segment === '!') && nextSegment1 === ' ') {
			if (expandAcrossPossiblePaddingToEnd(currentSegmentIndex) !== null) {
				if (segment === '*') {
					segments[currentSegmentIndex] = '•'
				} else if (segment === '!') {
					const paddingSegmentIndex =
						expandAcrossPossiblePaddingToEnd(currentSegmentIndex)
					if (paddingSegmentIndex !== null) {
						prefixes[paddingSegmentIndex] += STYLE.foreground_red
					} else {
						prefixes[0] += STYLE.foreground_red
					}
					segments[currentSegmentIndex] = '!'
					suffixes[currentSegmentIndex] += STYLE.END__foreground
				}
				continue
			}
		}

		// HEADER: Uppercase text ending with :
		if (segment === ':' && nextSegment1 === '\n') {
			const headerStartSegmentIndex = leftwardsOfHeader(currentSegmentIndex)
			if (headerStartSegmentIndex !== null) {
				prefixes[headerStartSegmentIndex] += STYLE.foreground_magenta
				suffixes[currentSegmentIndex] += STYLE.END__foreground
				continue
			}
		}

		// URL: <http...>
		if (
			segment === '<' &&
			`${nextSegment1}${nextSegment2}${nextSegment3}${nextSegment4}` === 'http'
		) {
			const endSegmentIndex = findIndexOfUpcomingPattern(
				/^>$/,
				currentSegmentIndex,
			)
			if (endSegmentIndex !== null) {
				segments[currentSegmentIndex] = STYLE.link
				segments[endSegmentIndex] = STYLE.END__link
				currentSegmentIndex = endSegmentIndex
			} else {
				continue
			}
			continue
		}

		// RETURN STATUS: [0...] or [1-9...]
		if (segment === '[') {
			const successfulStatusEndSegmentIndex = findXenophobicMatchesUntil(
				/^0+$/,
				']',
				currentSegmentIndex,
			)
			if (successfulStatusEndSegmentIndex !== null) {
				prefixes[currentSegmentIndex] += STYLE.foreground_green
				suffixes[successfulStatusEndSegmentIndex + 1] += STYLE.END__foreground
				currentSegmentIndex = successfulStatusEndSegmentIndex + 1
				continue
			} else {
				const failingStatusEndSegmentIndex = findXenophobicMatchesUntil(
					/^[\d*]+$/,
					']',
					currentSegmentIndex,
				)
				if (failingStatusEndSegmentIndex !== null) {
					prefixes[currentSegmentIndex] += STYLE.foreground_red
					suffixes[failingStatusEndSegmentIndex + 1] += STYLE.END__foreground
					currentSegmentIndex = failingStatusEndSegmentIndex + 1
					continue
				}
			}
		}

		// INLINE CODE: `
		if (segment === '`') {
			if (!inCode) {
				inCode = true
				segments[currentSegmentIndex] = STYLE.code
			} else {
				inCode = false
				segments[currentSegmentIndex] = STYLE.END__code
			}
			continue
		}

		// OPTIONS/ACTIONS: -, <, [, |, &, ...
		// Entire option/action line is styled in magenta when detected.
		inOption = false
		switch (segment) {
			case '-':
			case '<':
			case '[':
			case '|':
				inOption = true
				break
			case '&':
				if (nextSegment1 === ' ') {
					inOption = true
					segments[currentSegmentIndex] = ''
					segments[currentSegmentIndex + 1] = ''
				}
				break
			case '.':
				if (nextSegment1 === '.' && nextSegment2 === '.') {
					inOption = true
				}
				break
		}

		if (
			inOption &&
			expandAcrossPossiblePaddingToEnd(currentSegmentIndex) !== null
		) {
			prefixes[currentSegmentIndex] = STYLE.foreground_magenta
			const lineEndSegmentIndex = findIndexOfUpcomingPattern(
				/^\n$/,
				currentSegmentIndex,
			)
			if (lineEndSegmentIndex !== null) {
				suffixes[lineEndSegmentIndex] += STYLE.END__foreground
			} else {
				suffixes[segmentsCount - 1] += STYLE.END__foreground
			}
		}

		// INTENSITY MODIFIERS: <, [, >, ]
		// Use a stack to support nesting and to re-apply parent intensity after pop.
		let shouldRemoveIntensity = false
		switch (segment) {
			case '<':
				if ([' ', '&', '(', '='].includes(nextSegment1)) {
					requireFence(`${segment}${nextSegment1}`, currentSegmentIndex)
				}
				intensities.push({
					style: STYLE.bold,
					segmentIndex: currentSegmentIndex,
					segment,
				})
				prefixes[currentSegmentIndex] += STYLE.bold
				break
			case '[':
				if (
					nextSegment1 === 'a' &&
					nextSegment2 === '-' &&
					nextSegment3 === 'z'
				) {
					requireFence(
						`${segment}${nextSegment1}${nextSegment2}${nextSegment3}${nextSegment4}`,
						currentSegmentIndex,
					)
				} else if (nextSegment1 === ' ' || nextSegment1 === ']') {
					requireFence(`${segment}${nextSegment1}`, currentSegmentIndex)
				} else {
					intensities.push({
						style: STYLE.dim,
						segmentIndex: currentSegmentIndex,
						segment,
					})
					prefixes[currentSegmentIndex] += STYLE.dim
				}
				break
			case '>':
				if (priorSegment1 === ' ' || priorSegment1 === ')') {
					requireFence(`${segment}${priorSegment1}`, currentSegmentIndex)
				} else if (nextSegment1 === '&') {
					requireFence(`${segment}${nextSegment1}`, currentSegmentIndex)
				} else if (nextSegment1 === '=' && nextSegment2 === ' ') {
					requireFence(
						`${segment}${nextSegment1}${nextSegment2}`,
						currentSegmentIndex,
					)
				}
				shouldRemoveIntensity = true
				break
			case ']':
				if (priorSegment1 === ' ') {
					requireFence(`${segment}${priorSegment1}`, currentSegmentIndex)
				}
				shouldRemoveIntensity = true
				break
		}

		if (shouldRemoveIntensity) {
			if (intensities.length === 0) {
				reportMismatchedIntensity(currentSegmentIndex)
			} else if (intensities.length === 1) {
				// Last open intensity closed: emit reset and clear stack.
				suffixes[currentSegmentIndex] += STYLE.END__intensity
				intensities.length = 0
			} else {
				// Nested close: reset intensity then re-apply still-open parent styles.
				intensities.pop()
				suffixes[currentSegmentIndex] +=
					STYLE.END__intensity +
					intensities.map((intensity) => intensity.style).join('')
			}
		}
	}

	if (intensities.length !== 0) {
		reportUnclosedIntensity()
	}

	// Build result
	let result = ''
	for (
		let currentSegmentIndex = 0;
		currentSegmentIndex < segmentsCount;
		currentSegmentIndex++
	) {
		result +=
			prefixes[currentSegmentIndex] +
			segments[currentSegmentIndex] +
			suffixes[currentSegmentIndex]
	}

	// Trim double trailing newline
	while (result.endsWith('\n\n')) {
		result = result.slice(0, -1)
	}

	return result
}

/** Error type carrying an explicit process exit code. */
export class CodeError extends Error {
	readonly code: number = 1

	/**
	 * @param code Process exit code to use.
	 * @param message Human-readable error message.
	 */
	constructor(code: number, message: string) {
		super(message)
		if (code != null) {
			this.code = code
		}
	}
}

/**
 * Error type used for command usage/help flows.
 *
 * If both help and messages are provided, help is rendered first and error
 * messages are appended.
 *
 * TypeScript-like implementation of Dorothy's `__help` bash function convention, which defers to its `styles.bash:__print_help` implementation (our TypeScript `renderHelp` implementation).
 */
export class HelpError extends Error {
	readonly help: string = ''
	readonly messages: string[] = []
	readonly code: number = 22

	/**
	 * Construct a HelpError from either config+messages or only messages.
	 */
	constructor(config: { help?: string; code?: number }, ...messages: string[])
	constructor(...messages: string[])
	constructor(
		first?: string | { help?: string; code?: number },
		...rest: string[]
	) {
		super()
		if (typeof first === 'object' && first !== null) {
			if (first.help != null) this.help = first.help
			if (first.code != null) this.code = first.code
			this.messages = rest
		} else if (typeof first === 'string') {
			this.messages = [first, ...rest]
		}
	}

	/** Render this error for terminal display. */
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

/**
 * Run a command with inherited stdout/stderr.
 *
 * @param cmd Command array where the first element is the executable.
 * @returns Resolves when the command exits with code 0.
 * @throws {CodeError} If the command exits non-zero.
 */
export async function run(cmd: string[]): Promise<void> {
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

/**
 * Union of all literal values accepted by {@link assertFactory}.
 *
 * @typeParam T Tuple of allowed literal values.
 */
export type AssertFactoryValues<T extends readonly unknown[]> = T[number]

/**
 * Create reusable runtime type guards for a fixed set of allowed values.
 *
 * This is useful when command options are user input (strings/unknown values)
 * and you want both:
 * - runtime validation with a clear error, and
 * - compile-time narrowing to a literal union type.
 *
 * @typeParam T Tuple of allowed values, usually declared with `as const`.
 * @param values Allowed values.
 * @param typeName Human-friendly type name for error messages.
 * @returns Helpers to validate (`assert`) or coerce-with-check (`as`).
 * @throws {CodeError} If a value is not present in `values`.
 * @remarks
 * - `assert(value)` narrows the type in-place when validation succeeds.
 * - `as(value)` is a convenience wrapper that returns the validated value.
 * @example
 * ```ts
 * const LEVELS = ['info', 'warn', 'error'] as const
 * const Level = assertFactory(LEVELS, 'LogLevel')
 *
 * const raw: unknown = 'warn'
 * Level.assert(raw)
 * // raw is now narrowed to 'info' | 'warn' | 'error'
 *
 * const level = Level.as('error')
 * // level has type 'info' | 'warn' | 'error'
 * ```
 */
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

/**
 * Assert that a value is a string.
 *
 * TypeScript does not trust unknown input by default. This assertion narrows
 * `unknown` to `string` after the call succeeds.
 *
 * @param value Value to validate.
 * @throws {CodeError} If `value` is not a string.
 */
export function assertString(value: unknown): asserts value is string {
	if (typeof value !== 'string') {
		throw new CodeError(14, `Expected a string, but received: ${typeof value}`)
	}
}

/**
 * Return a value as `string` after runtime validation.
 *
 * Use this when you need a string value immediately (instead of calling
 * `assertString` and then returning the original variable yourself).
 *
 * @param value Value to validate and return.
 * @returns The same value, typed as `string`.
 * @throws {CodeError} If `value` is not a string.
 */
export function asString(value: unknown): string {
	assertString(value)
	return value
}

/**
 * Assert that a value is an Error instance.
 *
 * Useful in `catch` blocks where the caught value is `unknown` in modern TS.
 *
 * @param value Value to validate.
 * @throws {CodeError} If `value` is not an Error instance.
 */
export function assertError(value: unknown): asserts value is Error {
	if (!(value instanceof Error)) {
		throw new CodeError(14, `Expected an Error, but received: ${typeof value}`)
	}
}

/**
 * Return a value as `Error` after runtime validation.
 *
 * @param value Value to validate and return.
 * @returns The same value, typed as `Error`.
 * @throws {CodeError} If `value` is not an Error instance.
 */
export function asError(value: unknown): Error {
	assertError(value)
	return value
}

/**
 * Render an error to stderr and terminate the process.
 *
 * @param error Optional unknown error value.
 * @param status Optional explicit status code; inferred when omitted.
 * @returns Never returns because this function terminates the process.
 * @remarks
 * This function always calls `Deno.exit(...)`.
 */
export async function exitWithError(error?: unknown, status?: number) {
	let finalError = error
	let output: string | undefined
	if (error) {
		try {
			output = error instanceof CodeError ? error.message : error.toString()
		} catch (renderError) {
			finalError = renderError
			if (renderError instanceof CodeError) {
				output = renderError.message
			} else if (renderError instanceof Error) {
				output = renderError.toString()
			} else {
				output = String(renderError)
			}
		}
	}
	if (status == null || status < 0) {
		if (finalError instanceof CodeError || finalError instanceof HelpError) {
			status = finalError.code ?? 1
		} else {
			status = 1
		}
	}
	if (output != null) {
		// Write directly to stderr to preserve ANSI codes
		await Deno.stderr.write(new TextEncoder().encode(output + '\n'))
	}
	Deno.exit(status)
}

/** Serialize unknown output as JSON and write to stdout. */
export function writeStdoutStringify(output: unknown) {
	return writeStdoutPlain(JSON.stringify(output))
}

/** Write plain text to stdout without adding a trailing newline. */
export function writeStdoutPlain(output: string) {
	return Deno.stdout.write(new TextEncoder().encode(output))
}

/** Pretty-print output via console.log. */
export function writeStdoutPretty(output: unknown) {
	console.log(output)
}

/**
 * Return true when arguments request help output for a command.
 *
 * @param args Process arguments, usually Deno.args.
 * @returns True when args is exactly one help flag.
 */
export function wantsHelp(args: string[]): boolean {
	return args.length === 1 && (args[0] === '--help' || args[0] === '-h')
}

/**
 * Return true when arguments request running command tests.
 *
 * @param args Process arguments, usually Deno.args.
 * @returns True when args is exactly the test flag.
 */
export function wantsTests(args: string[]): boolean {
	return args.length === 1 && args[0] === '--test'
}

/**
 * Local recreation of the removed `Deno.Reader` type for Deno 2 compatibility.
 *
 * @remarks
 * Shape-compatible with the standard Reader contract so existing callers such
 * as `Deno.stdin` can be passed without adapters.
 * @see {@link https://docs.deno.com/runtime/reference/migration_guide/#api-changes | Deno migration guide API changes}
 * @see {@link https://jsr.io/@std/io/doc/types/~/Reader | @std/io Reader contract}
 * @see {@link https://github.com/denoland/std/blob/main/io/types.ts | Upstream type source}
 * @see {@link https://github.com/denoland/std/blob/main/LICENSE | Upstream license}
 * @copyright
 * Copyright the Deno authors.
 * Licensed under the MIT License.
 */
export type ReaderLike = {
	read(p: Uint8Array): Promise<number | null>
}

/**
 * Read all bytes from a ReaderLike and decode as UTF-8 text.
 *
 * @param reader Byte reader implementing the ReaderLike contract.
 * @returns Decoded UTF-8 text containing the full reader contents.
 * @throws {Error} Any I/O error thrown by `reader.read`.
 * @remarks
 * This function replaces removed runtime helpers like `Deno.readAll` while
 * keeping equivalent behavior for command input handling.
 * @see {@link https://github.com/denoland/std/blob/main/io/read_all.ts | Upstream read_all implementation}
 * @see {@link https://github.com/denoland/std/blob/main/LICENSE | Upstream license}
 * @copyright
 * Copyright 2018-2022 the Deno authors.
 * Licensed under the MIT License.
 */
export async function readWhole(reader: ReaderLike): Promise<string> {
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

/**
 * Read all data from stdin as UTF-8 text.
 *
 * @returns Decoded UTF-8 text from `Deno.stdin`.
 */
export function readStdinWhole(): Promise<string> {
	return readWhole(Deno.stdin)
}
