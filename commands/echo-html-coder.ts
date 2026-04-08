#!/usr/bin/env -S eval-wsl deno run --quiet --no-config --no-lock --no-npm

import { heredoc, HelpError, exitWithError, wantsHelp } from '../sources/ts.ts'
import { Html5Entities } from 'https://deno.land/x/html_entities@v1.0/mod.js'

class UsageError extends HelpError {
	override help = heredoc`
		USAGE:
		\`echo-html-coder.ts <encode|decode> <text>\`
	`
}

function main(...args: string[]) {
	if (args.length < 2) {
		throw new UsageError('--help=Expected <encode|decode> and <text>.')
	}
	const coder =
		args[0] === 'decode' ? Html5Entities.decode : Html5Entities.encode
	const value = args[1]
	console.log(coder(value))
}

try {
	if (wantsHelp(Deno.args)) {
		throw new UsageError()
	}
	main(...Deno.args)
} catch (error) {
	await exitWithError(error)
}
