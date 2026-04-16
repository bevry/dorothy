# CURRENT TODOS

TODOS:

- verify all automatic `--upgrade` to `upgrade` were intentional, they may need to be `install` or `upstall`
- add `upstall`
- change `install --upgrade` to `upstall`
- check `setup-python` and other `setup-*` for if they want `upstall`
- consider `--upstall` for `setup-util --install="$option_install" --upgrade="$option_upgrade" --transpose=MAS -- "${packages[@]}"`
- `setup-util-bat upstall`
- `RECONFIGURE_` to `CONFIGURE_` ?
- converge on `has` vs `is-installed` nomenclature

- `setup-system` should adopt `install`, `upgrade`, `upstall`, `(re)configure` nomenclature

- `setup-util-discord` is still just a copy of `legcord`

- `setup-util-docker` changed from its own `--postinstall` to the `--reconfigure` convention

- `setup-utils`
- `get-installer`
- `get-app`
- `get-font`
- `open-app`

- `RECONFIGURE_INSTALLED_EVAL` - cannot reconfigure if check, as check is often conditional
- `RECONFIGURE_EVAL`
- `APT_INSTALL_EVAL`
- `AUR_INSTALL_EVAL`
- `RPM_INSTALL_EVAL`
- `APPIMAGE_FILENAME` automake
- `DOWNLOAD_BUILD_INSTALL` to `DOWNLOAD_BUILD_INSTALL_EVAL`

rpi
croc
ruby
rust
samba
snap
syncthing
transmission
xcode
resilio
plex-media-server

can `setup-util-node` use reconfigure?

mediainfo repo install

--spread
.exe

for review:

- check glob var has \*/ if originalcode had it

docker reconfigure, check, debug

.app/.dmg

- ghostty, has soar dusabled
- discord, ghostty, legcord, ple-media-server - all have .dmg, but uses .zip instead of .dmg
- hyper, obs, plexam, tabby - uses .dmg, with custom extraction
- rpi-imager, super-produc - uses dmg, but no custom extraction
- vivaldi and vcode use custom fetch andextraction `DOWNLOAD_ARCHIVE_EXTRACT`

- .exe

- ` && is-system --snap && snap list deno &>/dev/null` to `--source=snap`

```bash
setup-util -- bat git curl
setup-util get bat
setup-util has bat
setup-util-bat


# tell us information about bat
setup-util about|get bat # util-bat --help

# return json about bat installions, empty result if no bat installatins (failure exit status)
setup-util where|find|has bat

# returns [0] if the action is necessary
setup-util check bat
setup-util check bat --uninstall
setup-util check bat --install
setup-util check bat --upgrade

# open/invoke gitfox app/cli
setup-util open gitfox -- ...<argument>

# open the finder/browser to the location of each app/cli/font path matching it
setup-util browse gitfox


setup-util install bat
setup-util upgrade bat
setup-util uninstall bat

# all actions as either argument or flag
setup-util --uninstall --install --upgrade bat
setup-util --install --upgrade --uninstall bat
# order if uninstall and install provided, will always be uninstall first

setup-util --install bat # only install, no upgrade
setup-util --upgrade bat # only upgrade, no install
setup-util --install --upgrade bat # install OR upgrade

setup-util --quiet bat # no messaging, even if it is installing - when really, we just don't want messaging if no action is necessary (already installed)
setup-util --dependency bat # quiet if no action, otherwise TTY/STDERR if action
```

# Todos

- [ ] new intall/upgrade/uninstall as options, instead of action, allowing all to be run
- [ ] updating each source to properly support upgrade
- [ ] updating each source to properly support get
- [ ] implementing the dependency verbosity
- [ ] merging `utils` into `util`
- [ ] merging `get-app` and `get-font` into `util`

# OLDER TODOS

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
> setup-util-curlie --source=download --verbose
The `curlie` utility was not found. Installing automatically... ⏲
</ wget --continue --progress=dot:giga --output-document=curlie1.8.2darwinarm64.tar.gz https://github.com/rs/curlie/releases/download/v1.8.2/curlie_1.8.2_darwin_arm64.tar.gz >[0]
```

```plain
function __help {
	cat <<-EOF >&2
```

to

```plain
function __help {
	cat <<-EOF >&2 || return $?
```
