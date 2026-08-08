#!/usr/bin/env -S eval-wsl deno run --quiet --no-config --no-lock --no-npm --no-remote --cached-only

import { heredoc, HelpError, exitWithError, wantsHelp } from '../sources/ts.ts'

class UsageError extends HelpError {
	override help = heredoc`
		USAGE:
		\`get-url-domain.ts ...<url>\`
	`
}

function main(...urls: string[]) {
	if (urls.length === 0) {
		throw new UsageError('--help=At least one <url> must be provided.')
	}

	for (const input of urls) {
		const url = new URL(input)
		const domain = `${url.protocol}//${url.host}`
		console.log(domain)
	}
}

try {
	if (wantsHelp(Deno.args)) {
		throw new UsageError()
	}
	main(...Deno.args)
} catch (error) {
	await exitWithError(error)
}
