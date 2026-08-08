#!/usr/bin/env -S eval-wsl deno run --quiet --no-config --no-lock --no-npm --no-remote --cached-only

import { heredoc, HelpError, exitWithError, wantsHelp } from '../sources/ts.ts'

class UsageError extends HelpError {
	override help = heredoc`
		USAGE:
		\`echo-math.ts <precision> <formula>\`

		EXAMPLE:
		\`echo-math.ts 2 "1/3"\`
	`
}

function assertFormula(value: unknown): asserts value is string {
	if (typeof value !== 'string' || value.trim() === '') {
		throw new UsageError('--help=<formula> must be a non-empty string.')
	}
	if (!/^[0-9+\-*/%().\s]+$/.test(value)) {
		throw new UsageError(
			'--help=The <formula> may only contain numbers, spaces, and math operators: \`+ - * / % ( ) .\`',
		)
	}
}

function assertPrecision(value: number): asserts value is number {
	if (!Number.isFinite(value) || !Number.isInteger(value) || value < 0) {
		throw new UsageError('--help=<precision> must be a non-negative integer.')
	}
}

function assertEvaluatedNumber(value: number): asserts value is number {
	if (Number.isNaN(value)) {
		throw new UsageError('--help=<formula> must evaluate to a number.')
	}
}

function main(...args: string[]) {
	if (args.length < 2) {
		throw new UsageError('--help=Expected <precision> and <formula>.')
	}
	const precisionInput: unknown = args[0]
	const formulaInput: unknown = args[1]
	assertFormula(formulaInput)
	const precision = Number(precisionInput)
	assertPrecision(precision)
	const formula = formulaInput
	const result = Number(eval(formula))
	assertEvaluatedNumber(result)
	const output = result.toFixed(precision)
	console.log(output)
}

try {
	if (wantsHelp(Deno.args)) {
		throw new UsageError()
	}
	main(...Deno.args)
} catch (error) {
	await exitWithError(error)
}
