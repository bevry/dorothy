#!/usr/bin/env -S eval-wsl deno run --quiet --no-config --no-lock --no-npm --no-remote --cached-only
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

export class AbstractHelpError extends CodeError {
	help?: string
	override readonly code = 22
	public override toString() {
		let message = this.help || ''
		if (this.message) {
			message += `\n\nERROR: ${this.message}`
		}
		return message
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
		// render error.toString() through executing `echo-style` command
		// const p = Deno.run({ cmd: ['echo-style', `--help=${message}`] })
		// status = (await p.status()) || status
		// Deno.exit(styleStatus || status)
		const message = error.toString()
		console.error(message)
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

export async function readStdinWhole(): Promise<string> {
	return new TextDecoder().decode(await Deno.readAll(Deno.stdin))
}
