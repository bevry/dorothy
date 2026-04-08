#!/usr/bin/env -S eval-wsl deno run --quiet --no-config --no-lock --no-npm --no-remote --cached-only

import { heredoc, HelpError, exitWithError, wantsHelp } from '../sources/ts.ts'

class UsageError extends HelpError {
	override help = heredoc`
		USAGE:
		\`echo-url-coder.ts <encode|decode> <url>\`
	`
}

function main(...args: string[]) {
	if (args.length < 2) {
		throw new UsageError('--help=Expected <encode|decode> and <url>.')
	}
	const coder = args[0] === 'decode' ? decodeURI : encodeURI
	const url = args[1]
	console.log(coder(url))
}

try {
	if (wantsHelp(Deno.args)) {
		throw new UsageError()
	}
	main(...Deno.args)
} catch (error) {
	await exitWithError(error)
}
