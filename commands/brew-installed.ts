#!/usr/bin/env -S eval-wsl deno run --quiet --no-config --no-lock --no-npm --no-remote --cached-only
// deno-lint-ignore-file no-explicit-any

function ensureNumber(input: string | number = '', fallback = 0): number {
	if (typeof input == 'number') {
		return input
	} else if (input == '0') {
		return 0
	} else if (!input) {
		return fallback
	} else {
		const number = Number(input)
		if (isNaN(number)) {
			return fallback
		} else {
			return number
		}
	}
}

// --type=<cask|formula|tap> | --type=
const optionType: 'cask' | 'formula' | 'tap' | '' = Deno.args.includes(
	'--type=cask',
)
	? 'cask'
	: Deno.args.includes('--type=formula')
		? 'formula'
		: Deno.args.includes('--type=tap')
			? 'tap'
			: '' // cask and formula
// --requested[=yes]
const optionRequested =
	Deno.args.includes('--requested') || Deno.args.includes('--requested=yes')
// --quiet[=yes]
const optionQuiet =
	Deno.args.includes('--quiet') || Deno.args.includes('--quiet=yes')
// --expects=<count>
const optionExpects = ensureNumber(
	Deno.args
		.find((value) => value.startsWith('--expects='))
		?.replace(/^.+?=/, ''),
	-1,
)
// --versions
const optionVersions: 'latest' | 'current' | false =
	Deno.args.includes('--versions') ||
	Deno.args.includes('--versions=yes') ||
	Deno.args.includes('--versions=latest')
		? 'latest'
		: Deno.args.includes('--versions=current')
			? 'current'
			: false
// --status=<updated|outdated> | --status=
const optionStatus: 'updated' | 'outdated' | '' = Deno.args.includes(
	'--status=updated',
)
	? 'updated'
	: Deno.args.includes('--status=outdated')
		? 'outdated'
		: '' // updated and outdated

// parse stdin as json
const json = await new Response(Deno.stdin.readable).json()

// prepare result
const names = new Set<string>()
const currentVersions = new Map<string, string>()
const latestVersions = new Map<string, string>()

