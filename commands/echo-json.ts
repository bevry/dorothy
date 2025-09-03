#!/usr/bin/env -S deno run --quiet --no-config --no-lock --no-npm --no-remote --cached-only

type Operation = 'stringify' | 'encode' | 'decode' | 'parse'

function help(...args: string[]) {
	console.error(
		[
			'USAGE:',
			'echo-json.ts <stringify|encode|decode|parse> <content>',
			'echo <content> | echo-json.ts <stringify|encode|decode|parse>',
			...(args.length ? ['', 'ERROR:', ...args] : []),
		].join('\n'),
	)
	Deno.exit(22)
}

async function parse(...args: string[]): {
	operation: Operation
	content: string
} {
	if (args.length === 0) {
		throw new Error('No arguments provided.')
	}
	const arg = String(args.shift())
	let operation: Operation, content: string
	switch (arg) {
		case 'stringify':
		case 'encode':
		case 'decode':
		case 'parse':
			operation = arg
			break
		default:
			throw new Error(`<operation> was invalid, it was: ${arg}`)
			break
	}
	if (args.length === 0) {
		content = await readStdin()
		return { operation, content }
	}
	content = args.shift()
	if (args.length !== 0) {
		throw new Error('An unrecognised argument was provided: ' + arg)
	}
	return { operation, content }
}

async function writeStdoutPlain(output: string) {
	return await Deno.stdout.write(new TextEncoder().encode(output))
}

function writeStdoutPretty(output: unknown) {
	console.log(output)
}

async function readStdin(): Promise<string> {
	return new TextDecoder().decode(await Deno.readAll(Deno.stdin))
}

async function main() {
	// extract the inputs
	const { operation, content } = await parse(...Deno.args)
	// handle interpretation differences between stringify, encode, and decode
	let parsed: unknown, parseError: Error | undefined
	if (operation == 'stringify') {
		parsed = content
	} else {
		try {
			// update the content
			parsed = JSON.parse(content)
		} catch (e) {
			// store the parse error for later if desired
			parseError = e
			// and make parsed just the string input
			parsed = content
		}
	}
	let output: string
	switch (operation) {
		case 'stringify':
		case 'encode':
			try {
				output = JSON.stringify(parsed)
			} catch (e) {
				throw new Error(
					`Failed to encode the content as a JSON string: ${e.message}`,
				)
			}
			return await writeStdoutPlain(output)
			break
		case 'decode':
			try {
				output =
					typeof parsed === 'object' ? JSON.stringify(parsed) : String(parsed)
			} catch (e) {
				throw new Error(
					`Failed to recode the content as a JSON string: ${e.message}`,
				)
			}
			return await writeStdoutPlain(output)
			break
		case 'parse':
			if (parseError != null) {
				throw new Error(
					`Failed to parse the JSON content: ${parseError.message}`,
				)
			}
			return await writeStdoutPretty(parsed)
			break
		default:
			throw new Error('Internal Error: Invalid operation: ' + operation)
			break
	}
}

try {
	await main()
} catch (e) {
	help(e.message)
}
