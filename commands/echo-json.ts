#!/usr/bin/env -S eval-wsl deno run --quiet --no-config --no-lock --no-npm --no-remote --cached-only
// deno-lint-ignore-file no-unreachable

import {
	HelpError,
	exitWithError,
	writeStdoutStringify,
	writeStdoutPlain,
	writeStdoutPretty,
	heredoc,
	wantsHelp,
	asString,
	asError,
	assertFactory,
} from '../sources/ts.ts'

const { values: actionValues, as: asAction } = assertFactory(
	['make', 'stringify', 'encode', 'decode', 'json', 'pretty'] as const,
	'action',
)

class UsageError extends HelpError {
	override help = heredoc`
		USAGE:
		\`echo-json.ts <make> [--] ...[<key> <value>]\`
		\`echo-json.ts <${actionValues.join('|')}> [--] ...<input>\`
	`
}

// Parsing
function real(input: string) {
	try {
		return JSON.parse(input)
	} catch {
		return input
	}
}
function parse(input: string): {
	parseError: Error | null
	value: unknown
} {
	try {
		return {
			parseError: null,
			value: JSON.parse(input),
		}
	} catch (parseError) {
		return {
			parseError: asError(parseError),
			value: input,
		}
	}
}

// Execute
// <action> [...options] ...<input>
function main(...args: string[]) {
	// parse <action>
	if (args.length === 0) {
		throw new UsageError(`--help=No <action> was provided.`)
	}
	const action = asAction(args.shift())
	// parse [...options] ...<input>
	const properties = [],
		inputs = []
	while (args.length !== 0) {
		const input = asString(args.shift())
		if (input == '--') {
			inputs.push(...args)
			break
		} else if (input.startsWith('--property=')) {
			const property = input.replace(/^--property=/, '')
			properties.push(property)
		} else {
			inputs.push(input)
		}
	}
	// <make> ...[<key> <value>]
	if (action === 'make') {
		// validate we have a <value> for every <key>
		if (inputs.length % 2 !== 0) {
			throw new UsageError(
				`--help=<make> requires an even number of <key> <value> pairs.`,
			)
		}
		// build the object
		const output: Record<string, unknown> = {}
		while (inputs.length) {
			const key = asString(inputs.shift())
			const value = asString(inputs.shift())
			output[key] = real(value)
		}
		return writeStdoutStringify(output)
	}
	// ...<input>
	while (inputs.length) {
		const input = asString(inputs.shift())
		switch (action) {
			case 'stringify': {
				return writeStdoutStringify(input)
				break
			}
			case 'json':
			case 'pretty': {
				const { parseError, value } = parse(input)
				if (parseError != null) {
					throw new UsageError(
						`--help=Failed to parse what should be JSON-encoded <input> = `,
						`--value=${parseError.message}`,
					)
				}
				if (action == 'json') {
					return writeStdoutStringify(value)
				} else {
					return writeStdoutPretty(value)
				}
				break
			}
			case 'encode': {
				const { value } = parse(input)
				return writeStdoutStringify(value)
				break
			}
			case 'decode': {
				const { value } = parse(input)
				let output = ''
				if (properties.length === 0) {
					output =
						typeof value === 'object' ? JSON.stringify(value) : String(value)
				} else {
					const outputs = []
					for (const property of properties) {
						const keys = property.split('.')
						let diver: any = value
						for (const key of keys) {
							if (diver && typeof diver === 'object' && key in diver) {
								diver = diver[key]
							} else {
								throw new UsageError(
									`Property `,
									`--value=${property}`,
									` does not exist in the provided input.`,
								)
							}
						}
						outputs.push(
							typeof diver === 'object' ? JSON.stringify(diver) : String(diver),
						)
					}
					output = outputs.join('\n')
				}
				return writeStdoutPlain(output)
				break
			}
			default:
				throw new UsageError(`--help=Invalid <action>: `, `--value=${action}`)
				break
		}
	}
}

try {
	if (wantsHelp(Deno.args)) {
		throw new UsageError()
	}
	await main(...Deno.args)
} catch (error) {
	await exitWithError(error)
}
