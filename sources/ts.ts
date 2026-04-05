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
const STYLE = {
	bold: '\x1b[1m',
	END__bold: '\x1b[22m',
	dim: '\x1b[2m',
	END__dim: '\x1b[22m',
	code: '\x1b[90m', // intense gray (foreground_intense_black)
	END__code: '\x1b[39m', // default foreground
	link: '\x1b[4m', // underline
	END__link: '\x1b[24m', // no underline
	foreground_magenta: '\x1b[35m',
	foreground_green: '\x1b[32m',
	foreground_red: '\x1b[31m',
	foreground_blue: '\x1b[34m',
	END__foreground: '\x1b[39m', // default foreground
	intensity: '\x1b[1m', // bold (used for intensity tracking)
	END__intensity: '\x1b[22m', // normal intensity
}

// This is a AI conversion of Dorothy's source of truth `styles.bash:__print_help` implementation, which has tests in `echo-help`.
export function formatHelpText(text: string): string {
	// Convert string to character array for character-by-character processing
	// This matches the bash version's approach of storing characters in an array
	const chars = text.split('')
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
	readonly code: number
	constructor(message: string, code = 1) {
		super(message)
		this.code = code
	}
}

export class HelpError extends CodeError {
	help?: string
	override readonly code = 22
	public override toString() {
		let message = this.help || ''
		if (this.message) {
			// Format ERROR: section to match echo-error style: red background, white text
			message += `\n\n\x1b[41m\x1b[97mERROR:\x1b[49m\x1b[39m ${this.message}`
		}
		return message
	}

	async toTerminalString(): Promise<string> {
		const message = this.toString()
		return formatHelpText(message)
	}
}

export function assertString(value: unknown): asserts value is string {
	if (typeof value !== 'string') {
		throw new CodeError(`Expected a string, but received: ${typeof value}`, 14)
	}
}
export function asString(value: unknown): string {
	assertString(value)
	return value
}

export function assertError(value: unknown): asserts value is Error {
	if (!(value instanceof Error)) {
		throw new CodeError(`Expected an Error, but received: ${typeof value}`, 14)
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
		if (error instanceof HelpError) {
			output = await error.toTerminalString()
		} else {
			output = error.toString()
		}
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
