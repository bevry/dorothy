#!/usr/bin/env -S eval-wsl deno run --allow-net --quiet --no-config --no-lock --no-npm --no-remote --cached-only
// deno-lint-ignore-file no-explicit-any
const [apikey, username, collection] = Deno.args
if (!apikey || !username || !collection) {
	throw new Error('Missing arguments: apikey, username, collection')
}
const url = new URL(
	`https://wallhaven.cc/api/v1/collections/${username}/${collection}?apikey=${apikey}`,
)
function stderr(text: string) {
	return Deno.stderr.write(new TextEncoder().encode(text + '\n'))
}
function stdout(text: string) {
	return Deno.stdout.write(new TextEncoder().encode(text + '\n'))
}
function wait(ms: number, callback: () => void) {
	return new Promise((resolve, reject) => {
		setTimeout(function () {
			try {
				resolve(callback())
			} catch (error) {
				reject(error)
			}
		}, ms)
	})
}
async function fetchNextPage() {
	await stderr('Fetching: ' + url.toString())
	const req = await fetch(url)
	if (req.status === 429) {
		await stderr('Waiting 45 seconds for rate limiting.')
		return await wait(45 * 1000, fetchNextPage)
	}
	const text = await req.text()
	const json: any = await Promise.resolve().then(function () {
		try {
			return JSON.parse(text)
		} catch (err) {
			console.error('Failed to parse JSON:', err, text)
			return Promise.reject('Failed to download ' + url)
		}
	})
	const urls = json.data.map((item: any) => item.path)
	await stdout(urls.join('\n'))
	if (json.meta.last_page !== json.meta.current_page) {
		url.searchParams.set('page', String(json.meta.current_page + 1))
		fetchNextPage()
	}
}
await fetchNextPage()
