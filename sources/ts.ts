#!/usr/bin/env -S deno run --quiet --no-config --no-lock --no-npm --no-remote --cached-only
// this file is alpha quality, conventions will change, feedback welcome
// for instance, here's some over-engineered alternative:
// https://gist.github.com/balupton/4138b7ab3bb72caf020c061a872e1631

export class CodeError extends Error {
	readonly code: number
	constructor(message: string, code = 1) {
		super(message)
		this.code = code
	}
}

export class AbstractHelpError extends Error {
	help: string
	readonly code = 22
	public toString() {
		let message = this.help
		if (this.message) {
			message += `\n\nERROR: ${this.message}`
		}
		return message
	}
}

export async function exitWithError(error?: Error, status?: integer) {
	if (status == null || status < 0) {
		if (error instanceof Error) {
			status = error.code ?? 1
		} else {
			status = 1
		}
	}
	// render error.toString() through executing `echo-style` command
	const message = error.toString()
	// const p = Deno.run({ cmd: ['echo-style', `--help=${message}`] })
	// status = (await p.status()) || status
	// Deno.exit(styleStatus || status)
	console.error(message)
	Deno.exit(status)
}

export function writeStdoutStringify(output: string) {
	return writeStdoutPlain(JSON.stringify(output))
}

export function writeStdoutPlain(output: string) {
	return Deno.stdout.write(new TextEncoder().encode(output))
}

export function writeStdoutPretty(output: unknown) {
	console.log(output)
}

export async function readStdinWhole(): Promise<string> {
	return new TextDecoder().decode(await Deno.readAll(Deno.stdin))
}
