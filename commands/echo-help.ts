#!/usr/bin/env -S eval-wsl deno run --quiet --allow-env --allow-read --allow-write --allow-run --no-config --no-lock --no-npm --no-remote --cached-only

import {
	HelpError,
	exitWithError,
	readStdinWhole,
	exec,
} from '../sources/ts.ts'

class UsageError extends HelpError {
	override help = [
		'USAGE:',
		'`echo-help.ts --test`',
		'`echo-help.ts --help`',
		'`echo-help.ts [...<styled error messages>] < template.txt`',
		'',
		'NOTE:',
		'This is a test implementation only. Use the bash version `echo-help` for production.',
	].join('\n')
}

// Execute
async function main(...args: string[]) {
	const help = await readStdinWhole()
	throw new HelpError({help, code: 0}, ...args)
}

// invoke command or tests
try {
	if (Deno.args.join('') == '--help' ) {
		throw new UsageError()
	} else if (Deno.args.join('') == '--test' ) {
		await exec(['eval-tester', '--fixture=echo-help', '--', 'echo-help.ts'])
	} else {
		await main(...Deno.args)
	}
} catch (error) {
	await exitWithError(error)
}
