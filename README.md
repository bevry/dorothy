# [Benjamin Lupton's](http://balupton.com) Dotfiles

Goes well with my [New Machine Starter Kit](https://gist.github.com/balupton/5259595).


## Install

``` bash
# enter into a bash login shell
bash -il

# perform the installation
eval "$(curl -fsSL https://raw.githubusercontent.com/balupton/dotfiles/master/.scripts/commands/install-dotfiles)"
```

Put your private environment configuration into `.scripts/env.sh`

If you would like to do the setup process manually, refer to:

- [`.scripts/commands/install-dotfiles`](https://github.com/balupton/dotfiles/blob/master/.scripts/commands/install-dotfiles)
- [`.scripts/commands/setup-dotfiles`](https://github.com/balupton/dotfiles/blob/master/.scripts/commands/setup-dotfiles)


## Explanation

The dotfiles reside inside [`$HOME/.scripts`](https://github.com/balupton/dotfiles/tree/master/.scripts) which contains:

- [`commands` directory](https://github.com/balupton/dotfiles/tree/master/.scripts/commands) contains executable commands
- [`sources` directory](https://github.com/balupton/dotfiles/tree/master/.scripts/sources) contains scripts that are loaded into the shell environment
- [`themes` directory](https://github.com/balupton/dotfiles/tree/master/.scripts/themes) contains themes that you can select via the `THEME` environment variable
- [`init.fish`](https://github.com/balupton/dotfiles/blob/master/.scripts/init.fish) the initialisation script for the fish shell
- [`init.sh`](https://github.com/balupton/dotfiles/blob/master/.scripts/init.sh) the initialisation script for other shells

The initialisation scripts are loaded via the changes made to your dotfiles via the [`setup-dotfiles`](https://github.com/balupton/dotfiles/blob/master/.scripts//commands/setup-dotfiles) command.

To setup your machine with the exact same apps and preferences as Benjamin Lupton, then install the dotfiles, then run `install`, and every now and run `update` to keep thing updated.


## Highlights

- great compatibility
	- cross-shell compatibility, with tested support for `bash`, `fish`, and `zsh`
	- cross-operating-system compatibility, with tested support for MacOS and Ubuntu

- automatic editor detection
	- use `edit` to open your favourite installed editor automatically
		- in GUI environments will open your GUI editor
		- in terminal environments will open your terminal editor
	- git prompts are configured correctly to use your favourite terminal editor
	- uses `setup-editor-commands` to determine the correct configuration, which is then appied via the init scripts

- `install` and `update` will setup your entire system for development, including
	- installs and configures linux (via `setup-linux-*`) and mac (via `setup-mac-*`)
	- installs and configures node (via `setup-node`), ruby (via `setup-ruby`), python (via `setup-python`)
	- installs and configures vscode, and if atom is installed will configure it
	- installs fonts (via `setup-*-fonts`)
	- configures git (via `setup-git`)
		- user
		- diff
		- keychain
		- gpg
	- configures terminal commands for several GUI apps (via `setup-bin`)

- intelligent cross-shell setup of your PATH variables
	- uses `setup-paths-commands` to determine the correct configuration, which is then applied via `sources/paths.*` which are loaded by the init scripts

- ssh key management
	- stores ssh key passwords in the operating system's keychain, so you don't have to reenter them every time
	- `addsshkey` to add a specific ssh key to the agent
	- `addsshkeys` to all known ssh keys to the agent
	- `newsshkey` for generating new ssh keys

- `key` for creating and managing your gpg keys

- `sparse-vault` for creating and managing sparsebundles and sparseimages

- `macup` command for backup then restore of all your application and system preferences prior and after a computer restore

- `git-fix-email` for fixing incorrect contributor details in commit histories

- `down` for downloading files using the best currently installed downloader app

- `isodev` for opening the iOS simulator

- `podcast` for converting an audio file to a new file with aac-he 48k encoding

- `podvideo` for converting a video file to a new file with h264+aac encoding

- `vmerge` for merging multiple video files in a directory together into a single video file

- `rmvmware` for uninstalling vmware

- `addscripts` and `editscripts` for quickly working with these dotfiles

- `aliasdetails`, `aliases`, `aliasestosymlink`, `aliaspath`, `aliasverify` for converting MacOS aliases to symlinks

- `mailsync` to move everything from one IMAP provider to another

- `pdfdecrypt` for mass converting encrypted documents into new unencrypted documents

- `xps2pdf` for mass converting xps documents ito new pdf documents

- `findfiles` for finding files that match a given extension, and optionally running a command on them

- youtube download helpers
	- `youtube-dl-audio` for downloading the best quality audio from a youtube video with m4a encoding
	- `youtube-dl-native` for downloading the best quality options from a youtube video with mp4+m4a encoding
	- `youtube-dl-everything` for downloading an entire playlist using `youtube-dl-native`

- many helpers for general shell scripting, such as those named `command*`, `contains*`, `is*`, `silent*`


## License

Public Domain via [The Unlicense](https://choosealicense.com/licenses/unlicense/)

```
This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.

In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <http://unlicense.org>
```
