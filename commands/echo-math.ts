#!/usr/bin/env -S eval-wsl deno run --quiet --no-config --no-lock --no-npm --no-remote --cached-only
const precision = Number(Deno.args[0])
const formula = Deno.args[1]
const result = Number(eval(formula))
const output = result.toFixed(precision)
console.log(output)
