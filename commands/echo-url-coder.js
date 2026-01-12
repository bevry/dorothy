#!/usr/bin/env node
const coder = process.argv[2] === 'decode' ? decodeURI : encodeURI
const url = process.argv[3]
console.log(coder(url))
