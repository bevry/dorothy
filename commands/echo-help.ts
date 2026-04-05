#!/usr/bin/env -S eval-wsl deno run --quiet --allow-env --allow-read --allow-write --allow-run --no-config --no-lock --no-npm --no-remote --cached-only

import {
	HelpError,
	exitWithError,
	formatHelpText,
	readStdinWhole,
} from '../sources/ts.ts'

// Custom error for echo-help (for testing only)
class UsageError extends HelpError {
	override help = [
		'USAGE:',
		'`echo-help.ts --test`',
		'`echo-help.ts --render-fixture [...<message-arguments>] < template.txt`',
		'',
		'NOTE:',
		'This is a test implementation only. Use the bash version `echo-help` for production.',
	].join('\n')

	constructor(message = 'Help requested') {
		super(message)
	}
}

// Execute
async function main(...args: string[]) {
	// Handle --test mode
	if (args.includes('--test')) {
		await runTests()
		return
	}

	// Handle --render-fixture mode (for testing via eval-tester)
	if (args.includes('--render-fixture')) {
		// Remove the flag and get remaining arguments
		const messageArgs = args.filter(arg => arg !== '--render-fixture')
		await renderFixture(messageArgs)
		return
	}

	// Default to help
	throw new UsageError('This script is for testing only. Use: echo-help.ts --test or echo-help.ts --render-fixture')
}

// Render a fixture (called by eval-tester)
async function renderFixture(messageArgs: string[]) {
	// Read template from stdin
	const template = await readStdinWhole()

	// Format the template with help text formatting
	let output = formatHelpText(template)

	// Trim trailing newlines from the formatted usage
	output = output.replace(/\n+$/, '')

	// If there are arguments (error messages), append them with double newline before
	if (messageArgs.length > 0) {
		output += '\n\n\x1b[41m\x1b[97mERROR:\x1b[49m\x1b[39m ' + messageArgs.join('')
	}

	// Write formatted output to stderr with trailing newline
	await Deno.stderr.write(new TextEncoder().encode(output + '\n'))
}

// Run tests using eval-tester
async function runTests() {
	// Get the DOROTHY environment variable or use default
	const dorothy = Deno.env.get('DOROTHY') || '/Users/balupton/.local/share/dorothy'

	// Read the fixture files
	const expectedFixture = await Deno.readTextFile(`${dorothy}/fixtures/echo-help.expected.txt`)
	const stdinFixture = await Deno.readTextFile(`${dorothy}/fixtures/echo-help.stdin.txt`)

	// Hardcoded ANSI code for blue
	const blueAnsiCode = '\x1b[34m'
	const resetAnsiCode = '\x1b[39m'

	// Create temporary directory for fixture files
	const tempDir = await Deno.makeTempDir()

	try {
		// Write fixtures to temp files
		const expectedFile = `${tempDir}/expected.txt`
		const stdinFile = `${tempDir}/stdin.txt`

		await Deno.writeTextFile(expectedFile, expectedFixture)
		await Deno.writeTextFile(stdinFile, stdinFixture)

		// Build the test command using bash for proper shell handling
		const bashCommand = `eval-tester --stderr="$(cat '${expectedFile}')" -- echo-help.ts --render-fixture 'first argument' '${blueAnsiCode}second argument${resetAnsiCode}' < '${stdinFile}'`

		// Run the test command through bash
		const testProcess = new Deno.Command('bash', {
			args: ['-c', bashCommand],
			stdout: 'inherit',
			stderr: 'inherit',
			env: { ...Deno.env.toObject() },
		})

		const { success } = testProcess.outputSync()

		if (!success) {
			Deno.exit(1)
		}
	} finally {
		// Clean up temp directory
		try {
			await Deno.remove(tempDir, { recursive: true })
		} catch {
			// Ignore cleanup errors
		}
	}
}

try {
	await main(...Deno.args)
} catch (error) {
	await exitWithError(error)
}