// add taps if desired
if (['tap'].includes(optionType)) {
	// all taps are by request
	const taps = json || []
	for (const tap of taps) {
		if (tap.installed) {
			names.add(tap.name)
		}
	}
} else {
	// add casks if desired
	if (['', 'cask'].includes(optionType)) {
		// {
		//   "token": "whatsapp",
		//   "full_token": "whatsapp",
		//   "old_tokens": [],
		//   "tap": "homebrew/cask",
		//   "name": [
		//     "WhatsApp"
		//   ],
		//   "desc": "Native desktop client for WhatsApp",
		//   "homepage": "https://www.whatsapp.com/",
		//   "url": "https://web.whatsapp.com/desktop/mac_native/release/?version=2.26.25.12&extension=zip&configuration=Release&branch=master&is_buck=true",
		//   "url_specs": {},
		//   "version": "26.25.12",
		//   "autobump": true,
		//   "no_autobump_message": null,
		//   "skip_livecheck": false,
		//   "installed": "2.2305.7",
		//   "installed_time": 1675799733,
		//   "bundle_version": null,
		//   "bundle_short_version": null,
		//   "pinned": false,
		//   "pinned_version": null,
		//   "outdated": false,
		//   "sha256": "72d7d766ede5df2bef52ed5162ed5da99cc38999f03e4ca821437f6bb19bfab0",
		//   "artifacts": [
		//     {
		//       "uninstall": [
		//         {
		//           "quit": "net.whatsapp.WhatsApp"
		//         }
		//       ]
		//     },
		//     {
		//       "app": [
		//         "WhatsApp.app"
		//       ],
		//       "target": "/Applications/WhatsApp.app"
		//     },
		//     {
		//       "zap": [
		//         {
		//           "trash": [
		//             "~/Library/Application Scripts/net.whatsapp.WhatsApp*",
		//             "~/Library/Caches/net.whatsapp.WhatsApp",
		//             "~/Library/Containers/net.whatsapp.WhatsApp*",
		//             "~/Library/Group Containers/group.com.facebook.family",
		//             "~/Library/Group Containers/group.net.whatsapp*",
		//             "~/Library/Saved Application State/net.whatsapp.WhatsApp.savedState"
		//           ]
		//         }
		//       ]
		//     }
		//   ],
		//   "caveats": null,
		//   "caveats_rosetta": null,
		//   "depends_on": {
		//     "macos": {
		//       ">=": [
		//         "12"
		//       ]
		//     }
		//   },
		//   "conflicts_with": {
		//     "cask": [
		//       "whatsapp@beta"
		//     ]
		//   },
		//   "container": null,
		//   "rename": [],
		//   "auto_updates": true,
		//   "deprecated": false,
		//   "deprecation_date": null,
		//   "deprecation_reason": null,
		//   "deprecation_replacement_formula": null,
		//   "deprecation_replacement_cask": null,
		//   "deprecate_args": null,
		//   "disabled": false,
		//   "disable_date": null,
		//   "disable_reason": null,
		//   "disable_replacement_formula": null,
		//   "disable_replacement_cask": null,
		//   "disable_args": null,
		//   "tap_git_head": "dc00bb9e2fa411eea7989b81362065df4b7be0f9",
		//   "languages": [],
		//   "ruby_source_path": "Casks/w/whatsapp.rb",
		//   "ruby_source_checksum": {
		//     "sha256": "86b48b80a6d32b23646058c90119cb3ad992bed5a212849605a666f1a43fa462"
		//   }
		// }
		// all casks are by request
		const casks = json.casks || []
		for (const cask of casks) {
			// installed sanity check
			if (!cask.installed) continue
			// status filter check
			const updated = cask.auto_updates || !cask.outdated
			const outdated = !updated
			if (optionStatus == 'outdated' && !outdated) {
				continue
			} else if (optionStatus == 'updated' && !updated) {
				continue
			}
			// store
			if (optionVersions) {
				const currentVersion = cask.installed
				const latestVersion = cask.version
				currentVersions.set(cask.full_token, currentVersion)
				latestVersions.set(cask.full_token, latestVersion)
				// console.debug({
				// 	name: cask.full_token,
				// 	current: currentVersion,
				// 	latest: latestVersion,
				// 	outdated: cask.outdated,
				// 	auto: cask.auto_updates,
				// 	status: updated ? 'up-to-date' : 'out-of-date',
				// })
			}
			names.add(cask.full_token)
		}
	}

	// add formulas if desired
	if (['', 'formula'].includes(optionType)) {
		// {
		//   "name": "abseil",
		//   "full_name": "abseil",
		//   "tap": "homebrew/core",
		//   "oldnames": [],
		//   "aliases": [],
		//   "versioned_formulae": [],
		//   "desc": "C++ Common Libraries",
		//   "license": "Apache-2.0",
		//   "homepage": "https://abseil.io",
		//   "versions": {
		//     "stable": "20260107.1",
		//     "head": "HEAD",
		//     "bottle": true
		//   },
		//   "urls": {
		//     "stable": {
		//       "url": "https://github.com/abseil/abseil-cpp/archive/refs/tags/20260107.1.tar.gz",
		//       "tag": null,
		//       "revision": null,
		//       "using": null,
		//       "checksum": "4314e2a7cbac89cac25a2f2322870f343d81579756ceff7f431803c2c9090195"
		//     },
		//     "head": {
		//       "url": "https://github.com/abseil/abseil-cpp.git",
		//       "branch": "master",
		//       "using": null
		//     }
		//   },
		//   "patches": [],
		//   "revision": 0,
		//   "version_scheme": 0,
		//   "compatibility_version": null,
		//   "autobump": true,
		//   "no_autobump_message": null,
		//   "skip_livecheck": false,
		//   "bottle": {
		//     "stable": {
		//       "rebuild": 0,
		//       "root_url": "https://ghcr.io/v2/homebrew/core",
		//       "files": {
		//         "arm64_tahoe": {
		//           "cellar": "/opt/homebrew/Cellar",
		//           "url": "https://ghcr.io/v2/homebrew/core/abseil/blobs/sha256:90697dc0727974c4a873ed19e63c30bc4c9525566cbd0ff968f980ce15047ae8",
		//           "sha256": "90697dc0727974c4a873ed19e63c30bc4c9525566cbd0ff968f980ce15047ae8"
		//         }
		//       }
		//     }
		//   },
		//   "pour_bottle_only_if": null,
		//   "keg_only": false,
		//   "keg_only_reason": null,
		//   "options": [],
		//   "build_dependencies": [
		//     "cmake",
		//     "googletest"
		//   ],
		//   "dependencies": [],
		//   "test_dependencies": [
		//     "cmake"
		//   ],
		//   "recommended_dependencies": [],
		//   "optional_dependencies": [],
		//   "uses_from_macos": [],
		//   "uses_from_macos_bounds": [],
		//   "requirements": [],
		//   "conflicts_with": [],
		//   "conflicts_with_reasons": [],
		//   "link_overwrite": [],
		//   "caveats": null,
		//   "installed": [
		//     {
		//       "version": "20260107.1",
		//       "used_options": [],
		//       "built_as_bottle": true,
		//       "poured_from_bottle": true,
		//       "time": 1771342111,
		//       "runtime_dependencies": [],
		//       "installed_on_request": false
		//     }
		//   ],
		//   "linked_keg": "20260107.1",
		//   "pinned": false,
		//   "outdated": false,
		//   "deprecated": false,
		//   "deprecation_date": null,
		//   "deprecation_reason": null,
		//   "deprecation_replacement_formula": null,
		//   "deprecation_replacement_cask": null,
		//   "deprecate_args": null,
		//   "disabled": false,
		//   "disable_date": null,
		//   "disable_reason": null,
		//   "disable_replacement_formula": null,
		//   "disable_replacement_cask": null,
		//   "disable_args": null,
		//   "post_install_steps": [],
		//   "post_install_defined": false,
		//   "service": null,
		//   "tap_git_head": "c74febca1780f550c89649857a82e09c1d08491c",
		//   "ruby_source_path": "Formula/a/abseil.rb",
		//   "ruby_source_checksum": {
		//     "sha256": "1a347881f05e38002aea73e3d027e0cc2bd68dcc0c8b03f61cae2403a486efb1"
		//   }
		// },
		const formulae = json.formulae || []
		for (const formula of formulae) {
			// installed sanity check
			if (formula.installed.length === 0) continue
			// requested check
			const wasOnRequest = formula.installed.find(
				(i: any) => i.installed_on_request,
			)
				? true
				: false
			if (optionRequested && !wasOnRequest) {
				continue
			}
			// status filter check
			if (optionStatus == 'outdated' && !formula.outdated) {
				continue
			} else if (optionStatus == 'updated' && formula.outdated) {
				continue
			}
			// store
			if (optionVersions) {
				// @todo load in <https://github.com/bevry/version-compare> to get the latest currently installed version, right now this just assumes it is the first, which I'm unsure about
				const currentVersion = formula.installed[0].version
				const latestVersion = formula.versions.stable
				currentVersions.set(formula.full_name, currentVersion)
				latestVersions.set(formula.full_name, latestVersion)
			}
			names.add(formula.full_name)
		}
	}
}

// output result
if (names.size && optionQuiet === false) {
	await Deno.stdout.write(
		new TextEncoder().encode(
			Array.from(names)
				.sort()
				.map(
					optionVersions === 'latest'
						? (name: string) =>
								`${name} ${currentVersions.get(name)} ${latestVersions.get(name)}`
						: optionVersions === 'current'
							? (name: string) => `${name} ${currentVersions.get(name)}`
							: (name: string) => name,
				)
				.concat('')
				.join('\n'),
		),
	)
}
if (optionExpects >= 0 && optionExpects != names.size) {
	Deno.exit(91) // ENOMSG 91 No message of desired type
}
