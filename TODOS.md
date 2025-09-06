# TODOS

ssh-helper --install=\*

is-\* --reason support

support --no-status and --status=no/null to discard status so failure returns 0

ensure-trailing-newline
ensure-trailing-slash
echo-file
echo-write
config-helper

get-devices
get-terminal-quiet-support could remove need for \__is_non_affirmative as it has eval_

debug-terminal-tty
fs-dequarantine should use is-fs
commands.test/bash.bash
echo-style --tty

`\\\n(\s+)-- `
`-- \\\n$1`

```plain
> setup-util-curlie --order=download --verbose
The [curlie] utility was not found. Installing automatically... ⏲
</ wget --continue --progress=dot:giga --output-document=curlie1.8.2darwinarm64.tar.gz https://github.com/rs/curlie/releases/download/v1.8.2/curlie_1.8.2_darwin_arm64.tar.gz >[0]
```

```
	function __help {
		cat <<-EOF >&2
```

to

```
	function __help {
		cat <<-EOF >&2 || return
```
