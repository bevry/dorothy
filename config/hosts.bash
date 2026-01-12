#!/usr/bin/env bash
# shellcheck disable=SC2034
# Used by `setup-hosts`, use `--configure` to (re)configure this
# Do not use `export` keyword in this file

# For details about hosts files, check out these resources:
# https://en.wikipedia.org/wiki/Hosts_(file)
#
# For selections of hosts files, check out these resources:
# https://github.com/StevenBlack/hosts
#
# And here are references for posterity that are inferior to the above:
# https://raw.githubusercontent.com/AdAway/adaway.github.io/master/hosts.txt

# Label first, then url
OPTIONS=(
	'Unified hosts = (adware + malware)' # =>
	'https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts'
	'Unified hosts + fakenews' # =>
	'https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews/hosts'
	'Unified hosts + gambling' # =>
	'https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/gambling/hosts'
	'Unified hosts + porn' # =>
	'https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/porn/hosts'
	'Unified hosts + social' # =>
	'https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/social/hosts'
	'Unified hosts + fakenews + gambling' # =>
	'https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling/hosts'
	'Unified hosts + fakenews + porn' # =>
	'https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-porn/hosts'
	'Unified hosts + fakenews + social' # =>
	'https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-social/hosts'
	'Unified hosts + gambling + porn' # =>
	'https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/gambling-porn/hosts'
	'Unified hosts + gambling + social' # =>
	'https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/gambling-social/hosts'
	'Unified hosts + porn + social' # =>
	'https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/porn-social/hosts'
	'Unified hosts + fakenews + gambling + porn' # =>
	'https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn/hosts'
	'Unified hosts + fakenews + gambling + social' # =>
	'https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-social/hosts'
	'Unified hosts + fakenews + porn + social' # =>
	'https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-porn-social/hosts'
	'Unified hosts + gambling + porn + social' # =>
	'https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/gambling-porn-social/hosts'
	'Unified hosts + fakenews + gambling + porn + social' # =>
	'https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn-social/hosts'
)

# If we have a preference, we can set CHOICE to the URL value of our desired hosts file
CHOICE='' # 'https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn-social/hosts'
