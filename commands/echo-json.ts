#!/usr/bin/env -S deno run --quiet --no-config --no-lock --no-npm --no-remote --cached-only

import {
	AbstractHelpError,
	exitWithError,
	writeStdoutStringify,
	writeStdoutPlain,
	writeStdoutPretty,
	asString,
	asError,
} from '../sources/ts.ts'

// Actions and Arguments
type Action = 'make' | 'stringify' | 'encode' | 'decode' | 'json' | 'pretty'
const actions: Action[] = [
	'make',
	'stringify',
	'encode',
	'decode',
	'json',
	'pretty',
]
class HelpError extends AbstractHelpError {
	override help = [
		'USAGE:',
		'echo-json.ts <make> [--] ...[<key> <value>]',
		'echo-json.ts <stringify|encode|decode|json|pretty> [--] ...<input>',
	].join('\n')
}
function assertAction(value: unknown): asserts value is Action {
	if (!actions.includes(value as Action)) {
		throw new HelpError(`An unrecognised <action> was provided: ${value}`)
	}
}
function asAction(value: unknown): Action {
	assertAction(value)
	return value
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
async function main(...args: string[]) {
	// parse <action>
	if (args.length === 0) {
		throw new HelpError(`No <action> was provided.`)
	}
	const action: Action = asAction(args.shift())
	// remove -- if present, note it is optional, because not all actions use arguments
	if (args.length && args[0] === '--') args.shift()
	// <make> ...[<key> <value>]
	if (action === 'make') {
		// validate we have a <value> for every <key>
		if (args.length % 2 !== 0) {
			throw new Error('<make> requires an even number of <key> <value> pairs.')
		}
		// build the object
		const output: Record<string, unknown> = {}
		while (args.length) {
			const key = asString(args.shift())
			const value = asString(args.shift())
			output[key] = real(value)
		}
		return writeStdoutStringify(output)
	}
	// <action> ...<input>
	while (args.length) {
		const input = asString(args.shift())
		switch (action) {
			case 'stringify': {
				return writeStdoutStringify(input)
				break
			}
			case 'json':
			case 'pretty': {
				const { parseError, value } = parse(input)
				if (parseError != null) {
					throw new Error(
						`Failed to parse what should be JSON-encoded <input> = ${parseError.message}`,
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
				const output =
					typeof value === 'object' ? JSON.stringify(value) : String(value)
				return writeStdoutPlain(output)
				break
			}
			default:
				throw new Error(`Invalid action: ${action}`)
				break
		}
	}
}

try {
	await main(...Deno.args)
} catch (error) {
	exitWithError(error)
}
